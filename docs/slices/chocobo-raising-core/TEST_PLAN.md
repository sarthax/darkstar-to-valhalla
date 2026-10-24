# TEST_PLAN: chocobo-raising-core

Pre-step: back up the DB, dry-check live schema (MyISAM), then apply `up.sql`. Run `tools/check_sql_id_collisions.py` is not needed (no pool/group ids).

| # | Test | Expected | State |
|---|------|----------|-------|
| 1 | Build map-server | compiles | tested |
| 2 | up.sql then down.sql then up.sql | idempotent, no errors | tested |
| 3 | addItemExData + saveItemExData, relog, getExData | bytes identical | tested (egg fixed in b16a391408) |
| 4 | Move/trade an item with exdata | bytes survive | untested |
| 5 | setChocoboRaisingInfo, relog, getChocoboRaisingInfo | all fields round-trip | tested (after fix 0fa8cee06a) |
| 6 | setChocoboUserData / registerChocobo, relog, get | values round-trip | tested |
| 7 | Delete character | char_chocobos row gone | untested |
| 8 | getChocoboRaisingInfo for char with none | nil | untested |
| 9 | Existing item/trade/save paths | no regression | untested |

Evidence goes in this file as `runtime:` / `test:` lines; nothing is `validated` without it.

## Evidence (2026-10-24, xitest03, headless MCP, MariaDB 12.3.2, chocobo commits 1f40d60ebf + 0fa8cee06a)

- runtime: build OK (game + connect, Release x64); only the git-version post-build step fails (exit 9009, unrelated).
- runtime: up.sql applied to live dspdb_fresh after backing up char_pet; up/down/up/up on a scratch DB had no errors and the columns match sql/char_chocobos.sql (30 columns).
- runtime: setChocoboRaisingInfo returned false on first run: MariaDB rejects FROM_UNIXTIME(0) ("Truncated incorrect unixtime value"). Fixed in 0fa8cee06a (NOW() when created is omitted; existing created kept). After the fix all 29 fields plus created are identical before and after relog.
- runtime: setChocoboUserData and registerChocobo persisted: char_pet.chocobo_user_data = 41960000A5A50000410100..., readback identical after relog (flags 0xA5A5, chocobosRaised 321, field properties 3846). registerChocobo overwrites registered* stats from its own table (it does not read the raising row).
- runtime: exdata set via addItemExData matches char_inventory.extra and the client's 0x020 readout (24 bytes). After relog a plain item (4096) is identical. chocobo_egg (2312) is NOT: bytes 17 and 23 changed (7F->40, A9->80) while the DB row is unchanged.
- cause: charutils::LoadInventory calls setSignature() for ITEM_FLAG_INSCRIBABLE items, which overwrites extdata bytes 12-23 with the encoded (empty) signature. An egg's data must live in bytes 0-11 or use the signature column.
- not run: #4 move/trade, #7 char delete, #8 none->nil, #9 regression.
- runtime: after b16a391408 (load only seeds the signature from the column when extra[0x0C..] is empty) the chocobo_egg exdata is byte-identical before and after relog (080F161D...A2A9). Existing rows whose signature exists only in the column still get it.
- runtime: #4 (move) chocobo_egg with bytes 0-11 = 01..0C moved main bag slot 17 -> container 5 slot 1 via move_to_container: char_inventory.extra and the client 0x020 readout are byte-identical after the move and after relog. Player-to-player trade not run (needs two bots).
- runtime: #8 getChocoboRaisingInfo for a char with no char_chocobos row returns nil.
- not run: #7 char delete (lobby.cpp path needs a throwaway lobby char), #9 full regression pass.
- runtime: #7 char delete: xitest08 char with a char_chocobos row deleted through the lobby (0x14 delete, result=3): chars row and char_chocobos row both gone; account re-provisioned afterwards.
- static (not runtime): player-to-player trade. charutils::DoTrade copies a stack-1 item with itemutils::GetItem(PItem) (default copy constructors, so m_extra is carried) then AddItem(PTarget, ..., PNewItem). Headless has no player-trade tool, so this is unverified at runtime.
