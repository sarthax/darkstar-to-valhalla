# Extended-capability handshake - design proposal (for owner review)

Status: SERVER SIDE IMPLEMENTED 2026-10-22 (offline-tested only; server not built or run; client side not started). Packet ID `0x103` both ways per `CLIENT_AUDIT_RESULTS.md`.

## Goal and threat model
Guarantee the unmodified December 2019 client never receives container IDs 13-16 or the 18-container 0x1C layout, and that a patched client gets them only when both ends agree.
This protects against **accidents** (wrong DLL, old DLL, patched client against an unpatched server). It is not defense against a hostile user: a user can fake a hello, and the only victim is their own client. The server still validates every inbound container ID so a spoofed session cannot touch containers it should not (see "Ingress").

## Why not the existing signals
| Candidate | Verdict |
|---|---|
| Login `CLIENT_VER` string (`lobby.cpp`) | Rejected. Original and patched DLL report the same string; it is checked at the lobby, not per map session. |
| Per-account / per-character DB flag | Rejected. One account may run either client; proves nothing about the process connecting now. |
| Per-IP or conf allow-list of players | Rejected. Same reason; also brittle. |
| **Explicit hello from the patched client + server ack** | **Proposed.** An unmodified client cannot produce a packet it has no code to send. |

## Protocol
All traffic uses the existing encrypted map channel.

1. **Server always starts legacy.** At zone-in (`SmallPacket0x00C` -> `CInventorySizePacket`, and `SendInventory`) the server sends exactly today's 13-container 0x1C and item pushes. No ordering dependency: a handshake arriving late or never just means the client stays legacy.
2. **Client hello** (client->server, fixed size, placeholder ID `C2S_W58_HELLO`): `magic u32` (`'W58H'`), `proto u16` (1), `flags u16` (0), `patchset[8]` (first 8 bytes of SHA-256 of the patch-set definition, not of the DLL), `reserved`. Sent by the patched client after it has parsed the first legacy 0x1C of each zone-in.
3. **Server decision.** Grant only if ALL hold: conf `wardrobe58_enable=1`; magic and `proto` match; `patchset` is in conf allow-list `wardrobe58_patchsets`; session state is `LEGACY`; character is in a normal in-zone state. Otherwise stay `LEGACY` and log once (rate limited). Never error out the session.
4. **Server ack** (server->client, placeholder `S2C_W58_ACK`): `magic`, `proto`, `granted_flags`. Sent only to a session that was granted. The patched client enables its 13-16 sidecar and UI only after receiving the ack; with no ack (vanilla server) it behaves exactly like the original client.
5. **Upgrade push.** After the ack the server sends the extended 0x1C (18-container layout; ID 17 sized 0) and item packets for containers 13-16 **only**. It does not resend 0-12.

## Server state
`map_session_data_t` gains `clientCaps` (`LEGACY` default, `EXTENDED`) plus a hello-seen counter. Rules:
- Lives with the session, so it dies with it (`delete map_session_data`). A new session, including after the player changes map server, starts `LEGACY`.
- Zoning on the same map server keeps `EXTENDED`, but the server re-sends the **legacy** zone-in packets (it does not know the client store was reset) and the client must re-hello; the server re-acks and re-pushes. Downgrade on any of: failed re-hello within N seconds, malformed hello, conf flag turned off, character logout.
- A session never goes `LEGACY -> EXTENDED` without passing step 3, and no code path sets it directly.
- Single accessor: `bool CCharEntity::extendedStorage()` / `session->clientCaps`, used by `IsValidContainerID(id, extended)` and every send path. Default-deny.

## Ingress and egress rules
- Every handler taking a container ID (0x029, 0x03A, 0x050, 0x1E/1F/20 builders, trade, delivery, Lua bindings) validates with `IsValidContainerID(id, session.extended)` before `getStorage`. Legacy: 0-12. Extended: 0-16. Always: reject >= 17.
- Every outbound item/capacity packet for container >= 13 goes through one chokepoint that drops it for `LEGACY` sessions.
- Lua-driven sends (`lua_baseentity.cpp` 0x1C push at ~7246) use the same chokepoint.
- Items in 13-16 for a legacy session are invisible, not removed: not tradeable, not equippable, not counted in `HasItem`-style client-visible views (decide per consumer; listed in `TEST_PLAN.md`).

