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
