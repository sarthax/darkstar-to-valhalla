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
- runtime: player-to-player trade (two bots, xitest03 -> xitest08, headless trade_player_* tools): a stack-1 plain item (4112) with all 24 exdata bytes set and an inscribable item (180) with bytes 0-11 set arrive on the receiver byte-identical in char_inventory.extra and the client 0x020 readout, and after relog. Sender slots are emptied.
- note: chocobo_egg (2312) has ITEM_FLAG_EX (0x4000), so the server refuses to trade it between players (0x034 handler returns silently). Eggs move only via NPC trade (0x036); egg-to-player trade is not possible by design.
- not run: #9 full regression pass beyond the paths exercised above.

## Evidence P1a (2026-10-24, xitest03, Pulonono npc 17764419 zone 241, commit f42de13454)

- runtime: egg trade 2312 to Pulonono started csid 745 with params [VanadielTime,0,0,0,0,0,0,3]; onEventUpdate received option 252; finish with option 252 created a char_chocobos row (stage 1, location 3) and consumed the egg.
- runtime: second egg trade with a chocobo present started rejection csid 748 (params [3,0,0,0,0,0,0,3]); update option 244 reached Lua; egg kept.
- note: headless auto-finish watchdog (7 s grace) sends finish option 0 if an event lingers; drive trade -> update -> select back to back.
- not verified: S>C 0x05C reply bytes (event_trace shows only inbound 0x032/0x034 and outbound 0x05B); Hantileon and Zopago trade paths; intro trigger csids.

## Evidence P1b slice 1 (2026-10-24, xitest03, Pulonono, uncommitted-run-tree copy of worktree Lua)

- runtime: clicking Pulonono with a saved chocobo (location 3) starts main csid 742 via startEventString (first/last name x2, isTradeEvent 0, infoFlag 0, sex); no Lua errors in map log.
- not verified: string packet contents (event_trace shows only 0x032), menu options (VM ops are not ported), growth report (infoFlag always 0), age/stage helpers unused yet.

## Evidence P1b slice 2 (2026-10-24, xitest03, Pulonono, csid 742 menu VM)

- runtime: with an open csid 742, option updates 208, 252, 248, 214, 215, 250 and 852222 (0xFE care plan, slot 0, length 5, type 1) were all accepted with no Lua errors and the event stayed active.
- runtime: the 0xFE update persisted: char_chocobos.care_plan 0x70707070 -> 0x51707070 (slot 0 byte = length<<4 | type).
- not verified: S>C 0x05C reply bytes (untraced) and exact menu flag values against captures; ops 40/46/216/221-223/240/241/243/244/246/251/256 are not ported; no growth report, so 248 always replies as "no report".

## Evidence P1b slice 3 (2026-10-24, xitest03, Pulonono, csid 742 menu VM)

- runtime: with an open csid 742, option updates 244 (appearance), 251 (condition), 500 and 63220 (command 244 with args) were accepted with no Lua errors and the event stayed active.
- not verified: S>C 0x05C reply bytes and the rank mapping (LSB numberToRank always returns 0, so 32 points per rank is a guess); capture 824/825 replies for 244/251 were not compared.
- not ported: feeding (241), event playout (246), growth report, skip report (504).

## P1b slice 4 evidence: feeding (menu option 241)

- Capture check: 241 reply = (10, glow 96, 0, 0, 1, 6, 0, 0) (Windurst capture Day 7-8); message ids resolved by text from freshly generated dialog.yml per zone.
- Live test (headless, Windurst Woods Pulonono, chocobo stage 3, hunger 100): trade 2x gysahl greens (4545) opens event 742 (isTradeEvent = 8); option 241 -> hunger 150, gysahl consumed, no Lua errors.
- Not verified on the wire: reply bytes compared only by reading against the capture; feed message ids matched by shape/text, not seen in a client.
