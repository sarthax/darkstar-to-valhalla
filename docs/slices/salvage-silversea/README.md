# salvage-silversea

**Requires `salvage-base` (tag `slice/salvage-base-v1`)**: `scripts/globals/salvage.lua`, the gears/rampart mixins, pathos effect rows and the C++ dependency manifest live there. Independent of the other zone slices (cherry-picked onto the base, v2).

Ports Silver Sea Remnants Salvage I (instance 71) from Topaz to DSP.lua`). Original work: valhalla branch `salvage-wip-2026-10-09`.

## Contents
- `scripts/zones/Silver_Sea_Remnants/` - `IDs.lua` (global `SilverSea`), `Zone.lua`, instance script, Armoury_Crate/Slot/Socket, 8 mob scripts. The stale DSP `TextIDs.lua` is removed.
- `sql/slices/salvage-silversea/00..06`: an exact copy of the live Topaz build for zone 76 / instance 71. 33 mob_pools (live pool P copied to id 76*10000+P, with mob_pool_mods), instance_list row, 58 mob_groups (ids 30000+, one per live group, repointed at the copied pools), 797 mob_spawn_points (every live row, 458 of them still at (0,0,0)), 51 npc_list rows (every live row), 848 instance_entities (identical to live), 28 mob_droplist rows (dropId 54000+live id).

## Decisions
- Text ids checked by TEXT against a fresh zone-76 dialog.yml pull. Topaz values 6383/6389/6390/6392/7213 were off; the login-campaign ids 7000-7002 were dropped (they do not match the client).
- Unlike Zhayolm, the build positions 110 spawn rows DSP does not have: 95 are inserted, the rest updated. Groups are matched by pool to existing DSP zone-76 groups; 7 new groups use reserved ids 30000+ (all other slices < 18500). New groups have dropid 0.
- 5 build-only pools (6507 Haunt_SSR, 6533 Doom_Mage_SSR, 6555/6556 Guard_Skeleton_SSR, 6722 Orobon_AR) are inserted into `mob_pools`; they do not exist in DSP.
- Spawn rows still at (0,0,0) and pool-0 groups are carried as unfinished placeholders; the loader skips them until positioned / given a pool.
- Long-Armed Chariot has two candidate ids (17088786 / 17089250); neither is confirmed, both listed.

## Known gaps
- 15 positioned mobs use live group pool 0 (Qiqirn x12, Apkallu Avenger, Seafarer Piliproon, Fomor Windwalker): no pool, so they are NOT carried and will not spawn.
- Only the entry, failure and exit mechanics exist; no floor/door progression (LSB has none; none invented).
- 4 Armoury Crate pool ids (17088820-17088823) and 2 Runic Lamps (17089356/7) are still unpositioned, so `spawnTempChest`'s pool loop does nothing beyond the fixed crate.
- Runic Lamps 17089354/5/67 are listed in IDs but may be Salvage II content.
- Slot position conflict (Slot vs Don Poroggo) unresolved.
