/*
Wardrobe 5-8 extended-capability handshake: pure logic (no server state), testable offline.
Design: docs/slices/wardrobe5-8/HANDSHAKE_DESIGN.md. Wire IDs verified against the original 2019 client:
docs/slices/wardrobe5-8/CLIENT_AUDIT_RESULTS.md (both IDs must be < 0x11F).

Hello (client->server), 20 bytes:  +0 header(id 0x103, N=5)  +4 'W58H'  +8 proto u16  +10 flags u16  +12 patchset[8]
Ack   (server->client), 24 bytes:  +0 header(id 0x103, N=6)  +4 'W58A'  +8 proto u16  +10 granted u16
                                   +12 size[4] u8 (1+size, wardrobes 5-8)  +16 cap[4] u16 (1+buff)
Default is deny: nothing grants unless enabled, well-formed, and the patch-set is on the allow-list.
*/
#ifndef _W58_HANDSHAKE_H
#define _W58_HANDSHAKE_H

#include <array>
#include <cstring>
#include <string>
#include <vector>

#include "../../common/cbasetypes.h"

#define W58_PACKET_ID          0x103
#define W58_PROTO_VERSION      1
#define W58_HELLO_LENGTH       20
#define W58_ACK_LENGTH         24
#define W58_PATCHSET_LEN       8
#define W58_MAX_HELLOS_PER_ZONE 8   // further hellos in the same zone-in are ignored

static const uint8 W58_HELLO_MAGIC[4] = { 'W', '5', '8', 'H' };
static const uint8 W58_ACK_MAGIC[4]   = { 'W', '5', '8', 'A' };

typedef std::array<uint8, W58_PATCHSET_LEN> w58_patchset_t;

struct w58_hello_t
{
    uint16         proto;
    uint16         flags;
    w58_patchset_t patchset;
};

enum W58_VERDICT
{
    W58_GRANT = 0,
    W58_DISABLED,         // conf flag off: ignore silently
    W58_BAD_LENGTH,
    W58_BAD_MAGIC,
    W58_BAD_PROTO,
    W58_BAD_FLAGS,
    W58_UNKNOWN_PATCHSET, // includes an empty allow-list
    W58_NOT_IN_ZONE,
    W58_THROTTLED
};

// Parse a hello. `length` is the packet length in bytes taken from the header. Does not read past `length`.
inline W58_VERDICT W58ParseHello(const uint8* data, size_t length, w58_hello_t* out)
{
    if (data == nullptr || length != W58_HELLO_LENGTH)
        return W58_BAD_LENGTH;
    if (std::memcmp(data + 4, W58_HELLO_MAGIC, 4) != 0)
        return W58_BAD_MAGIC;
    out->proto = (uint16)(data[8] | (data[9] << 8));
    out->flags = (uint16)(data[10] | (data[11] << 8));
    std::memcpy(out->patchset.data(), data + 12, W58_PATCHSET_LEN);
    if (out->proto != W58_PROTO_VERSION)
        return W58_BAD_PROTO;
    if (out->flags != 0)                 // reserved in proto 1
        return W58_BAD_FLAGS;
    return W58_GRANT;
}

// "0123456789abcdef,fedcba9876543210" -> list. Tokens that are not exactly 16 hex chars are skipped and counted.
inline std::vector<w58_patchset_t> W58ParseAllowList(const std::string& text, size_t* rejected = nullptr)
{
    std::vector<w58_patchset_t> out;
    size_t bad = 0, pos = 0;
    while (pos <= text.size())
    {
        size_t end = text.find(',', pos);
        if (end == std::string::npos) end = text.size();
        std::string tok = text.substr(pos, end - pos);
        size_t a = tok.find_first_not_of(" \t\r\n"), b = tok.find_last_not_of(" \t\r\n");
        tok = (a == std::string::npos) ? std::string() : tok.substr(a, b - a + 1);
        if (!tok.empty())
        {
            w58_patchset_t ps{};
            bool ok = tok.size() == 2 * W58_PATCHSET_LEN;
            for (size_t i = 0; ok && i < tok.size(); ++i)
            {
                char c = tok[i];
                int v = (c >= '0' && c <= '9') ? c - '0' : (c >= 'a' && c <= 'f') ? c - 'a' + 10 : (c >= 'A' && c <= 'F') ? c - 'A' + 10 : -1;
                if (v < 0) ok = false; else ps[i / 2] = (uint8)((i % 2 == 0) ? (v << 4) : (ps[i / 2] | v));
            }
            if (ok) out.push_back(ps); else ++bad;
        }
        pos = end + 1;
    }
    if (rejected) *rejected = bad;
    return out;
}

// The grant decision. Order matters: cheap/silent refusals first. All inputs are plain values.
inline W58_VERDICT W58Decide(bool enabled, const uint8* data, size_t length, const std::vector<w58_patchset_t>& allow,
                             bool inZone, uint32 hellosThisZone)
{
    if (!enabled)
        return W58_DISABLED;
    if (!inZone)
        return W58_NOT_IN_ZONE;
    if (hellosThisZone >= W58_MAX_HELLOS_PER_ZONE)
        return W58_THROTTLED;
    w58_hello_t hello;
    W58_VERDICT v = W58ParseHello(data, length, &hello);
    if (v != W58_GRANT)
        return v;
    for (const auto& ps : allow)
        if (ps == hello.patchset)
            return W58_GRANT;
    return W58_UNKNOWN_PATCHSET;
}

inline const char* W58VerdictName(W58_VERDICT v)
{
    switch (v)
    {
        case W58_GRANT: return "grant";                 case W58_DISABLED: return "disabled";
        case W58_BAD_LENGTH: return "bad length";       case W58_BAD_MAGIC: return "bad magic";
        case W58_BAD_PROTO: return "bad protocol";      case W58_BAD_FLAGS: return "bad flags";
        case W58_UNKNOWN_PATCHSET: return "patch-set not allowed";
        case W58_NOT_IN_ZONE: return "not in zone";     case W58_THROTTLED: return "throttled";
    }
    return "?";
}

#endif
