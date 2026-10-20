# TEST_PLAN: chocobo-raising-core

Pre-step: back up the DB, dry-check live schema (MyISAM), then apply `up.sql`. Run `tools/check_sql_id_collisions.py` is not needed (no pool/group ids).

| # | Test | Expected | State |
|---|------|----------|-------|
| 1 | Build map-server | compiles | untested |
| 2 | up.sql then down.sql then up.sql | idempotent, no errors | untested |
| 3 | addItemExData + saveItemExData, relog, getExData | bytes identical | untested |
| 4 | Move/trade an item with exdata | bytes survive | untested |
| 5 | setChocoboRaisingInfo, relog, getChocoboRaisingInfo | all fields round-trip | untested |
| 6 | setChocoboUserData / registerChocobo, relog, get | values round-trip | untested |
| 7 | Delete character | char_chocobos row gone | untested |
| 8 | getChocoboRaisingInfo for char with none | nil | untested |
| 9 | Existing item/trade/save paths | no regression | untested |

Evidence goes in this file as `runtime:` / `test:` lines; nothing is `validated` without it.
