# salvage-arrapago

**Requires `salvage-base` (tag `slice/salvage-base-v1`)**: `scripts/globals/salvage.lua`, the gears/rampart mixins, pathos effect rows and the C++ dependency manifest live there. Independent of the other zone slices (cherry-picked onto the base, v2).

Ports the Arrapago Remnants (Salvage I) build from Topaz into DSP. Instance id 65, zone 74.

## Contents
- `scripts/zones/Arrapago_Remnants/`: IDs.lua rewritten (global `Arrapago`: text, mobs, npcs, points; text ids verified by text against a fresh zone-74 dialog pull, login-campaign ids dropped), Zone.lua (14 regions incl. telepad exits), instance script, 22 doors/npcs, mob scripts. Stale TextIDs.lua removed.
- `sql/slices/salvage-arrapago/00..06`: an exact copy of the live Topaz build for zone 74 / instance 65. 41 mob_pools (live pool P copied to id 74*10000+P, with mob_pool_mods), instance_list row, 64 mob_groups (ids 32000+, one per live group, repointed at the copied pools), 608 mob_spawn_points (every live row, 341 of them still at (0,0,0)), 37 npc_list rows (every live row), 298 instance_entities (identical to live), 123 mob_droplist rows (dropId 62000+live id).
- Apply order: salvage-base, then 00..05 here. Files are idempotent.

## Known gaps
- Weapon-break behaviour dropped: Topaz `weapon_break` and `families/qutrub` mixins depend on a CRITICAL_TAKE listener event that DSP never fires. Lamia/Merrow/Qutrub scripts no longer load them (cosmetic weapon-break animation only; the Qutrub mixin's swap logic was dead without it).
- `setSpeed` -> `speed` in Qiqirn_Treasure_Hunter.
- (0,0,0) mobs and pool-0 groups are carried as unfinished placeholders; the loader skips them until positioned / given a pool.
- The old DSP Arrapago npc rows not present in the build (ids 17080591, 17080958, 17080965..17080972) are left untouched.
