# npc-id-realign

Moves npc_list ids onto the ids the client DAT uses (id = 0x01000000 + (zone<<12) + slot), so server entities line up with client entities.

- 719 npc ids moved: 647 ledger-verified by name against the client entity table, 72 occupants displaced from a client slot and relocated to a free non-client slot (reason per row in ID_SHIFTS.csv).
- 28 mob ids re-keyed (`sql/slices/npc-id-realign/mob_id_realign.sql`).
- Lua literals updated: conquest.lua, harvesting.lua, La_Theine_Plateau/Zone.lua, Upper_Delkfutts_Tower/Zone.lua, West_Ronfaure and West_Sarutabaruta Signpost.lua.
- `sql/npc_list.sql`, `mob_spawn_points.sql`, `treasure_spawn_points.sql` already contain the new ids (fresh installs need nothing else).

## Existing databases
Run once, on a DB that still has the old ids: `sql/slices/npc-id-realign/npc_id_realign.sql` (two-phase, guarded by old id and name), then `mob_id_realign.sql`. Do not re-run. Restart the map server afterwards.

## Tools
`tools/dat_align.py`, `tools/check_npc_ids.py`, `tools/check_mob_ids.py` (the checkers need a live DB). Test list: ID_SHIFT_TEST_CHECKLIST.md.

See UNRESOLVED.md for open items.

## Reference audit (2026-10-13)
Rule: an id change is not done until everything referencing it is checked (see memory `topaz-dsp-id-change-requires-lua-audit`).
- Literal 8-digit ids in all `scripts/**/*.lua`, `IDs.lua`, and id-bearing SQL tables were compared with the ledger: a reference is stale only if it equals a ledger old id whose current row has a different name. Result: 37 Lua literals already target the DAT-correct id (the move fixed them); 1 stale, fixed (`West_Ronfaure/npcs/Signpost.lua` 17187507 -> 17187540).
- `GetNPCByID(base+offset)` and variable forms were evaluated per file: 958 resolved, 0 stale. `getID()+k` relative door/torch offsets: 878 checks, no relation changed in an affected zone.
- Stale in SQL: `instance_entities` instance 6 (Leujaoam, 5 door/prop ids) -> remapped in `sql/instance_entities.sql`; live DB: `sql/slices/npc-id-realign/instance_entities_leujaoam_6.sql`.
- The 28 mob moves: no literal references anywhere. Not covered: ids built at runtime from non-literal sources, and `conquest.lua` leader-offset rows that point at `Moogle`/blank rows (pre-existing).
- Known dead branch: West_Ronfaure Signpost `17187569` points at a Conquest_Banner (never a Signpost).

