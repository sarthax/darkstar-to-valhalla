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

## Slice 5 - day rollover, growth report (248/208), playout (246), skip (504)

Headless run (xitest03, Windurst Woods trainer csid 742), `created` moved back N days via SQL:
- 6 days from egg: stage 1 -> 2, last_update_age 6. 208 replies `(0xFFFFFFFF, 208, 0, 0, stage, ...)`; 248 header `2151682049` decodes to first=1, days=4, last=4, bit31 (more records) set.
- 246 playout: replies `(remaining, 768, ...)` then `(0, 801, ...)`: scene ids 3*256+0 and 3*256+33 (egg hatching), matching capture-verified offsets; stage switches to chick on the hatch scene.
- 40 days: stage 4 (adult 1), 248 records advance one per request, 504 (arg 1) sets skip, the next 246 drains the non-mandatory queue and ends with `0xFFFFFFFF`.
- Not tested: ADULT_3/4 mandatory scenes, gil payout, handkerchief/whistle, retirement. Odds marked "guess" in chocobo_raising_day.lua come from LSB and have no capture behind them. 246 p6/p7 use LSB's 0 and 3 (captures vary).

## Slice 6: retirement flow (evidence 2026-10-24)

Source: San d'Oria retire capture (option 24672 = command 96 arg 96 -> reply `(0, location*256+96, 0,0,7,0,0,0)`, then 244, then 40; card 2313 and yellow plaque 309 obtained at finish).
Live headless test (Windurst Woods, stage-4 yellow chocobo, 96/244/40 then finish): card 2313 + plaque 309 received, `char_chocobos` row deleted. PASS.
Bugs found by the live run: DSP has `getVar/setVar` (not `getCharVar`); `char_vars.varname` is 30 chars (owed-items var is `ChocoRetireItems`).
Repeatable: `tests/live/chocobo_raising/run_live.py retirement` and `day_report [days]` in the mission toolkit (PR 1401 branch).
Not done: hand-over events 843/518/751 (no capture), post-retire 817 params, mandatory ADULT_3/4 scenes need a live day-64/129 run, give-up flow, chococard 2342. (card exdata: done in slice 7)

## Slice 7 evidence: VCS card exdata

- No C++ rebuild was needed: `player:addItemExData(id, {24 bytes}, silent)` already exists (commit 21ed4b6809). `CR.packCard` builds the 24 bytes in Lua (STR/END/DSC/RCP bytes, DNA/ability/temperament/weather/gender/colour/size word, 12-byte 6-bit signature).
- Offline: `packCard` reproduces the San d'Oria retire capture bytes for item 2313 exactly (`38 30 08 0B 88 00 08 11 ... 4F 6B 77 2F 9A 25 9E 90`, name EirSkd O8T18). Test: toolkit `tests/test_chocobo_card_pack.py`.
- Live (2026-10-24, xitest03, Windurst Woods Pulonono): seeded the capture stats, retired, `char_inventory.extra` for 2313 = the capture bytes, byte for byte. Test: `tests/live/chocobo_raising/run_live.py retirement`.
- Chococard moved to slice 8.

## Slice 8 evidence: chococard (trainer option 239)

- Captures: Raguza 2021-12-04 (Hantileon, event 823, option 239 -> "Obtained: Chococard (F)", item 0x0926 = 2342, gil 73916 -> 73616 = 300) and Raguza 2021-07-27 (Chococard (M), item 0x0923 = 2339). Item ids match LSB `item.lua` CHOCOCARD_M/F. The capture shows no Event Update reply for 239.
- The F chococard exdata equals the retirement card bytes for the same bird, so `CR.handleChococard` reuses `CR.packCard`.
- Not evidenced, so not built: the "not enough gil" message and any stage gate (the capture is an adult bird). Insufficient gil just does nothing.
- Live (2026-10-24, Pulonono, xitest03): `run_live.py chococard` PASS: item 2342 exdata matches capture, 300 gil charged, chocobo kept.
- Open: second sample (2339 bytes `16 1A 18 14 89 00 00 12 ... 43 6B 69 CA 80`) not yet checked against that bird's saved stats.

## Full live pass 2026-10-24 (Pulonono, xitest03, slices 1-8 code)

| Scenario | Result |
|---|---|
| day_report 6 / 30 / 65 / 130 (stage 2 / 4 / 6 / 7) | PASS |
| retirement (card 2313 exdata = capture, plaque 309, row deleted) | PASS |
| chococard (2342 exdata = capture, 300 gil, bird kept) | PASS |

- No new Lua errors in the map-server log during the run (the old `getCharVar` and upsert errors are from earlier builds).
- Harness fix: the first day 64 / 129 runs "failed" only because seed() makes the bird days-1 old and the old assertion hard-coded stage 4. Expected stage is now derived from the thresholds 4/19/29/43/64/129. No server bug.

## Trainer matrix 2026-10-24/25 (3 trainers in parallel, accounts xitest04/05/06/07)

