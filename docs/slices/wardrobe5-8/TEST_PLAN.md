# Test plan - wardrobe5-8 V1
Order: offline unit -> local build -> isolated DB fixtures -> XIHeadless -> supervised real-client. Gates marked **[OWNER]** need explicit approval first. Evidence must be server-authoritative (DB rows, server logs), not client acks.

## 0. Preflight (read-only)
- [ ] Clean worktree; `main` and deployed revision match or mismatch recorded.
- [ ] Hash original, installed and staged DLLs against `MANIFEST.md`; confirm original restored after Stage 3.
- [ ] Baseline on unmodified build: inventory, equip, zone, relog, persistence. Record results.

## 1. Offline unit tests (no server, no DB)
- [x] Container ID table: legacy 0-12 unchanged; 13-16 valid only for extended sessions; >=17 rejected (`tests/wardrobe5-8/container_ids_test.cpp`, passing 2026-10-22; table only, not yet wired into each handler).
- [x] (partial) container guards in 0x028/0x029/0x03A/0x050/0x0FA/0x0FB and the egress chokepoint (`inventory_guard_test.cpp`, passing). Remaining handlers listed in README.
- [ ] `getStorage()` never returns null to a caller that dereferences it (0x029, 0x03A, 0x050, 0x1E/1F/20 builders, Lua bindings).
- [ ] 0x1C builder: legacy = byte-identical to current output; extended = 18-container layout; unknown caps = legacy.
- [x] (offline, logic only) Capability decision table: disabled/not-in-zone/throttled/bad length/magic/proto/flags/unknown or empty allow-list all refuse; one wrong patch-set byte refuses; ack bytes and header (`tests/wardrobe5-8/handshake_test.cpp`, passing).
- [ ] Capability end to end: default LEGACY; spoofed/malformed handshake stays LEGACY; reset on zone/relog/session end (needs a running server).
- [ ] Malformed requests (bad container/slot/quantity) fail safely without state change.
- [ ] Migration SQL passes `tools/sqlcheck.py`; `up.sql` then `down.sql` restores schema on a scratch DB.

## 2. Local build **(no deploy)**
- [ ] Map server builds (VS2019 toolset / Makefile) with feature off and on.
- [ ] Client patch tool: given a fake input, refuses wrong SHA-256; output deterministic.

## 3. Disposable-DB integration **[OWNER] for any shared test DB**
- [ ] Wardrobes 1-4 and inventory unchanged (move, equip, sort, trade).
- [ ] Wardrobes 5-8: capacity, add/move/equip/unequip, sort, trade/delivery restrictions.
- [ ] Persistence across zone, logout/login, map-server restart.
- [ ] Two characters + store-instance reset: no cross-contamination.
- [ ] Rollback: `down.sql` + feature off -> original behavior, no items lost (13-16 rows preserved or exported).

## 4. Client acceptance **[OWNER]** (modified DLL install, extended packets)
- [ ] Unmodified 2019 client: only 13-container layout ever sent (packet capture/log).
- [ ] Modified client: boot, connect, all menus, `/wardrobe5`..`/wardrobe8`, capacity display, item moves, equip, zone, relog, long-run stability, clean exit (teardown).
- [ ] Rollback: restore original DLL by hash; session works with items intact.

## 5. Sign-off
Outstanding defects, exact server and client hashes, evidence bundle, proposed tag `slice/wardrobe5-8-v1` (not created until owner approves).