## Packet ID selection (partly resolved)
**Update 2026-10-22 (`CLIENT_AUDIT_RESULTS.md`, Q1-Q5 done):** both directions must use IDs < 0x11F (client inbound table is 0x11F entries with an unchecked dispatcher; client `Begin()` refuses larger). Proposed: hello and ack both `0x103` (backup `0x10E`). The client has a real send path (ring of 0x110-byte slots, header `id | N<<9`), no per-packet crypto, so the hello is a normal packet. Hello is 20 bytes (N=5); DSP `PacketSize[0x103]=0x0A`. If the ring is full Begin returns NULL: the patch must retry later, never block. Server already drops outbound IDs >= 0x11F.

Original analysis:
Server's `PacketParser` table has 165 unregistered IDs in 0x00-0xFF and unregistered IDs fall to a default handler, so a free server ID is easy. The harder constraint is the client: the chosen ID must not be emitted/consumed by the 2019 client, and the patch needs a way to send a custom packet through the client's own send path. **Needs a Toolkit audit** (send-side builders, receive dispatch table bounds). If the client cannot be patched to send a packet safely, fallback is piggybacking the hello on an existing client packet's reserved bytes, which is worse (unmodified clients send those bytes) and would need a magic that cannot occur naturally.

## Tests
Offline (no server): hello parser rejects bad magic/proto/size/unknown patchset; state machine table test (every transition, default-deny, downgrade); packet builders: legacy 0x1C byte-identical to current output, extended layout correct, chokepoint drops 13-16 for legacy. Live (needs approval): unmodified client never receives 13-16 (capture); patched client vs vanilla server stays legacy; zone/relog/map-server-restart re-handshake; spoofed hello from a legacy client does not corrupt other sessions.

## Owner decisions (2026-10-22)
All three accepted: threat model = accidents, not adversaries; allow-list by patch-set ID; run the client audit first. Audit work order: `CLIENT_AUDIT_WORKORDER.md` (not yet run; needs the DLL).

## Open questions for the owner (answered above)
1. Accept the "accident, not adversary" threat model?
2. Allow-list by patch-set ID in conf (proposed), or a single boolean?
3. OK to spend a Toolkit research task on the client send-path/ID audit before implementing server code?

## Implementation notes (server side, 2026-10-22)
Files: `src/map/packets/w58_handshake.h` (pure logic), `w58_ack.{h,cpp}` (ack packet), `SmallPacket0x103` in `packet_system.cpp`, config in `map.cpp/map.h`, tests `tests/wardrobe5-8/handshake_test.cpp`.

**Config (map_darkstar.conf; defaults live in code, the tracked conf files are not edited):**
```
wardrobe58_enable:    0                      # default off. Handler is inert and silent when 0.
wardrobe58_patchsets: 0102030405060708,...   # comma-separated 16-hex-char patch-set IDs. Empty = nobody is upgraded.
```
**Deviation from the protocol text above:** the ack carries the Wardrobe 5-8 sizes and capacities itself (4 x u8 `1+size`, 4 x u16 `1+buff`) instead of the server sending a variant 0x1C. Reason: the 2019 0x1C handler copies exactly 13+13 entries; a second, differently shaped 0x1C would force the patched client to special-case a packet the original code already owns, and any stray one reaching an unpatched client is a hazard. The ack is new code on both ends. The legacy 0x1C is never altered.
**Decision order (`W58Decide`):** flag off -> not in zone -> throttle (8 per zone-in) -> length 20 -> magic -> proto 1 -> flags 0 -> patch-set on allow-list. Anything else is a refusal that keeps the session legacy; only the first refusal per zone-in is logged.
**Lifetime:** `CCharEntity::m_extendedStorage` is cleared at the start of every `SmallPacket0x00C` (zone-in), before any inventory push, and the hello counter is reset; a patched client must hello after each zone-in. The flag is set in exactly one place (the grant branch of `SmallPacket0x103`). A new login is a new character object, so it starts legacy.
**Grant action:** set flag, push ack, push item packets for containers 13-16 only, then `CInventoryFinishPacket`. The egress filter in `pushPacket` lets these through only because the flag is already set.
**Not implemented yet:** client-side hello/ack handling and sidecar (Milestone C); runtime downgrade if the conf flag changes without restart (flag is read at startup); equipment load for items worn from 13-16; trade/delivery/auction/shop/Lua paths for extended sessions.