`run_live.py` takes `TRAINER=pulonono|hantileon|zopago` and `ACCOUNT=xitest03..08` so streams run in parallel (one pool account per stream).

| Scenario | Pulonono (241) | Hantileon (230) | Zopago (234) |
|---|---|---|---|
| menu (208, 252, 214, 244, 500, 251, 63220, 250, 215: each accepted, no Lua error) | PASS | PASS | PASS |
| careplan (0xFE 852222 -> plan byte 0x51) | PASS | PASS | PASS |
| feed (241: 2x gysahl 4545 traded, hunger 100 -> 150, greens consumed) | PASS | PASS | PASS |
| chococard (2342 exdata = capture, 300 gil, bird kept) | PASS | PASS | PASS |
| retirement (card 2313 exdata = capture, plaque 309, row deleted) | PASS | PASS | PASS |
| day_report 30 (stage 4) | PASS | PASS | PASS |

- Card size nibble (byte 7 bits 4-7) is the owner's race id, Galka 0. It differs per account (0x11 Hume, 0x01 Galka, 0x51 race 5), so the harness masks it and asserts it against `char_look.race`. The first Hantileon/Zopago retirement "failures" were this test mask, not the server.
- Options 250 (care menu) and 215 (intro 3) end the trainer event; the menu scenario reopens it afterwards. The first Pulonono menu "failures" were an event-ordering problem in the harness.
- Limits of what this proves: menu options are only shown to be accepted without a Lua error (reply bytes are not traced by the harness), and feeding is checked by hunger and item consumption, not by the glow/rank reply values from the capture.
- NOT covered (no scenario yet): walk, mandatory ADULT_3/4 cuts, give-up before ADULT_1, insufficient gil / full bag.

## Chococard edge cases 2026-10-25 (Pulonono, xitest03, run tree dsp-branches on main)

| Scenario | Result |
|---|---|
| chococard_broke (299 gil: no card, no gil charged) | PASS |
| chococard_fullbag (inventory full: no card, gil stays 1000) | PASS |
| chococard_male (item 2339, 300 gil; exdata printed, no male capture to compare) | PASS |

- Male card exdata differs from the female one only in byte 7 (0x10 vs 0x11); no capture exists for the male bytes, so that value is unverified.

## Capture findings 2026-10-25 (Complete Timeline [SandOria])
- Retirement: no hand-over event. Card 2313 and plaque 309 arrive as bare 0x020 packets right after an outgoing 0x05B option (so 843/518/751 do not exist). Next trainer click is intro csid 817 params 1,0,5,0,0,0,3,1.
- ADULT_3 (day 64): update [0,293,1,0,6,0,0,0] = location 1 *256 + cs 37, stage 6; matches our cs table. ADULT_1 scene (cs 35) also has p2=1 in the capture (ours sends 0, whistle quest not ported). Capture ends at day 126 retire, so cs 38 (ADULT_4) was never played in it.
- Live: day_report 65 -> stage 6 PASS, 130 -> stage 7 PASS (earlier 64/129 FAILs were a stale harness expectation).
- Not yet checked: walk flow, egg exdata vs capture. All 37 zips are already ingested in the toolkit DB.

