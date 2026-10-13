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
