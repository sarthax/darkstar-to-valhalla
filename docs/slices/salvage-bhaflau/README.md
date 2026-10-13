# salvage-bhaflau

**Requires `salvage-base` (tag `slice/salvage-base-v1`)**: `scripts/globals/salvage.lua`, the gears/rampart mixins, pathos effect rows and the C++ dependency manifest live there. Independent of the other zone slices (cherry-picked onto the base, v2).

Ports the Bhaflau Remnants (Salvage I) build from Topaz into DSP. Instance id 68, zone 75.

## Contents
- `scripts/zones/Bhaflau_Remnants/`: IDs.lua (global `Bhaflau`, text ids verified by text against a fresh zone-75 dialog pull), Zone.lua, door_util.lua, instance script, ~27 mob scripts, ~40 npc scripts. Stale TextIDs.lua removed.
- `sql/slices/salvage-bhaflau/00..06`: an exact copy of the live Topaz build for zone 75 / instance 68. 38 mob_pools (live pool P copied to id 75*10000+P, with mob_pool_mods), instance_list row, 60 mob_groups (ids 31000+, one per live group, repointed at the copied pools), 423 mob_spawn_points (every live row, 146 of them still at (0,0,0)), 60 npc_list rows (every live row), 334 instance_entities (identical to live), 88 mob_droplist rows (dropId 58000+live id).
- Run order: `00..06` in numeric order (06 after 02). All files are idempotent (DELETE then INSERT). Stock DSP pools, groups and droplists are never overwritten; this slice uses its own id ranges.

## Known gaps
- `Empathic_Flan.lua` NOT ported: it needs a TAKE_DAMAGE listener with damage and attack type, which DSP does not have. Those mobs spawn script-less, so the Dormant_Rampart reveal tied to Mad Bomber / Empathic Flan is only partly functional.
- `Archaic_Gear.lua`: TAKE_DAMAGE replaced with ATTACKED, which only fires on melee hits. Ranged/magic hits will not trigger it.
- (0,0,0) mobs and mobs in pool-0 groups are carried as unfinished placeholders. `instance_loader.cpp` skips (0,0,0) rows and poolid 0 groups, so they do not spawn until given a real position / pool. They are not invalid.
- Dialog ids differ from Topaz; login-campaign ids dropped from IDs.lua.