## Walks (2026-10-25, ported from the Complete Timeline [SandOria] capture)
- Walk option = command 242 (0xF2), arg 42/43/44 = short/regular/long (10994/11250/11506). Reply p0 = the walk csid
  (San d'Oria 298/299/300), p1 = (energyAfter<<8)|energyBefore, p2 = 7 when an item was found (p3 stays 0), p4 = stage,
  p7 = weather of the walk zone. Not enough energy: p1 = -1.
- Energy cost is NOT LSB's 25/33/50+0..5. Clear weather (0/1): short 23-24, regular 31-32, long 38. Other weather
  (2/3/6/10/14): short 29-30, regular 39-40, long 47-48 (about x1.25).
- The found item is handed over by Watch Over (0x30F2 = 12530): reply p1 = (after<<8)|before, p2 = 1, p3 = item. Watch Over
  costs 3 or 4 energy (random) in the capture, none for an egg (LSB says 5). Ported; `run_live.py watch` passes.
- Gap: DSP Lua has no zone weather (no GetZone global, no CLuaZone:getWeather), so walks report weather 0 and always use
  the clear-weather cost. Needs a small C++ binding.
- Live: `run_live.py walk` passes (cost ranges, refusal when short of energy). Item find odds (33%) are LSB's, unverified.

### Walk behaviours without capture evidence: LSB audit (2026-10-25)
Checked against landsandboat-latest `hobbies/chocobo_raising` (`event_vm.lua`, `walks.lua`, `constants.lua`).

| Behaviour | Source | Status |
|---|---|---|
| Walk zone weather picks the energy tier and is sent as p7 | LSB `getWeatherInZone(walkZone)`; capture shows ~x1.25 tier | `GetZoneWeather` C++ global (0 if zone not loaded on this map server) |
| Watch Over cost 3 clear / 4 otherwise, weather of the player's own zone (also p7) | LSB; capture shows 3 or 4 | LSB-backed, consistent with capture |
| Item find chance 18/26/15 (short/regular/long) | LSB `eventChance[2]`, "at or below the captured rates" | Was a flat 33; now per-tier. LSB rolls trainer meetings first (21/15/18), not ported |
| Item only found while no item held | LSB | Same |
| Full bag: Watch Over p2 = 2, item kept | LSB | Same, LSB-only |
| Short energy | LSB `0x80000000 \| careAction` in p1 | We send -1; neither is capture-confirmed for Watch Over |
| Walk energy costs | Capture (23/31/38 +0..1, bad weather 29/39/47 +0..1) | LSB 24/32/38 and 30/40/48 differ slightly; capture kept |
| Whistle-quest walk reply (p2 = 1, stores search distance) | LSB | Not ported: the whistle quest is not ported |
| Trainer meetings, lost chick, stories on walks (p5/p6) | LSB `walks.walk` | Not ported |

## Lost Chick and stable clerks (2026-10-25)
No capture covers meetings, clues, the clerk review or the owner questions; everything below is LSB's unless noted.
| Item | Source | Live status |
|---|---|---|
| Clerk csids 846 (San d'Oria) / 534 (Bastok) / 761 (Windurst) | LSB; 761 confirmed on the client | 846 opens live (`chick_clerk`); 534/761 untested; review menu options untested |
| Trainer report csids 852 / 542 / 766 | LSB | 852 shows and clears the result live (`chick_report`); 542/766 untested |
| Key item 850 Story of a Diligent Chocobo | client ROM/175/35.DAT | untested |
| Meeting chance 21/15/18 %, item chance 18/26/15 % | LSB | walk reply path passes (`walk` scenario) |
| Chick found on a short walk, packed in char var `ChocoboRaisingLostChick` | LSB | passes (`chick` scenario, owner and location valid) |
| Owner events and ask/guess options (18 owners) | LSB walks.chickOwners | Cahaurme right and wrong guess pass live (`chick_guess`); ask-option owners and the other 17 untested |
| Guild-shop owners, Violitte map vendor forward | not ported | - |
Run: `TRAINER=hantileon ACCOUNT=xitestNN py -3 run_live.py chick` (needs the toolkit worktree's run_live.py).

## Telling stories (2026-10-25) - LSB GUESS values, no capture
Code: `scripts/globals/chocobo_raising_story.lua`. Every outcome number is an LSB guess ("Guess from guides; no capture shows a story being learned"); change them there if evidence appears.
| Item | Source | Live status |
|---|---|---|
| Care action 242 arg 50 (option 13042), story mask in p2, cutscene 50 + 256*location | LSB event_vm decoding | passes live (`story`, 2026-10-25, hantileon, xitest05) |
| Command 50 (option story*256+50), reply p0 0 interested / 1 learned / 2 inspired | LSB | passes live (`story`, 2026-10-25, hantileon, xitest05) |
| Energy cost 11 clear / 14 other | LSB careActionEnergy | passes live (`story`, 2026-10-25, hantileon, xitest05) |
| Learn chance 25%, discernment need 64/96/64/160/64/64, +1 discernment per telling, 10-100 energy refund, inspired +2 stat | LSB guess | passes live (`story`, 2026-10-25, hantileon, xitest05) |
Run: `TRAINER=hantileon ACCOUNT=xitestNN py -3 run_live.py story`.

## Slice 3: Chocobo Whistle quest (LSB-only evidence)
| Case | Result |
|---|---|
| Growth to adult 1 starts the quest at SEARCH (San d'Oria) | PASS live 2026-10-25 (`run_live.py whistle`) |
| Wrong walk length answers "not here" | PASS live |
| Right walk length: FOUND + Handkerchief key item 809 | PASS live |
| Hantileon scene 830, option 222: whistle 15533, DONE | PASS live |
| Scene 829 path (Bastok/Windurst raisers), full bag withhold | NOT tested |
All reply shapes, command 88 and option 222 are LSB-decoded, no capture; events 829/830 exist in the zone 230 DAT.

## Slice 4: Finbarr breeding (LSB-only evidence, no captures)
| Case | Scenario | Result |
|---|---|---|
| Buy ticket (plan byte, signature, 3500 gil) | breed_ticket | PASS 2026-10-25 |
| Date, wait, bred egg with IsBred bit | breed_date | PASS 2026-10-25 |
| Bred egg hatches with genes, ability, +8 strength | breed_hatch | PASS 2026-10-25 |

## Slice 5: competing and Dietmund (LSB-only evidence, no captures)
- `run_live.py compete`: refused before rivals met and when short of energy, cost 27-34, wins counter, key item 841 on the third win.
- `run_live.py dietmund`: no meeting before Save My Son, met after `!completequest jeuno save_my_son`, flag set.
