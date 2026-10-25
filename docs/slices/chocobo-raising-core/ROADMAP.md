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
| Chocobo Whistle (hidden) | `hiddenQuests/Chocobo_Whistle.lua`, `whistle.lua` | Not ported |
| Lost Chick (hidden) | `hiddenQuests/Lost_Chick.lua`, `walks.lua` | Not ported |
| Save My Son (Jeuno) | Gates Dietmund on long walks | Quest id exists; Dietmund meeting not ported |

## Not ported (engine)
Whistle quest and its ADULT_1 / walk replies; trainer meetings, stories and the abilities they teach; competing; breeding (Finbarr); handkerchief scene; random name at adult 3; ADULT_4 (cs 38, never captured); several VM ops; Bastok/Windurst captures.

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
- Not ported: guild-shop owners (Abd-al-Raziq, Azima, Kyaa Taali, Kopuro-Popuro, Peshi Yohnts, Ponono), Violitte map-vendor forward (595), clerk menu options beyond the opening event.

## Slice 2 status (2026-10-25): telling stories (abilities)
Meetings and the third-meeting story awards were already in slice 1. New: `scripts/globals/chocobo_raising_story.lua` (care action 242 arg 50, command 50).
- **LSB GUESS, not evidence:** learn chance 25%, per-ability discernment thresholds (64/96/64/160/64/64), +1 discernment per telling, 10-100 energy refund, inspired stat table and +2 gain, 11/14 energy cost. All are commented in the file as guesses; change `CR.LEARN_CHANCE`, `STORY_DISCERNMENT`, `INSPIRED_STAT`, `INSPIRED_GAIN`, `STORY_COST` if a capture shows otherwise.
- From LSB's client decoding (not captured either): the menu shape, story mask in p2, reply p0 0/1/2.
- Not ported: competing and the Happy story from three wins (slice 5).

## Slice 3 status (2026-10-25): Chocobo Whistle quest (quest part only)
`scripts/globals/chocobo_raising_whistle.lua`. Growth to adult 1 queues a "whistleQuest" effect (applied in `CR.initState`); San d'Oria raisers start at SEARCH, others at SEE_HANTILEON (Hantileon scene 829). While SEARCH, walks reply p2=1 and command 88 (arg = walk length 1-3) answers whether the handkerchief hides on that length (rolled once, char var `ChocoboWhistleHidingWalk`); found -> FOUND + Handkerchief key item (DSP id 809) -> Hantileon scene 830, option 222 -> Chocobo Whistle (15533) -> DONE. Adult 1 growth scene sends p2=1 while the quest is open.
- Evidence: events 829/830 exist in the zone 230 client DAT (829 on Hantileon). Command 88, option 222 and every reply shape are LSB-decoded, no capture.
- Deviations from LSB: whistle is withheld (quest stays FOUND) when the bag is full instead of LSB's pending-whistle flag; the crying handkerchief mechanic is not ported so the plain Handkerchief is always the one found; progress lives in a char var (no user-flag store in DSP).
- NOT ported (needs the mount, which DSP only stubs): whistle registration/recharge NPC events (844/845 San d'Oria, 525/533 Bastok Mines, 752/760 Windurst Woods), coupon, replacement purchase, riding your own chocobo. Windurst/Bastok raisers: scene 829 path untested.

## Slice 4 status (2026-10-25): Finbarr breeding (VCS Honeymoon)
`scripts/globals/chocobo_raising_breeding.lua`, Finbarr.lua, Upper_Jeuno TextIDs 11710. Menu 10108 buys a ticket (plan 1-4), trading ticket + both chococards plays date 10102 and lays an egg for the next JST midnight (10105 wait, 10107 hand-over); a bred egg handed to a trainer keeps its genes/ability, rolls sex by plan and seeds the plan stat.
- Evidence: events 10101-10108 on Finbarr and text 11710 exist in the zone 244 client DAT. Event params, exdata layouts and all numbers are LSB; no capture.
- **LSB GUESS:** ticket price 3500, mutation 5%, ability inheritance 60%+3/rank, Sports/Jeuno 70% lean, male chance (Gourmet 70/Hiking 30), +8 seed, Sports/Hiking egg items. All commented in the file.
- Live-tested (breed_ticket, breed_date, breed_hatch, Hantileon): all pass. Not tested: other plans/trainers, full bag, ticket menu options 2-4.
