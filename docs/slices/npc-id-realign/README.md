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
