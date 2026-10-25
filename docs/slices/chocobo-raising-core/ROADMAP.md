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
- Live-tested: walk scenario still passes, scripts load without errors. NOT live-tested: meeting/clue replies, clerk review, owner guess, report.
- Not ported: guild-shop owners (Abd-al-Raziq, Azima, Kyaa Taali, Kopuro-Popuro, Peshi Yohnts, Ponono), Violitte map-vendor forward (595), clerk menu options beyond the opening event.
