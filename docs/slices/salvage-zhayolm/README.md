# salvage-zhayolm

**Requires `salvage-base` (tag `slice/salvage-base-v1`)**: `scripts/globals/salvage.lua`, the gears/rampart mixins, pathos effect rows and the C++ dependency manifest live there. Independent of the other zone slices (cherry-picked onto the base, v2).

Ports Zhayolm Remnants Salvage I (instance 62) from the Topaz tree to DSP. Backup of the original work: valhalla branch `salvage-wip-2026-10-09`.

## Contents
- `scripts/zones/Zhayolm_Remnants/` - `IDs.lua` (global `Zhayolm`), `Zone.lua`, `zhayolm_util.lua`, `instances/zhayolm_remnants.lua`, 21 npc scripts, 33 mob scripts.
- `sql/slices/salvage-zhayolm/00..06`: an exact copy of the live Topaz build for zone 73 / instance 62. 40 mob_pools (live pool P copied to id 73*10000+P, with mob_pool_mods), instance_list row, 55 mob_groups (ids 29000+, one per live group, repointed at the copied pools), 679 mob_spawn_points (every live row, 391 of them still at (0,0,0)), 30 npc_list rows (every live row), 709 instance_entities (identical to live), 42 mob_droplist rows (dropId 50000+live id).

## Decisions
- Text ids were checked by text against a fresh dialog.yml pull of zone 73; several Topaz values were off (e.g. 6383/6389/6390/6392, CELL_OFFSET 7213).
- DSP's `instance_list` has no `instance_zone` column; row rewritten in the 12-column form.
- Live pools/groups/droplists are copied to separate ids (pools 730000+, groups 29000+, drops 50000+); stock DSP rows are untouched.
- Armoury_Crate: client entity pull lists a block of crates 17076579-17076588+, so both ids are real. Build uses 17076579 (matches `IDs.lua`); DSP's 17076584 row is replaced.

## Known gaps
- Spawn rows still at (0,0,0) are carried as unfinished placeholders; the loader skips them until positioned.
- Poroggo Gent: only 24 Topaz ids exist; LSB north path 3 needs ids 25-36. Not invented.
- Existing `TextIDs.lua` in the zone folder is stale and unused.
- Topaz `IDs.lua` text ids 7000-7002 do not match the client.
- Arrapago/Bhaflau/Silver Sea must define globals `Arrapago`/`Bhaflau`/`SilverSea` (only `Arrapago` exists) before their cells work.
