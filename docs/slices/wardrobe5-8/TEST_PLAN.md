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

## 6. Server path acceptance (added 2026-10-22; all need a running server + disposable characters, owner approval for the DB)
- [ ] Grant capacity via SQL/Lua to a disposable char; patched or XIHeadless-extended session: Wardrobe 5-8 show capacity; legacy session: nothing about 13-16 on the wire (capture).
- [ ] Move item inventory <-> Wardrobe 5; stack split/merge; sort; persistence across zone, relog, map-server restart.
- [ ] Equip from Wardrobe 5, zone, relog: gear still worn server-side; legacy client sees no 0x50 for it; after hello it does.
- [ ] Rare item sitting in Wardrobe 5: AH purchase of the same item is refused; `HasItem`-based quest checks see it.
- [ ] Use item from container 13+ as a legacy session is ignored (0x037); container >= 17 in 0x028/0x029/0x037/0x03A/0x050/0x0FA/0x0FB does not crash.
- [ ] Trade/delivery/AH/shop cannot reach items in 13-16 (they must be moved to inventory first).
- [ ] Migration on a COPY of the test DB: fresh up, up again, down (no live rows in container >= 13 in char_inventory or char_equip), up again restores items, gear and capacities. (Done on a scratch DB with synthetic rows 2026-10-22.)

## 7. Edge cases (added 2026-10-22; live, disposable characters)
- [ ] Charged item (e.g. a ring with uses) worn from Wardrobe 5: equip, use, zone, relog; note whether the recast refresh targets the right slot (known weak spot, same for Wardrobes 1-4).
- [ ] Ammo worn from Wardrobe 5: swing/shoot until empty; auto-unequip and DB row cleanup are correct.
- [ ] Latent/set-bonus gear worn from Wardrobe 5 gives the same stats as the same gear from Wardrobe 1 (compare `!`-style stat dumps).
- [ ] Equip set (0x051) with pieces from Wardrobes 1 and 5 on an extended session; the same set on a legacy session equips only legal pieces; a crafted 0x051 with count 255 reads no more than 16 entries.
- [ ] Capacity shrink below occupied: items missing at login, gear unequipped, DB rows intact; restoring capacity brings them back.
- [ ] Hello storm (> 8 in one zone-in) and replay; hello during zoning; relog and map-server change start legacy.
- [ ] `!delitem` removes an item from Wardrobe 6; Rare item in Wardrobe 7 blocks AH/treasure/trade receipt.
- [ ] Style lock using an appearance item stored only in Wardrobe 6: lock, zone, relog, delete the item -> style drops; crafted 0x053 with count 255 / equip slot 255 changes nothing outside `styleItems`.
- [ ] Equip set containing Wardrobe 5 pieces saved on a patched client, then the ORIGINAL DLL restored: confirm what the original client does with the stored set (client audit item; do not run on a live character).
