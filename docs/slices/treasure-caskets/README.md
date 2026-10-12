# Treasure Caskets (feature/treasure-caskets)

Port of the LSB/Topaz Treasure Casket system (F-18 in the DSP-LSB gap audit).

## Design
- No C++. `onMobDeathEx` in `scripts/globals/mobs.lua` calls `caskets.spawnCasket` for the killer's death in any zone listed in `casket_zone_data`.
- Each zone has 16 `Treasure_Casket` NPCs (`npc_list`); the chest uses one as a pooled entity (model 965 unlocked/temp items, 966 locked/real items), despawns after 3 minutes, respawn check 5 minutes.
- Files: `scripts/globals/caskets.lua`, `casket_zone_data.lua` (base npc id, text ids), `casket_loot.lua` (Topaz loot tables), 60x `scripts/zones/<Zone>/npcs/Treasure_Casket.lua`.
- Setting: `CASKET_DROP_RATE` (default 0.1) in settings.lua.

## Provenance
Loot tables = Topaz `{weight, itemId}` tables, item ids validated. Text ids from client dialog.yml per zone. NPC id blocks allocated per zone with collision checks against existing DSP npcs (27 zones got new blocks, 18 stray rows removed).
Topaz lists zone 207 (typo) - this port uses Garlaige Citadel (200).

## SQL
Reimport via `py -3 dbtool.py`, or run `sql/treasure_caskets.sql` directly in MariaDB, then restart map-server.

## Known limitations
- Only the party leader's party can open a chest.
- No ROE record 4019, no Super Kupowers/Evolith.

## Retest
Kill outdoor mobs -> chest appears, despawns at 3 min; locked chest lockpick minigame; temp-item and real-item loot; thief tool trade (1022); a new-block zone (e.g. Gusgen Mines); "<name> obtains..." message; chest visuals after re-entering range.
