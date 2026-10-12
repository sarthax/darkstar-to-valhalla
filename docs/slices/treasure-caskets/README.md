# Treasure Caskets (feature/treasure-caskets)

Port of the LSB/Topaz Treasure Casket system (F-18 in the DSP-LSB gap audit).

## Design
- No C++. `onMobDeathEx` in `scripts/globals/mobs.lua` calls `caskets.spawnCasket` for the killer's death in any zone listed in `casket_zone_data`.
- Each zone has 16 `Treasure_Casket` NPCs (`npc_list`); the chest uses one as a pooled entity (model 965 unlocked/temp items, 966 locked/real items), despawns after 3 minutes, respawn check 5 minutes.
- Files: `scripts/globals/caskets.lua`, `casket_zone_data.lua` (base npc id, text ids), `casket_loot.lua` (Topaz loot tables), 60x `scripts/zones/<Zone>/npcs/Treasure_Casket.lua`.
- Setting: `CASKET_DROP_RATE` (default 0.1) in settings.lua.

## Provenance
Loot tables = Topaz `{weight, itemId}` tables, item ids validated. Text ids from client dialog.yml per zone. NPC ids are the client's own: every casket zone has 16 contiguous 'Treasure Casket' entities in the client zone data (mission_toolkit `entities` table), and the casket npcs MUST sit on those ids or the client shows another entity's name / makes the chest untargetable (first pass used collision-free ids and got this wrong in 37 of 60 zones). 56 existing DSP rows (Treasure_Coffer/Achieve_Master/Unity_Master/Mirror_Pond, junk `NPC[..]`/`blank` rows, a 12-row block in zone 190) sit on real casket ids; they are real or unknown DSP npcs at drifted ids, so they are LEFT ALONE and the casket slots at those ids are simply not wired (904 of 960 slots; the pool skips missing slots). Zones with fewer than 16: 102:15 103:15 105:13 111:12 112:13 115:12 116:12 125:14 126:12 153:14 158:15 166:15 167:15 172:13 173:14 190:4 204:15 208:9. Fixing the underlying npc_list id drift would be a separate slice. Removed/restored rows are listed in `removed_rows.sql`.
Topaz lists zone 207 (typo) - this port uses Garlaige Citadel (200).

## SQL
Reimport via `py -3 dbtool.py`, or run `sql/treasure_caskets.sql` directly in MariaDB, then restart map-server.

## Known limitations
- Only the party leader's party can open a chest.
- No ROE record 4019, no Super Kupowers/Evolith.

## Retest
Kill outdoor mobs -> chest appears, despawns at 3 min; locked chest lockpick minigame; temp-item and real-item loot; thief tool trade (1022); a new-block zone (e.g. Gusgen Mines); "<name> obtains..." message; chest visuals after re-entering range.
