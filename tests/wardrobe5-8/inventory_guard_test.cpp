// Offline test: egress guard + equip/ingress container tables. No server, DB or client needed.
// Build/run (from repo root):
//   g++ -std=c++17 -Isrc -Isrc/map -o /tmp/w58_guard tests/wardrobe5-8/inventory_guard_test.cpp \
//       src/map/packets/inventory_modify.cpp && /tmp/w58_guard
#include <cstdio>
#include <cstring>
#include "map/packets/inventory_guard.h"
#include "map/packets/inventory_modify.h"

static int fails = 0;
#define CHECK(c) do { if (!(c)) { std::printf("FAIL line %d: %s\n", __LINE__, #c); ++fails; } } while (0)

int main()
{
    // Raw-byte guard: only 0x1E/0x1F/0x20 are inspected, at the verified offsets.
    const struct { uint16 type; int off; } fmt[] = { {0x1E, 0x08}, {0x1F, 0x0A}, {0x20, 0x0E} };
    for (auto& f : fmt)
        for (int c = 0; c < 256; ++c)
        {
            uint8 buf[0x30] = {};
            buf[f.off] = (uint8)c;
            CHECK(InventoryPacketBlocked(f.type, buf, false) == (c >= 13));
            CHECK(InventoryPacketBlocked(f.type, buf, true) == (c >= 17));
            // other bytes must not influence the decision
            uint8 noise[0x30]; std::memset(noise, 0xFF, sizeof noise); noise[f.off] = (uint8)c;
            CHECK(InventoryPacketBlocked(f.type, noise, false) == (c >= 13));
        }
    { uint8 buf[0x30]; std::memset(buf, 0xFF, sizeof buf);
      for (uint16 t : {0x1C, 0x1D, 0x21, 0x00A, 0x1FF}) { CHECK(!InventoryPacketBlocked(t, buf, false)); } }

    // Real builder (0x1E): the container byte really is at +0x08.
    { CInventoryModifyPacket legacyOk(LOC_WARDROBE4, 5, 1);
      CInventoryModifyPacket extOnly(LOC_WARDROBE5, 5, 1);
      CInventoryModifyPacket bad(200, 5, 1);
      CHECK(legacyOk.id() == 0x1E);
      CHECK(!InventoryPacketBlocked(legacyOk.id(), static_cast<uint8*>(legacyOk), false));
      CHECK( InventoryPacketBlocked(extOnly.id(), static_cast<uint8*>(extOnly), false));
      CHECK(!InventoryPacketBlocked(extOnly.id(), static_cast<uint8*>(extOnly), true));
      CHECK( InventoryPacketBlocked(bad.id(), static_cast<uint8*>(bad), true)); }

    // Client handler table is 0x11F entries (IDs 0-0x11E); dispatcher does no bounds check.
    for (int t = 0; t < 0x200; ++t) CHECK(ClientInboundIdSafe((uint16)t) == (t <= 0x11E));
    CHECK(CLIENT_INBOUND_ID_LIMIT == 0x11F);

    // Equip table
    for (int id = 0; id < 256; ++id)
    {
        bool legacyEq = id == 0 || id == 8 || id == 10 || id == 11 || id == 12;
        CHECK(IsEquippableContainer((uint8)id, false) == legacyEq);
        CHECK(IsEquippableContainer((uint8)id, true) == (legacyEq || (id >= 13 && id <= 16)));
    }
    std::printf(fails ? "FAILED (%d)\n" : "OK\n", fails);
    return fails != 0;
}