## Zone 69 chain resolved live (2026-10-13)
- Deleted the live-only placeholder `NPC[104]` (17060100, 0,0,0, unregistered, no Lua/treasure refs, absent from DAT). Backup: `bak_z69_20261013`.
- Then moved `_1x1` 17060116 -> 17060100 and Moogle 17060108 -> 17060116, and ran `sql/slices/npc-id-realign/instance_entities_leujaoam_6.sql` live (backup `bak_ie6_20261013`). Instance 6 now registers 100, 105, 106, 118, 119.
- Zone 104 Treasure_Casket "target-occupied" skips need no action: live already holds Treasure_Casket at 586-601, matching the DAT list exactly.
- The Selh_teus / Disjoined_One skips are zone 230 (Southern San d'Oria), not 69; see the findings below (unresolved).

## Name-mismatch sweep (2026-10-13)
After the zone 230 fills (606/618/632-635; 632 blank prop moved to 636) and the zone 241:243 Robino-Mobino -> Toppi-Meppi rename (the NPC was renamed by SE on 2018-12-11; DAT and LSB agree), a sweep of remaining rows whose name differs from the DAT slot (excluding `_` props, blank/csnpc, NPC[xx]) found 42 rows and no further clean renames. Evidence: `NAME_MISMATCH_SWEEP_2026-10-13.txt`. Left as-is on purpose (event helpers on generic DAT slots, not fixed now): ~30 rows (Summoner/Lucky Rat/Stray/Ore Door slots etc.); possible off-by-one `fep2/fep3` at 291:877-878; `unknpc` at 235:377/378/388 on Selh'teus/Disjoined One slots; 3 Erudite Moogle rows on Treasure Coffer slots (230:429, 235:250, 238:365) with unidentified model 0x056E-0x0570. Not fixed: deferred by user.

## Held-target cleanup (2026-10-13)
Removed 6 redundant copies whose DAT target slot already held the same-named row (115:526, 115:527 identical; 102:673, 202:61, 258:388, 267:383 same position, differing only by empty polutils_name / lower entityFlags). Swapped 3 Smile_Helper/NPC pairs onto their DAT slots (110:629<->631 Marlena, 117:652<->654 Yvantoine, 120:550<->552 Neriss). Backup `bak_dedupe_20261013`. Left as evidence: digit-named rows with differing looks (zones 13, 81, 85, 163), 102:636 Chocobo, zone 291 fep chain, and the one-off holds (20, 152, 179, 260, 267 Veil, 289, 136).

## Rows owned by other slices (2026-10-13)
The earlier "56 rows owned by other slices" group had shrunk to 5 against the live DB. Handed off, not changed here: zone 208 slots 495 and 496 (zero-position Treasure_Casket on the Achieve Master / Unity Master DAT slots; real DAT casket slots start at 479; belongs to the treasure-caskets rework) and the three Erudite Moogle rows on Treasure Coffer DAT slots (230:429, 235:250, 238:365; unidentified model 0x056E-0x0570, deliberately left as recorded). No Survival_Guide mismatches remain in the live state.

## Live-vs-repo differences (2026-10-13)
Of the 32 listed in `LIVE_VS_REPO_DIFFS_2026-10-13.md`, 8 were already identical (zone 104 rifts, fixed earlier). Repo now mirrors live for the rest with LSB evidence: 12 rift rows in zones 101/109/118/119 (live is a consistent permutation; each zone's 3 positions match LSB) and the 11 zone 104 Treasure_Casket rows (live flag 7 matches LSB). Live 119 Riftworn_Pyxis 17265320 pos_x -519.0 -> -519.9 per LSB. Backup `bak_lvr_20261013`. Left as evidence (no LSB basis): look-only rows 102:17195738 Selh_teus and 104:17203861 Conquest_Banner, Moogle 17248854 speed 40 vs 50, and zone 243 Survival_Guide 17772807 / `???` 17772827 (survival-guides slice).

## Source-absent rows with name not at target (2026-10-13)

38 `SKIP-src-absent` rows in `LIVE_RUN_2026-10-13_applied.csv` where the name was not at the target after the run (the other 230 were already satisfied). Checked against live `dspdb_fresh` and the client DAT. No changes made.

| Group | Rows | Finding | Action |
|---|---|---|---|
| Already satisfied | 2 | Ardrick (zone 104) live at 17203945 (ledger misspelled "Arfdrick"); Ephemeral Moogle (zone 243) live at 17764827 as `Ephemeral_Moogle_CC`, nameplate matches DAT | none |
| Survival guides | 3 | Kuchi Eyjhann 17199775, Iroha 17257126, Siren 17281677: target empty, old slot still a `Survival_Guide` row | left to survival-guides-v2 slice |
| Zone 104 corrective block | 26 | Targets empty, no DAT entity there; old ids hold other real rows (Rook, Logging_Point, Planar_Rift, Riftworn_Pyxis, ...), so the ledger lines are stale. Blank-named props untouched | none |
| Single stragglers | 7 | `???`, blank, `_4z0`, Balamor rows (zones 104, 113, 162, 191, 203, 258): empty target, no DAT entity, different row at old id | none |

Nothing was placed into an empty target slot: the DAT has no entity for those slots, so any placement would invent an id.

## Zone 20 warp shift (2026-10-13)

Promyvion-Mea warp doors (`_0k1`..`_0k9`, `_0ka`, `_0kb`; nameplates warp_01..warp_11) sat 2 slots above the DAT slots that carry the same names (warp_01 = slot 315 ... warp_11 = slot 325). Moved slots 317-327 down by 2 (live and `sql/npc_list.sql`); backup `bak_z20warp_20261013`. Targets were empty; no mob/instance/treasure rows in range. Lua updated in lockstep: `Promyvion-Mea/Zone.lua` (10 refs) and `mobs/Memory_Receptacle.lua` (11 refs) now use ids 16859451..461. `_0k0` (Memory Flux, slot 328) left alone. Scoreboard NPC name mismatches 140 -> 129.

## Zone 20 tail shift (2026-10-13)
Promyvion-Mea: after the warp doors, every mob row at slot >= 98 (210) and every NPC row at slot >= 98 that was not already DAT-correct (22) moved -2 to the slot whose DAT entity name matches (0 name mismatches at targets). Kept in place: Achieve/Unity Master (308/309), Memory Flux (312/313/328), warps (315-325), kiokudama (329-331). Parked (commented in sql/mob_spawn_points.sql, removed live): two surplus Idle_Wanderer rows (old slots 96/97) - the DAT has only 7. Lua: `mobs/Memory_Receptacle.lua` Floor 3 receptacles -> 16859271/280/289/347/356/365. Backups: `bak_mob_spawn_points_z20_20261013`, `bak_npc_list_z20_20261013`. No other id-keyed tables reference zone 20.

## Southern Sandoria zero-pos pass (2026-10-13)
Zone 230: A.M.A.N. Validator placed next to the Reclaimer from LSB (-83.07,1.0,-55.58). 127 rows at 0,0,0 (60 named rows that LSB also leaves at 0,0,0, plus 67 unnamed props) set to status=2 (hidden until an event/script shows them); 100 changed live, 43 were already hidden. Positions filled from LSB: Mystic Retriever (122.27,0,93.6), Enigmatic Footprints (70.81,2.0,-48.72), Destin (0.001,-3.4,43.255) - not yet checked with !checknav. Backup: bak_npc_list_z230_20261013. Review list: worklists/zone230_zeropos_visible.csv. Open: the 25 named rows not hidden (Moogles, Chocobos, Iroha, Shard of Sunlight blanks, Babban's Progeny, Selh'teus), and any script that needs to un-hide a row must call setStatus(0).
