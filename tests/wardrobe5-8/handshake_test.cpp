// Offline test: Wardrobe 5-8 handshake logic and ack packet. No server, DB or client needed.
// Build/run (repo root):
//   g++ -std=c++17 -w -Isrc -Isrc/map -Isrc/common -o /tmp/w58_hs tests/wardrobe5-8/handshake_test.cpp \
//       src/map/packets/w58_ack.cpp && /tmp/w58_hs
#include <cstdio>
#include "map/packets/w58_ack.h"
#include "map/packets/w58_handshake.h"
#include "map/packets/inventory_guard.h"

static int fails = 0;
#define CHECK(c) do { if (!(c)) { std::printf("FAIL line %d: %s\n", __LINE__, #c); ++fails; } } while (0)

static void makeHello(uint8* b, uint16 proto = 1, uint16 flags = 0, const char* magic = "W58H",
                      const uint8 ps[8] = nullptr)
{
    std::memset(b, 0, W58_HELLO_LENGTH);
    b[0] = 0x03; b[1] = (5 << 1) | 1;                  // id 0x103, N=5 words => 20 bytes
    std::memcpy(b + 4, magic, 4);
    b[8] = proto & 0xFF; b[9] = proto >> 8; b[10] = flags & 0xFF; b[11] = flags >> 8;
    static const uint8 def[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
    std::memcpy(b + 12, ps ? ps : def, 8);
}

int main()
{
    // IDs: both directions must stay below the client's 0x11F limits
    CHECK(W58_PACKET_ID == 0x103 && ClientInboundIdSafe(W58_PACKET_ID));
    CHECK(W58_HELLO_LENGTH == 20 && W58_ACK_LENGTH == 24);

    uint8 h[20]; w58_hello_t out;
    makeHello(h);
    CHECK(W58ParseHello(h, 20, &out) == W58_GRANT && out.proto == 1 && out.flags == 0 && out.patchset[7] == 8);
    CHECK(W58ParseHello(h, 19, &out) == W58_BAD_LENGTH);
    CHECK(W58ParseHello(h, 21, &out) == W58_BAD_LENGTH);
    CHECK(W58ParseHello(h, 0, &out) == W58_BAD_LENGTH);
    CHECK(W58ParseHello(nullptr, 20, &out) == W58_BAD_LENGTH);
    makeHello(h, 1, 0, "W58A");  CHECK(W58ParseHello(h, 20, &out) == W58_BAD_MAGIC);   // an ack is not a hello
    makeHello(h, 1, 0, "w58h");  CHECK(W58ParseHello(h, 20, &out) == W58_BAD_MAGIC);
    makeHello(h, 0);             CHECK(W58ParseHello(h, 20, &out) == W58_BAD_PROTO);
    makeHello(h, 2);             CHECK(W58ParseHello(h, 20, &out) == W58_BAD_PROTO);
    makeHello(h, 1, 1);          CHECK(W58ParseHello(h, 20, &out) == W58_BAD_FLAGS);
    makeHello(h, 1, 0x8000);     CHECK(W58ParseHello(h, 20, &out) == W58_BAD_FLAGS);

    // Allow-list
    size_t bad = 0;
    auto al = W58ParseAllowList("0102030405060708, FFEEDDCCBBAA9988 ,,zz02030405060708,01020304050607,010203040506070809", &bad);
    CHECK(al.size() == 2 && bad == 3);
    CHECK(al[0][0] == 0x01 && al[0][7] == 0x08 && al[1][0] == 0xFF && al[1][7] == 0x88);
    bad = 99; CHECK(W58ParseAllowList("", &bad).empty() && bad == 0);
    CHECK(W58ParseAllowList("   ,  ,", nullptr).empty());

    // Decision table
    makeHello(h);
    auto good = W58ParseAllowList("0102030405060708");
    CHECK(W58Decide(true, h, 20, good, true, 0) == W58_GRANT);
    CHECK(W58Decide(false, h, 20, good, true, 0) == W58_DISABLED);                  // flag off beats everything
    CHECK(W58Decide(false, nullptr, 0, {}, false, 255) == W58_DISABLED);
    CHECK(W58Decide(true, h, 20, good, false, 0) == W58_NOT_IN_ZONE);
    CHECK(W58Decide(true, h, 20, good, true, W58_MAX_HELLOS_PER_ZONE - 1) == W58_GRANT);
    CHECK(W58Decide(true, h, 20, good, true, W58_MAX_HELLOS_PER_ZONE) == W58_THROTTLED);
    CHECK(W58Decide(true, h, 20, {}, true, 0) == W58_UNKNOWN_PATCHSET);            // empty allow-list = deny
    uint8 other[8] = { 1, 2, 3, 4, 5, 6, 7, 9 };
    makeHello(h, 1, 0, "W58H", other);
    CHECK(W58Decide(true, h, 20, good, true, 0) == W58_UNKNOWN_PATCHSET);          // one wrong byte
    makeHello(h, 1, 0, "XXXX");
    CHECK(W58Decide(true, h, 20, good, true, 0) == W58_BAD_MAGIC);
    CHECK(W58Decide(true, h, 12, good, true, 0) == W58_BAD_LENGTH);
    // every non-grant verdict must have a name
    for (int v = 0; v <= W58_THROTTLED; ++v) CHECK(W58VerdictName((W58_VERDICT)v)[0] != '?');

    // Hello header as the client writes it: id | N<<9, and DSP's PacketSize check value
    { uint16 hdr = (uint16)(W58_PACKET_ID | (5 << 9));
      uint8 b1 = hdr >> 8;
      CHECK((hdr & 0x1FF) == W58_PACKET_ID);
      CHECK((b1 & 0xFE) == 0x0A);                  // registered as PacketSize[0x103] = 0x0A
      CHECK((hdr >> 9) * 4 == W58_HELLO_LENGTH); }

    // Ack packet (real class)
    const uint8 sizes[4] = { 81, 1, 41, 0 };
    const uint16 caps[4] = { 0x0201, 0x0001, 0x0102, 0x00FF };
    CW58AckPacket ack(sizes, caps);
    uint8* d = static_cast<uint8*>(ack);
    CHECK(ack.id() == 0x103);
    CHECK(ack.length() == 24);
    CHECK(d[0] == 0x03 && d[1] == (12 | 1));                                      // low id byte; length/2 with ninth id bit
    CHECK(((d[0] | (d[1] << 8)) >> 9) * 4 == 24);                                  // how the 2019 client sizes it
    CHECK(std::memcmp(d + 4, "W58A", 4) == 0);
    CHECK(d[8] == 1 && d[9] == 0 && d[10] == 0 && d[11] == 0);
    CHECK(d[12] == 81 && d[13] == 1 && d[14] == 41 && d[15] == 0);
    CHECK(d[16] == 0x01 && d[17] == 0x02 && d[18] == 0x01 && d[19] == 0x00 && d[20] == 0x02 && d[21] == 0x01 && d[22] == 0xFF && d[23] == 0x00);
    CHECK(!InventoryPacketBlocked(ack.id(), d, false));                            // not an inventory packet
    CHECK(ClientInboundIdSafe(ack.id()));
    // an ack is never accepted as a hello
    CHECK(W58ParseHello(d, 24, &out) == W58_BAD_LENGTH);

    std::printf(fails ? "FAILED (%d)\n" : "OK\n", fails);
    return fails != 0;
}
