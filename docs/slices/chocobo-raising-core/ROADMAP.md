# Chocobo Raising roadmap (audit 2026-10-25)

Compared against landsandboat-latest `hobbies/chocobo_raising`, `quests/hiddenQuests`, and the zone NPC scripts.

## Done and live-tested
Trainer (Hantileon/Zopago/Pulonono) event, eggs, aging to adult 3, menu and event playout, growth report, feeding, walks, Watch Over, retirement card/plaque/chococard.

## NPCs
| NPC | Role (LSB) | DSP state |
|---|---|---|
| Hantileon (San d'Oria), Zopago (Bastok Mines), Pulonono (Windurst Woods) | Trainers | Wired, San d'Oria capture-backed only |
| Arvilauge (San d'Oria), Gonija (Bastok Mines), Kiria-Romaria (Windurst Woods) | Stable clerks: lost-chick review, digging skill | Old stub scripts; Kiria-Romaria has no script (npc_list row exists) |
| Finbarr (Upper Jeuno) | VCS Honeymoon, chocobo breeding | Old stub (startEvent 0x2777 only) |
| VCS_Debug (3 zones) | Debug | Not needed |
| Per-city lost-chick owner NPCs (San d'Oria 8, Bastok 6 of 8, Windurst 4 of 8) | Lost Chick quest | Not wired |

## Quests
| Quest | LSB | DSP |
|---|---|---|
| Chocobo Whistle (hidden) | `hiddenQuests/Chocobo_Whistle.lua`, `whistle.lua` | Ported (slice 3, quest part) |
| Lost Chick (hidden) | `hiddenQuests/Lost_Chick.lua`, `walks.lua` | Ported (slice 1) |
| Save My Son (Jeuno) | Gates Dietmund on long walks | Dietmund meeting ported (slice 5) |

## Not ported (engine)
Whistle quest and its ADULT_1 / walk replies; trainer meetings, stories and the abilities they teach; competing; breeding (Finbarr); handkerchief scene; ADULT_4 (cs 38, never captured); several VM ops; Bastok/Windurst captures.

## Suggested order
1. Stable clerks plus Lost Chick (walks already roll the event; needs `walkTrainer` meetings and clerk review).
2. Walk trainer meetings and stories (unlocks abilities).
3. Whistle quest (depends on 1-2 and the ADULT_1 scene).
4. Breeding at Finbarr.
5. Competing, then Dietmund.
Each as its own slice with captures or LSB-only notes recorded in TEST_PLAN.md.

## Slice 1 status (2026-10-25): stable clerks and Lost Chick
Ported from LSB, no capture evidence except Windurst clerk csid 761 (client-confirmed) and key item 850 (client DAT).
- Done: walk meetings (walk_progress), chick state, clues, clerk scripts (Arvilauge, Gonija, Kiria-Romaria), trainer report 852/542/766, owner hooks on 18 NPCs, third-meeting stories 837-840.
- Live-tested (see TEST_PLAN.md): walk finds a chick, Cahaurme right/wrong guess, Arvilauge clerk 846, Hantileon report 852. NOT live-tested: Bastok/Windurst clerks and reports, the other 17 owners, ask-option, story key items on the third meeting.
- Not ported: guild-shop owners (Abd-al-Raziq, Azima, Kyaa Taali, Kopuro-Popuro, Peshi Yohnts, Ponono). Violitte needs no forward: LSB Violitte.lua only calls the map seller, and her chick-owner event (851) is already wired.

## Slice 2 status (2026-10-25): telling stories (abilities)
Meetings and the third-meeting story awards were already in slice 1. New: `scripts/globals/chocobo_raising_story.lua` (care action 242 arg 50, command 50).
- **LSB GUESS, not evidence:** learn chance 25%, per-ability discernment thresholds (64/96/64/160/64/64), +1 discernment per telling, 10-100 energy refund, inspired stat table and +2 gain, 11/14 energy cost. All are commented in the file as guesses; change `CR.LEARN_CHANCE`, `STORY_DISCERNMENT`, `INSPIRED_STAT`, `INSPIRED_GAIN`, `STORY_COST` if a capture shows otherwise.
- From LSB's client decoding (not captured either): the menu shape, story mask in p2, reply p0 0/1/2.
- Competing and the Happy story were added in slice 5.

## Slice 3 status (2026-10-25): Chocobo Whistle quest (quest part only)
`scripts/globals/chocobo_raising_whistle.lua`. Growth to adult 1 queues a "whistleQuest" effect (applied in `CR.initState`); San d'Oria raisers start at SEARCH, others at SEE_HANTILEON (Hantileon scene 829). While SEARCH, walks reply p2=1 and command 88 (arg = walk length 1-3) answers whether the handkerchief hides on that length (rolled once, char var `ChocoboWhistleHidingWalk`); found -> FOUND + Handkerchief key item (DSP id 809) -> Hantileon scene 830, option 222 -> Chocobo Whistle (15533) -> DONE. Adult 1 growth scene sends p2=1 while the quest is open.
- Evidence: events 829/830 exist in the zone 230 client DAT (829 on Hantileon). Command 88, option 222 and every reply shape are LSB-decoded, no capture.
- Deviations from LSB: whistle is withheld (quest stays FOUND) when the bag is full instead of LSB's pending-whistle flag; the crying handkerchief mechanic is not ported so the plain Handkerchief is always the one found; progress lives in a char var (no user-flag store in DSP).
- Whistle trades at the VCS trainer (`chocobo_raising_whistle_trade.lua`, tested live for all three trainers as `whistle_card`): registration-card menu (events 844/525/752, ids verified in the client DATs), register (250 gil, `registerChocobo`), chococard (300), replacement whistle (20000), whistle recharge at 400 gil per used charge (option 220) and whistle+coupon refill, using the new C++ `CLuaItem:getCurrentCharges/getMaxCharges` bindings (tested live as `whistle_recharge`/`whistle_poor`/`whistle_coupon`/`whistle_full`, hantileon only). Options/prices are LSB guesses (no capture). Riding with the registered stats is done (speed byte code-verified only; Mounted duration = minutes*60 and subpower 0x40 live-verified as `whistle_ride`; the whistle is a neck item and needs key item 138 plus a chocobo zone). NOT ported: the personal-chocobo mount model. Windurst/Bastok raisers: scene 829 path untested.

## Slice 4 status (2026-10-25): Finbarr breeding (VCS Honeymoon)
`scripts/globals/chocobo_raising_breeding.lua`, Finbarr.lua, Upper_Jeuno TextIDs 11710. Menu 10108 buys a ticket (plan 1-4), trading ticket + both chococards plays date 10102 and lays an egg for the next JST midnight (10105 wait, 10107 hand-over); a bred egg handed to a trainer keeps its genes/ability, rolls sex by plan and seeds the plan stat.
- Evidence: events 10101-10108 on Finbarr and text 11710 exist in the zone 244 client DAT. Event params, exdata layouts and all numbers are LSB; no capture.
- **LSB GUESS:** ticket price 3500, mutation 5%, ability inheritance 60%+3/rank, Sports/Jeuno 70% lean, male chance (Gourmet 70/Hiking 30), +8 seed, Sports/Hiking egg items. All commented in the file.
- Live-tested (breed_ticket, breed_date, breed_hatch, Hantileon): all pass. Ticket plans 2-4, dates and egg hand-over for plans 2-4, hatch with Zopago and Pulonono, and the full-bag hand-over (egg stays pending) live-tested 2026-10-26.


## Slice 5 status (2026-10-25): competing and Dietmund
`scripts/globals/chocobo_raising_compete.lua`, plus Dietmund in `chocobo_raising_chick.lua`. Care action 52 (cmd 242 arg 52): needs adolescence and the rivals met once; costs 27 (clear) or 34 energy, +1 affection, boredom cured at rollover, wins counted in walk_progress bits 12-13, key item 841 (Happy story) on the third win. The long walk can meet Dietmund (trainer 6) once after Save My Son, tracked by char var `ChocoboMetDietmund`; no clue or meeting count.
- Evidence: all shapes and numbers are LSB; no capture.
- **LSB GUESS:** 50% win chance (`WIN_CHANCE`), rival names, costs. Commented in the file.
- Menu command 243 (care menu mask) is now answered by `CR.handleCareMenu`: reply `(0x7FFFFFFF minus offered bits, energy)`, verified byte for byte against captured masks for chick/adolescent/adult, with and without the rivals met (care_menu scenario).
- Live-tested (compete, dietmund, Hantileon): pass. Dietmund's and the race scene client events were not checked in a DAT pull.

## Naming (2026-10-25)
`chocobo_raising_names.lua` holds the client name table (LSB indices, banned set). Menu option 0xFF (first index bits 8-17, last bits 18-27) is validated and saved by `handleNamingUpdate`; 216 (forced naming) is acked; an unnamed chocobo is named by the trainer (random 5-8 letter first name) at the adult 2 -> 3 scene. Live scenarios `naming` and `forced_name` (the latter flaky on the first run of a batch). Care plan (0xFE) was already wired.

## Guild-shop chick owners: blocked
Abd-al-Raziq, Azima, Kyaa Taali, Kopuro-Popuro, Peshi Yohnts and Ponono ask inside their guild shop events. LSB itself has these as TODO (events unconfirmed), so they cannot be ported without a capture or a DAT decode of the shop events. Do not guess the event ids.

## Stable clerks: complete (2026-10-26)
LSB's three clerks only start the review event (846/534/761) with the dig-skill and clue params; they have no onEventUpdate/onEventFinish, so the client handles the menu itself. DSP matches that. Server-side tests pass for all three; real-client check of Gonija is pending.
