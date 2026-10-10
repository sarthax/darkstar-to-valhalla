# salvage-arrapago

**Requires `salvage-base` (tag `slice/salvage-base-v1`)**: `scripts/globals/salvage.lua`, the gears/rampart mixins, pathos effect rows and the C++ dependency manifest live there. Independent of the other zone slices (cherry-picked onto the base, v2).

Ports the Arrapago Remnants (Salvage I) build from Topaz into DSP. Instance id 65, zone 74.

## Contents
- `scripts/zones/Arrapago_Remnants/`: IDs.lua rewritten (global `Arrapago`: text, mobs, npcs, points; text ids verified by text against a fresh zone-74 dialog pull, login-campaign ids dropped), Zone.lua (14 regions incl. telepad exits), instance script, 22 doors/npcs, mob scripts. Stale TextIDs.lua removed.
- `sql/slices/salvage-arrapago/00..05`: build-only pools (6507, 6533, 6555, 6556; these repeat earlier slices and are idempotent), instance_list row 65, mob_groups (24 new at ids 32000+, 4 reused, scripted spawn), mob_spawn_points (236 updates, 18 inserts), npc_list (6 rows), 282 instance_entities (254 mobs + 28 npcs).
- Apply order: salvage-base, then 00..05 here. Files are idempotent.

## Known gaps
- Weapon-break behaviour dropped: Topaz `weapon_break` and `families/qutrub` mixins depend on a CRITICAL_TAKE listener event that DSP never fires. Lamia/Merrow/Qutrub scripts no longer load them (cosmetic weapon-break animation only; the Qutrub mixin's swap logic was dead without it).
- `setSpeed` -> `speed` in Qiqirn_Treasure_Hunter.
- 13 mobs whose live pool id is 0 are not carried.
- Mobs at (0,0,0) are not carried (loader never loads them).
- The old DSP Arrapago npc rows not present in the build (ids 17080591, 17080958, 17080965..17080972) are left untouched.
