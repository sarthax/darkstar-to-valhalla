# Treasure Caskets (feature/treasure-caskets)

Port of the LSB/Topaz Treasure Casket system (F-18 in the DSP-LSB gap audit).

## Design
- No C++. `onMobDeathEx` in `scripts/globals/mobs.lua` calls `caskets.spawnCasket` for the killer's death in any zone listed in `casket_zone_data`.
- Each zone has 16 `Treasure_Casket` NPCs (`npc_list`); the chest uses one as a pooled entity (model 965 unlocked/temp items, 966 locked/real items), despawns after 3 minutes, respawn check 5 minutes.
- Files: `scripts/globals/caskets.lua`, `casket_zone_data.lua` (base npc id, text ids), `casket_loot.lua` (Topaz loot tables), 60x `scripts/zones/<Zone>/npcs/Treasure_Casket.lua`.
- Setting: `CASKET_DROP_RATE` (default 0.1) in settings.lua.

## Provenance
Loot tables = Topaz `{weight, itemId}` tables, item ids validated. Text ids from client dialog.yml per zone. NPC ids are the client's own: every casket zone has 16 contiguous 'Treasure Casket' entities in the client zone data (mission_toolkit `entities` table), and the casket npcs MUST sit on those ids or the client shows another entity's name / makes the chest untargetable (first pass used collision-free ids and got this wrong in 37 of 60 zones). On a base whose npc_list ids are not yet client-aligned (e.g. plain master-dsp), some casket slots in 190 and 208 (and the other drifted zones) are occupied by other npcs; `INSERT IGNORE` leaves those untouched, so those caskets are not wired and the pool skips them. The npc id alignment itself is NOT part of this slice (it is the separate npc-id-realign work). On the live server (client-aligned ids) 923 of 960 slots are wired. Zones with fewer than 16: 102:15 103:15 105:13 111:12 112:13 115:12 116:12 125:14 126:12 153:14 158:15 166:15 167:15 172:13 173:14 204:15. Fixing the underlying npc_list id drift in those zones would be a separate slice. Removed/restored rows are listed in `removed_rows.sql`.
Topaz lists zone 207 (typo) - this port uses Garlaige Citadel (200).

## SQL
Reimport via `py -3 dbtool.py`, or on an existing DB run `sql/slices/treasure-caskets/treasure_caskets.sql` directly in MariaDB, then restart map-server.

## Known limitations
- Only the party leader's party can open a chest.
- No ROE record 4019, no Super Kupowers/Evolith.

## Retest
Quicksand Caves weight doors (open/close with weight) and Antican tag/qm6 spawns; King Ranperre's Tomb Grounds_Tome, Treasure_Chest spawn, Pyxis; Kill outdoor mobs -> chest appears, despawns at 3 min; locked chest lockpick minigame; temp-item and real-item loot; thief tool trade (1022); a new-block zone (e.g. Gusgen Mines); "<name> obtains..." message; chest visuals after re-entering range.

## Zone-exclusive items (v7)
Each zone has a `regionalItems` list in `casket_loot.lua`; a locked-casket item roll has a 5% chance to become one of them. The wiki's "one exclusive per zone" is inconsistent with the item pages, so the list is the union of both: items can appear in several zones and zones can have several. Kept as-is (user-confirmed valid): 112 Negoroshiki, 157 Iron Ingot (Middle Delkfutt's Tower; Rebel Earring 11042 added there per BG-Wiki), 177 Dragon Ring, 184 Giant's Earring. Added: Negoroshiki in 125 (Western Altepa Desert), Dragon Ring in 172 (Zeruhn Mines) and 192 (Inner Horutoto Ruins). Slot bug fixed: the exclusive now replaces the rolled slot instead of always overwriting slot 1 (which left a slot empty).
