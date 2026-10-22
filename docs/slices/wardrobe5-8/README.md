# Mog Wardrobes 5-8 (December 2019 client) - V1

**Status (2026-10-22): PLANNING. Nothing is implemented. Wardrobes 5-8 are NOT implemented until the complete feature passes real client/server acceptance (see `TEST_PLAN.md`).**

Branch of record: `feature/wardrobe5-8-v1` (cut from `main` @ `86d4467`). One cohesive feature: server C++/Lua/SQL, packet compatibility, client patch tooling, UI support, migration/rollback, docs and tests. It is not released or merged in pieces. Subordinate task branches (`codex/<issue>-<name>`) may feed it; the local integrator assembles reviewed work here. Owner personally approves integration and any live rollout.

## Source research (Toolkit, `sarthax/FFXI-Mission-Toolkit`)
Branch `research/2019-wardrobe-backport-gates-20261021` (PRs #1312 audit, #1303 POL1 repacking). Not merged to Toolkit `main`. Reports: `docs/reports/ffximain_2019_wardrobe_backport_stage4.md`, `wardrobe_2019_toolkit_research_closeout_handoff.md`, `wardrobe_2019_dsp_transition_readiness_2026-10-21.md`. Reusable binary tooling stays in Toolkit; only decisions, evidence references and implementation-relevant code/tests move here.

Original client gate: `FFXiMain.dll` 2,870,352 bytes, SHA-256 `514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f`; POL1-decoded `.text` SHA-256 `af2126c057d86559bfad2e164f7f7fd0a26bbc89ab29ea9cbde5cea807c7d2b8`. No retail or modified DLL is ever committed.

## Current DSP state (audited 2026-10-22, read-only)
- `src/map/item_container.h`: `CONTAINER_ID` 0-12 (`LOC_WARDROBE`=8, `LOC_MOGSAFE2`=9, `LOC_WARDROBE2/3/4`=10/11/12); `MAX_CONTAINER_ID` 13; `MAX_CONTAINER_SIZE` 120. This matches the 2019 client's 13 containers and its mode numbering (9 is Mog Safe 2 / `/bank2`).
- `charentity.cpp`: one `unique_ptr<CItemContainer>` per container; `getStorage()` is a switch that returns null for unknown IDs.
- Persistence: `char_inventory(charid, location tinyint, slot, itemId, quantity, bazaar, signature, extra)`, PK (charid, location, slot) - new locations need no column change; capacities live in `char_storage` (`wardrobe`..`wardrobe4`, default 80).
- `packets/inventory_size.cpp` (0x1C): 13 u8 sizes at +0x04, 13 u16 buffs at +0x14, size 0x1A. Matches the 2019 layout. A newer-client 18-container layout must never go to the 2019 client.
- Hard-coded wardrobe lists to extend or guard: `SmallPacket0x050` (equip), `charutils.cpp` login container push, `charutils.cpp` equip/save paths, `lua_baseentity.cpp` (`MAX_CONTAINER_ID` loops), `scripts/globals/status.lua`.
- Login version lock (`src/login/lobby.cpp`, `CLIENT_VER`) compares only the version string. A modified DLL reports the same string, so **it cannot serve as the extended-capability indicator**.
- No existing work implements any part of Wardrobes 5-8 (grep of src, scripts, sql, docs; no related branch, tag or PR).

## Dependencies and conflicts
- PR #51 (`fix/inventory-sort-invalid-container-20261018`, draft, open): validates container ID and null storage in packet 0x03A. Touches `packet_system.cpp`. Not built or runtime-tested. V1 must include it (merge the branch into the feature, merge-commit style) or have it land first - owner decides. Also need the same audit for 0x1E/0x1F/0x20 and every `getStorage()` caller.
- PR #54 merged; #57 is docs only. No other PR touches inventory.

## Architecture (proposed; subject to review)
**Storage.** IDs 13-16 = Wardrobe 5-8 (matches newer clients; ID 17 out of scope). Add `LOC_WARDROBE5..8`, `MAX_CONTAINER_ID_LEGACY` (13) and `MAX_CONTAINER_ID_EXTENDED` (17); keep legacy loops on the legacy constant so existing behavior is unchanged. `getStorage()` takes only IDs valid for the session. Capacity columns `wardrobe5..8` added to `char_storage` by reversible migration; `char_inventory` needs no change. Equipment from wardrobes 5-8 is allowed only for extended sessions.

**Protocol.** Per-session `clientCaps` on `map_session_data_t`, default `LEGACY`. Legacy sessions see only containers 0-12 in 0x1C, login item push, 0x1D/0x1E/0x1F/0x20 and Lua-driven item messages; items stored in 13-16 stay on the server and are invisible, not lost. Extended mode needs an independently verified signal from the patched client: see `HANDSHAKE_DESIGN.md` (proposal awaiting owner review; the login version string is insufficient). Unknown or unverified clients get legacy. Experimental packet code is gated by a conf flag, default off. Reviewed ingress/egress bounds for every container-ID field.

**Client (modified 2019 DLL).** Patch definitions and tooling in source control only (`tools/client_patch/wardrobe5-8/`, to be created); no binaries. Needs: per-store sidecar (4 x 81 x 44 = 14,256 bytes per store; legacy array ends at active-store +0x14D5C, immediately followed by the enumeration cursor, so it cannot be extended in place), manager switching/reset/teardown, `containerID < 13` guards (3 observed), 0x1C parse (13 u8 + 13 u16 -> extended), 0x1E/1F/20 bounds, four new slash commands plus mode objects (new modes 13-16; never reuse 9), the `mode-2` selector (2-12 today), and update/cleanup for the 13 UI-global objects at `0x10621FBC..0x10621FEC`. EVB file transfers (`0x3B080` bytes) must not be resized; whether they matter to server persistence is UNKNOWN. Gated on the exact SHA-256 above.

## Milestones
| # | Milestone | Status |
|---|---|---|
| 0 | Preflight, research import, branch and tracking docs | in progress |
| A | Server storage + persistence + migration up/down | in progress: containers 13-16, capacity load/save, `sql/slices/wardrobe5-8/up.sql`+`down.sql` done; syntax-checked and migration round-trip tested on a scratch MariaDB only. Not yet: item-move/sort/equip paths, unit tests, full build |
| B | Legacy/extended packet handling, capability handshake, bounds review | not started |
| C | Client patch design + tooling (offline) | design written (`CLIENT_PATCH_DESIGN.md`), owner decisions pending; no code |
| D | Offline unit tests, then XIHeadless and live acceptance | not started |
| E | Owner review and approval request | not started |

## Known gaps
Server build/test baseline not yet run in this environment; deployed revision, MariaDB schema revision, client install state, and Stage 3 DLL restoration are unverified (need the owner's local machine). See `MANIFEST.md`.

## Milestone A notes (2026-10-22)
- `MAX_CONTAINER_ID` stays 13 on purpose: every existing guard and loop (0x029, Lua bindings, HasItem, augment pass) keeps legacy behavior. `MAX_CONTAINER_ID_EXTENDED` (17) is used only by `getStorage()` and the inventory load guard. Because `getStorage(13..16)` now returns a container instead of null, **PR #51's 0x03A check on `>= MAX_CONTAINER_ID` is what keeps a legacy client from sorting 13-16**; this feature must include it (or equivalent) before extended packets exist.
- Capacities for Wardrobes 5-8 are loaded/saved by separate statements so an unmigrated schema leaves the legacy path unchanged. Default capacity 0.
- Item rows in unknown containers (>= 17) are skipped with a warning at load instead of dereferencing null.
- `down.sql` parks items in `char_inventory_w58_backup` and capacities in `char_storage_w58_backup`; `up.sql` restores both. Verified on a scratch DB (not the test DB): up twice (idempotent), down, up restores items and capacity.
- Not yet done: sorting, equip (0x050 still legacy-only), trade/delivery restrictions, Lua exposure, extended 0x1C and item packets, capability handshake.
- PR #51 (0x03A validation) is merged into this branch by merge commit, so a legacy client cannot sort containers 13-16. If #51 later lands on `main` first, merging `main` here is a no-op for that hunk.
- `IsValidContainerID(id, extendedSession)` added in `item_container.h`; first offline test: `tests/wardrobe5-8/container_ids_test.cpp` (passes: legacy IDs 0-12 fixed, 13-16 extended-only, >=17 never valid).
- Client audit for the handshake: work order `CLIENT_AUDIT_WORKORDER.md`; inbound-registration scanner `tools/client_patch/wardrobe5-8/audit_inbound_registrations.py` (synthetic tests pass, never run on the real DLL). Server handshake code is blocked on its results.

## Server validation (Milestone A/B, 2026-10-22)
- `CCharEntity::m_extendedStorage` (default false; nothing sets it yet - only the verified handshake may). Ingress uses `IsValidContainerID` / `IsEquippableContainer`.
- Handlers now validating container IDs: 0x028 (drop), 0x029 (move), 0x03A (sort), 0x050 (equip), 0x0FA, 0x0FB. 0x028, 0x0FA, 0x0FB had **no** guard before: ID >= 13 returned a null `getStorage()` and was dereferenced (existing bug, closed here). 0x0FD/0x0FE/0x0FF already restrict to Mog Safe / Mog Safe 2.
- Egress: `CCharEntity::pushPacket` drops item packets 0x1E/0x1F/0x20 whose container is invalid for the session (`packets/inventory_guard.h`), with a warning. 0x1C remains the legacy 13-container builder.
- Tests: `tests/wardrobe5-8/inventory_guard_test.cpp` links the real 0x1E builder; guard truth table over all 256 IDs and the equip table pass.
- Not yet covered: trade (0x033/0x034), delivery box (0x04D), auction, shop, Lua bindings that take a container, equipment load at login for 13-16, `HasItem`-style helpers, `SendInventory` for extended sessions, sorting order. Each needs a read-through before extended mode can be enabled.
- **Client audit Q1 done** (`CLIENT_AUDIT_RESULTS.md`): inbound table = 0x11F entries, dispatcher unchecked -> server drops outbound IDs >= 0x11F; provisional ack ID 0x100. Outgoing-path questions Q2-Q6 still open and gate the handshake implementation.
- **Client audit Q2-Q5 done (static)**: client has a real, lock-free send path (ring slots + `Begin()`), no per-packet crypto; hello/ack proposed as `0x103` both ways. Provisional GO for the handshake design; open items (6 dynamic Begin sites, code space for the patch, same-thread confirmation) listed in `CLIENT_AUDIT_RESULTS.md`. Nothing executed against a client.
- **Server-side handshake implemented** (offline-tested; not built/run): `HANDSHAKE_DESIGN.md` "Implementation notes". Off by default (`wardrobe58_enable: 0`). Deviation: ack carries capacities instead of an extended 0x1C. Next: remaining ingress paths (trade/delivery/auction/shop/Lua) and the client patch design.

## Server path audit (2026-10-22) - every container consumer in `src/map`
Method: grep of all `getStorage(`, `MAX_CONTAINER_ID`, `char_inventory`/`char_equip` uses and every outbound packet builder that carries a container ID. Offline only (syntax-checked, unit-tested, scratch-DB migration); nothing built or run as a server.

| Path | Result |
|---|---|
| Client-supplied container, validated against the session (`IsValidContainerID`) | 0x028 drop, 0x029 move, 0x037 use item (**was unguarded**), 0x03A sort, 0x050 equip (`IsEquippableContainer`), 0x0FA, 0x0FB (**were unguarded**). 0x0FC-0x0FF already restrict to Mog Safe 1/2 |
| Ownership scans: extended range, independent of client version (a Rare item in Wardrobe 5 still counts) | AH Rare check (0x04E), `charutils::HasItem`, Lua `checkImbuedItems`, login augment pass |
| Central helpers: null-safe for any container >= 17 | `AddItem`, `MoveItem`, `UpdateItem`, `EquipItem`, `EquipArmor`, `CItemState` ctor |
| Inventory-only by construction (items in 13-16 cannot be traded, sold, delivered or auctioned until moved to the inventory) | trade 0x033/0x034/0x036, delivery 0x04D, AH 0x04E, shop 0x083-0x085 all address `LOC_INVENTORY` only |
| Sorting | 0x03A works on any container via the container's own ID; DB update is generic |
| Egress (legacy client withheld from containers >= 13 and from IDs >= 0x11F) | item packets 0x1E/0x1F/0x20, equip 0x50, furniture 0xFA, in `CCharEntity::pushPacket` |
| Worn gear from 13-16 | `LoadEquip` restores it server-side (items load first). A legacy session never hears about it (0x50/0x1F dropped). After the handshake the server re-sends equip + lock packets for those slots. Rollback: `down.sql` parks `char_equip` rows with container 13-16 as well (an old binary would crash on them) |
| Capacity grant | Lua `changeContainerSize(13..16, n)` now allowed (scripts only; max 80 via `AddBuff`) and refreshes the capacity for extended sessions. No GM command added; for a disposable test character: `UPDATE char_storage SET wardrobe5=80 WHERE charid=...` |
| Zone-in | flag cleared at the top of `SmallPacket0x00A` (with `clearPacketList`) and again in 0x00C; `SendInventory` stays the legacy 13-container list |

**Deliberately unchanged (legacy scope):** Lua `hasItem(id, loc)`, `delItem(id, qty, loc)`, `getFreeSlotCount(loc)` still clamp to 0-12, so scripts cannot address 13-16 by location (a plain `hasItem(id)` covers everything).
**Not verified / open:** `latent_effect_container` and similar code was checked only for literal container uses, not by running; equip-dependent features (latents, set bonuses) for gear worn from 13-16 are untested; behavior under a real server, real DB and real client is untested; no GM command to grant capacity.

## Edge cases and latents (2026-10-22) - read-through of the code, nothing executed
| Case | Finding |
|---|---|
| Latent effects, gear sets, ammo swings, charged gear | Container-agnostic. `latent_effect_container.cpp` has no live container reference (the `getStorage` lines are commented out); everything reads gear through `getEquip()`/`equipLoc`. Ammo use and the auto-unequip when ammo runs out use `equipLoc`/`UpdateItem`, so they work from containers 13-16 unchanged |
| **Equip-set packet 0x051** | **Fixed.** Had its own hard-coded five-container list, so extended sessions could never equip a set from Wardrobes 5-8; now `IsEquippableContainer`. Also **existing bug fixed**: the loop ran to a client-supplied count (up to 255) over a fixed 72-byte packet; now clamped to 16 entries |
| Rare items | One source of truth: `HasItem` (now 0-16) is what `AddItem`, trade, treasure pool and the AH use. A Rare item in Wardrobe 5 blocks every way of receiving another |
| GM tooling | `!delitem` stopped at Wardrobe 4 (would say "does not have item" for an owned item); now to Wardrobe 8. `LOC_WARDROBE5-8` added to `status.lua`. Lua `hasItem`/`delItem`/`getFreeSlotsCount` location args widened to 0-16 (server scripts only); `getItem`, `equipItem`, `getContainerSize` bindings no longer crash on a bad container |
| Legacy session + gear worn from 13-16 (e.g. earlier patched session) | Withheld from the wire (0x50/0x1F dropped). If the player equips over that slot, the server unequips the old item normally; its unlock packet is dropped too. After a hello, the worn slots are re-announced |
| Stale flag across threads | `m_extendedStorage` is now `std::atomic<bool>`: `pushPacket` runs on other threads than the zone-in reset |
| Handshake abuse | Hello storm: 8 per zone-in then ignored. Replay: idempotent (re-ack, re-push). Hello while zoning: harmless, next `0x00A` clears the flag. Map-server change or relog: new character object, starts legacy. Same-zone teleports do not re-zone the client, so the flag correctly persists |
| Capacity set back to 0 while items remain | `CItemContainer::InsertItem(item, slot)` **deletes the in-memory item** when `slot > size`. DB rows survive, so nothing is lost permanently, but at login those items do not load, and gear worn from there is not re-equipped; the next `SaveCharEquip` writes that slot as empty. **Pre-existing behavior for Wardrobes 1-4.** Consider refusing capacity decreases below the occupied count (not done) |
| Item recasts (charged gear) | **Pre-existing**: `RECAST_ITEM` is keyed by slot number alone and refreshed against `LOC_INVENTORY`, so a charged item in any wardrobe can refresh the wrong inventory slot. Wardrobes 5-8 inherit this; not changed |
| Item-type rules | Pre-existing parity: the server does not restrict wardrobes to equipment (the client UI does); Wardrobes 5-8 behave the same |
| Macro equip-set reply (0x116) | Echoes client-supplied bytes; ID 0x116 is < 0x11F; not server-derived, so no new hazard |
| New characters / schema | `char_storage` defaults for Wardrobes 5-8 are 0; before the migration is applied the extra columns are simply not read |
| Bazaar, synthesis, shop, trade, delivery, AH | Inventory-only; no change needed |

### Macros (equip sets) and style lock (2026-10-22)
| Feature | Verdict |
|---|---|
| Using an equip set (0x051) | Works for Wardrobes 5-8 on **extended** sessions; a legacy session only equips legal pieces (container list is per session). Count clamped to 16 |
| Saving an equip set (0x052) | The server only echoes the client's own bytes back as 0x116 and never stores sets. Reads stay inside the 76-byte packet. No server issue; sets live on the client |
| Style lock (0x053) | Style is by **item ID**; the packet's container byte is ignored; the client's lock-style-from-set reuses the `es*.dat` records (no separate file). Validity needs `HasItem(appearance item)`, which now counts containers 0-16, so an appearance item sitting in Wardrobe 5-8 stays valid. (Before the `HasItem` widening it would have been dropped.) Deleting the last copy still un-styles correctly |
| Existing bug fixed in 0x053 | The type-3 loop wrote `styleItems[equipSlotId]` (array of 16) with a client-supplied slot up to 255, and ran to a client-supplied count; now clamped to 16 entries and slot < 16 |
| **Client-side risk (audited, partly resolved)** | Equip sets live in `es0.dat`-`es4.dat` (see `CLIENT_AUDIT_RESULTS.md`, "Equipment sets"). The original client's apply path filters containers to {0,8,10,11,12} and bounds the re-resolve to < 13, so entries naming 13-16 are dropped, not dereferenced. Not every UI path is traced. Style lock needs no storage of its own: it reuses the same `es*.dat` records on the client and persists item IDs only (`char_style`) on the server, so rollback keeps the precaution of backing up and restoring `es*.dat`. The patched client must extend the set module (patch sites listed) or sets with Wardrobe 5-8 pieces will not equip |
