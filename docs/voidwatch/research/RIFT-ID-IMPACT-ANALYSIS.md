# Rift / Pyxis / Maw id impact analysis (2026-10-07)

Method: every zone with a Planar Rift, Riftworn Pyxis or Cavernous Maw in live `dspdb_fresh.npc_list` (81 zones) compared against a **fresh same-session client pull** (`mission_toolkit.py <zone>` -> `entities.yml`, the client's own entity table). Script: `rift_id_impact.py`; raw table: `rift_id_impact.csv`.
Offset = client targid - DSP targid (positive = DSP is lower than client).

**Warning:** `ffxi_zone_database.db`'s `entities` table is NOT usable for this (it is +1 vs the pulls in 101/104/193 and unrelated in 190). Only fresh pulls count.

## Result: 81 zones: 67 match, 12 shifted, 1 not pulled (127), 1 Maw-count only (137)

### Match (no action): 67 zones
All of 4 5 7 15 24 25 45 54 61 65 68 79 81 82 83 84 88 89 90 91 95 96 97 98 105 106 110 112 116 117 120 121 122 123 125 126 130 132 153 159 164 171 174 175 177 178 182 184 190 191 193 194 195 196 197 198 200 205 208 215 216 217 218 222 253 254 255. Rift/Pyxis/Maw ids that DSP has already equal the client's.

### Shifted: 12 zones (the whole list that needs correcting)
| Zone | Zone name | Rifts / Pyxis | Maw | Rows already at the target id (re-key collision) |
|---|---|---|---|---|
| 100 | West Ronfaure | +33 | none | none (free) |
| 101 | East Ronfaure | +2 | 0 | Geomantic_Reservoir at 669 |
| 102 | La Theine Plateau | -1 | -1 | Mog-Tablet at 682 |
| 103 | Valkurm Dunes | 0 | +2 (666->668) | `blank` at 668 |
| 104 | Jugner Forest | -9 | -11 / -9 | `blank` x5 (735,739-743), Carbuncle at 686 |
| 107 | South Gustaberg | +33 | +33 | `blank`, SlimeTarou, Orgis |
| 108 | Konschtat Highlands | -1 | -1 | Mog-Tablet at 594 |
| 109 | Pashhow Marshlands | +2 | 0 | Geomagnetic_Fount 695, Suspicioushume 696 |
| 111 | Beaucedine Glacier | +2 | none | Geomantic_Reservoir at 439 |
| 115 | West Sarutabaruta | +37 | +33 | SprigganCrier at 628 |
| 118 | Buburimu Peninsula | +2 | +2 | Survival_Guide 679, csnpc 669 |
| 119 | Meriphataud Mountains | +2 | 0 | Geomagnetic_Fount 679, Survival_Guide 680 |

(Offsets are in targid units, i.e. `npcid & 0xFFF`; the csv has the exact old->new targid lists per zone.)

### Other findings (not Rift id shifts)
- **Missing in DSP** (client has them, DSP npc_list does not): Pyxis in zones 83, 89, 195 (3 each); extra client Maws in 84 (2), 91 (1), 105 (3), 110 (1), 137 (1). Client "Cavernous Maw" entries beyond DSP's count may be other content; needs per-zone look before adding.
- **Zone 127**: pull failed/absent, not analyzed.
- Zone 102 flips from "match" under the drift DB to -1 under the pull; trust the pull.

## What a re-key would touch
- No Lua file in `scripts/zones/<zone>/` references the old full npc ids (grep of every shifted zone: none) — Rift/Pyxis scripts bind by **name**, so scripts are unaffected.
- Only `npc_list` rows change (and `npc_list.sql`). Rows needing to move out of the way (the collision column) are real objects in 101, 102, 104, 107, 108, 109, 111, 115, 118, 119 (Geomantic Reservoir/Fount, Mog-Tablet, Survival Guide, Carbuncle, etc.). Those are themselves almost certainly shifted the same way (the Jugner tail is +9 throughout), so re-keying must move the **whole tail of each zone**, not only Rift ids, to avoid creating duplicates.
- `blank` placeholder collisions (103, 104, 107) are free to overwrite.
- 100 and 107/115 are large offsets (+33/+37): likely rows are in a different block entirely, not a simple shift; verify against the client table row by row before touching.
- 190 and 193 (the Voidwatch slice zones: Ranperre, Ordelle's) match — no change needed for the current Krabimanjaro/Hahava work.

## Recommended order
1. Do nothing for the 67 matching zones.
2. Pick the zones in the slice: only 101 East Ronfaure and 104 Jugner (Voidwatch NMs planned) are in scope; both shifted.
3. For each, re-key the full tail from the client table on a copy of the DB first; test one Rift click in game against Valhalla for the reference behavior.
