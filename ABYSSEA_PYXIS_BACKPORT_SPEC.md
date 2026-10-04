# Abyssea Sturdy Pyxis backport — Phases 1–3 (LSB → DSP)

Status 2026-10-02: code written and Lua syntax-checked. **Not built or tested in-game.**

## What is in
- `scripts/globals/abyssea_pyxis.lua` — spawn, blue chest (higher/lower), red chest (air pressure), gold chest (two-digit guess with hunches), Forbidden Key trade. Rewards: light, restore (HP/MP/TP/recast), cruor, experience, temp items, numerous temps, items, pop items.
- `scripts/globals/abyssea_pyxis_drops.lua` — generated drop tables (temp / item / pop item / deduct), from LSB.
- Phase 3: gold-chest augmented items (1–2 per chest, tier-scaled augment pool) and key items (big gold chest only; Konschtat/Tahrongi/La Theine/Attohwa/Misareaux/Vunkerl). Data in `scripts/globals/abyssea_pyxis_augs.lua` (generated; item and key item ids resolved by name against DSP `item_basic.sql` / `keyitems.lua`; all augment ids exist in DSP `augments.sql`).
- C++: `addItem` now applies augments to weapons too (was armor-only; 11 of the 27 augment items are weapons). **Needs the same rebuild.**
- Unlocked-chest event (2067+tier): contents list via `onPyxisEventUpdate`; option low word 65 = take slot (high word), slot 9 = send to treasure pool, 66 = leave.
- `scripts/zones/Abyssea-<Zone>/npcs/Sturdy_Pyxis.lua` ×9 (name drives script lookup; onEventUpdate now calls `onPyxisEventUpdate`).
- `scripts/globals/mobs.lua` — `onMobDeathEx` calls `spawnPyxis` for the killer on non-NM kills in Abyssea.
- C++: `CLuaBaseEntity::setNpcFlags` (lua_baseentity.h/.cpp). **Requires map-server rebuild** (together with the Lights C++ changes).

- Phase 4: Time Extension (blue chest, tier 4+, content message 17 = 0x0150000; +10 min on each alliance member's Visitant via `setDuration`/`resetStartTime`/`setIcon`; message 7326, 7226 in Attohwa/Uleguerand, verified by text in all 9 zones). Abyssite perks read from the killer's key items: acumen 1409-1411 (blue, fewer answers), kismet 1400-1402 (blue +tier), prosperity 1403-1405 (red +tier), destiny 1406-1408 (gold +tier), tier capped at 5.

## ID sources
- Pyxis npc ids: `sql/npc_list.sql` rows named `Sturdy_Pyxis` (blocks of 80 per zone). No SQL changes needed.
- Message ids: client `dialog.yml` pulls, identical across zones except Attohwa/Uleguerand (−100). Kept in the module, not TextIDs.lua (which is +2 off).
- Events: locked 2003+tier, unlocked 2067+tier.

## Known limits / deferred
- Key items for Altepa/Uleguerand/Grauberg: LSB has none (TODO there), so no KI drop in those zones.
- Key item message ids 7487/7490/7492 (-100 Attohwa/Uleguerand) verified by text; KI ids come from DSP keyitems.lua, not independently checked against the client.
- Restore feedback uses basic message ids 24/25/26/361 (LSB `msg.lua`; DSP's header lacks these names, but DSP's 102 matches LSB's, so the client table lines up). Not confirmed in-game.
- Pets don't spawn chests (`OnMobDeath` only dispatches CCharEntity kills). Not changed: needs a C++ change plus testing of how DSP credits pet kills.
- Pop items only exist for Konschtat.
- Unverified guesses to check in-game: the unlocked-event argument layout and the 65/66 option decoding, which came from the LSB reference.

## Test steps
1. Rebuild map server. 2. In Abyssea (Visitant), `!addlights` pearl high to raise spawn odds, kill non-NM mobs. 3. Open by trigger or trade Forbidden Key (2490). 4. Blue/red/gold: solve, then check the unlocked menu (take, treasure pool, leave). 5. Verify rewards land and the chest despawns and can respawn.
