# ID shift test checklist

Do these in order, from `D:\Claude\dsp-branches` only. Master list: `docs/ID_SHIFT_MASTER.csv`.

## 0. Before logging in
1. Confirm the live DB matches the files: `py -3 tools/check_npc_ids.py 127.0.0.1 root <pw> dspdb_fresh` must show 0 / 0 / 0 differences.
2. Restart the map server (a SQL change alone may not apply zone/entity data live).
3. Open the map-server log in a window and keep it visible. Any `GetNPCByID`, `GetMobByID`, "No Valid Function" or nil error during the steps below is a failure.

## 1. Shifted zones (name-verified moves)
Rows moved in each zone are in the master CSV (filter by zone id). In every zone: walk up to 3 of the moved npcs, check the nameplate, target and click each one, and watch the log.

| Zone | Shift | Check |
|------|-------|-------|
| 144 | +78 (29 rows) | Same pattern as 139/146. Click each moved npc; nameplates read correctly. |
| 179 | +12 (49 rows) | Largest block. Sample the first, middle and last moved rows. |
| 165 | +12 (7 rows) | Riko, Ayame and Volker mobs still spawn and are named correctly (mob/npc slot collision zone). |
| 291 | +1 (11 rows) | Click moved npcs; no wrong names. |
| 288 / 289 | +1 / -1 | One moved npc each. |
| 293 | +25 (14 rows) | Click moved npcs; no wrong names. |
| 106, 110, 117, 120, 243 | +2 | One moved npc each. |
| 245 | +1 | Both moved rows. |
| 230, 235 | -13 | One moved npc each (city zones; check shops work). |

## 2. Zones where Lua depends on ids (highest risk)
- **West Sarutabaruta, West Ronfaure signposts**: click conquest banners and signposts; the correct text appears.
- **West Sarutabaruta harvesting points**: harvest once.
- **Quicksand Caves**: stand on weight-sensor floor plates for doors 1, 3 and 5; the matching door opens.
- **King Ranperre's Tomb, Upper Delkfutt's Tower**: Zone.lua casket/tome ids; open a treasure chest and check the Grounds Tome.
- **La Theine Plateau**: Planar Rift and Riftworn Pyxis respond; Stachysaurus fight starts and drops.
- **Treasure caskets**: one casket in each of 3 zones is named Treasure_Casket (not Morbol Groupie) and opens.
- **Survival Guides**: North Gustaberg guide is visible and clickable; spot-check two more zones.

## 3. Mob realigns (28 rows)
Zones 139, 146, 148, 152, 163, 165, 168. Enter one battlefield or mission in at least 3 of them (for example 163 Shantotto, 146 Buu Xolo). Confirm the mobs spawn, have the right name, and the fight can be won.

## 4. Not shifted on purpose
Zones 20 (Promyvion-Mea), 69 (Leujaoam), 277 are unchanged. Confirm a Promyvion receptacle door and a Leujaoam Assault entry still work; this proves nothing broke there.

## 5. Record results
For each failure note zone, npc name, id (`!getid` or the log line). Anything wrong is reversible: each batch has a SQL file in `sql/` (`npc_id_realign_*.sql`, `mob_id_realign_apply.sql`).
