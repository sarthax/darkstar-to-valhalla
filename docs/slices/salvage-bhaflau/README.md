# salvage-bhaflau

**Requires `salvage-base` (tag `slice/salvage-base-v1`)**: `scripts/globals/salvage.lua`, the gears/rampart mixins, pathos effect rows and the C++ dependency manifest live there. Independent of the other zone slices (cherry-picked onto the base, v2).

Ports the Bhaflau Remnants (Salvage I) build from Topaz into DSP. Instance id 68, zone 75.

## Contents
- `scripts/zones/Bhaflau_Remnants/`: IDs.lua (global `Bhaflau`, text ids verified by text against a fresh zone-75 dialog pull), Zone.lua, door_util.lua, instance script, ~27 mob scripts, ~40 npc scripts. Stale TextIDs.lua removed.
- `sql/slices/salvage-bhaflau/00..05`: build-only mob pools (6507, 6555, 6556), instance_list row 68, mob_groups (21 new at ids 31000+, 4 reused, scripted spawn), mob_spawn_points (232 updates, 11 inserts), 16 npc_list rows, 328 instance_entities (277 mobs + 51 npcs).
- Run order: Zhayolm and Silver Sea slices first, then 00..05 in order. All files are idempotent (DELETE then INSERT).

## Known gaps
- `Empathic_Flan.lua` NOT ported: it needs a TAKE_DAMAGE listener with damage and attack type, which DSP does not have. Those mobs spawn script-less, so the Dormant_Rampart reveal tied to Mad Bomber / Empathic Flan is only partly functional.
- `Archaic_Gear.lua`: TAKE_DAMAGE replaced with ATTACKED, which only fires on melee hits. Ranged/magic hits will not trigger it.
- Zero-position (0,0,0) placeholder mobs are not carried; the instance loader would never load them.
- Mobs whose live pool id is 0 are not carried.
- Dialog ids differ from Topaz; login-campaign ids dropped from IDs.lua.
