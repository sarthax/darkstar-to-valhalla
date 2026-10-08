# Voidwatch NM Details — Notes (hand-edited)

Source and verification ledger for `NM-DETAILS.md`. **This file is never overwritten by the generator.**

Source tags: [C] capture, [V] client dat, [J] wikiwiki.jp, [F] FFXIclopedia, [W] BG Wiki, [B] BG forum, [D] design guess, [U] user-stated, `?` = none known.
Verified: `yes` (checked against a ground-truth source), `partial`, `no` (unchecked/guess), `user-stated`.
Values are a snapshot when this file was created; the live numbers are in `NM-DETAILS.md`.

## Botulus_Rex (Buburimu_Peninsula)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 94-95 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/BLM | ? | no |  |
| HP | 145000 | ? | no | no capture; BG Wiki lists only rifts, tier and treasure (no stats). |
| skills | list 1166 | ? | no |  |
| spells | list 449 | ? | no |  |
| Pyxis drops | 9 items with per-item % | U | user-stated | dropRates: Asteria 0.1, Supernal Knife 12.2, Gerra's Staff 16, Beaivi's Scepter 0.1, Athos's Tabard 1.8, Rubeus Jacket 2.1, Heavy Metal 21.1, Riftdross 0.8, Riftcinder 3.3 (percent) |
| key item | Atmacite of the Shrewd + Dusky Periapt of Vigilance | W, U | partial | both granted (periapt via vwExtraKeyItem); chances 5% [D] |
| cruor/EXP | see NM-DETAILS | ? | no |  |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (Jeuno path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Sarimanok (East_Ronfaure)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 94-95 | ? | no | no level source; NPCLogger level unreliable. Ask user. |
| mobType | 2 | ? | no |  |
| main/sub job | THF/BLM | ? | no |  |
| HP | 37254 | C | partial | set 2026-10-07 from hptrack kill estimate (35765-40074); was formula. Single capture. |
| skills | list 198 | C | partial | capture: Crosswind id 1718 anim 1194 matches DB. Other four (Wind Shear, Obfuscate, Zephyr Mantle, Ill Wind) not seen in capture. |
| spells | list 440 | C | partial | capture: Silencega id 359 matches (157, 185, 359 in list). Others not seen. |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | Vivid Periapt of Readiness | ? | no | no periapt message in capture (may already be owned); 5% random in DB. Check forum. |
| cruor/EXP | 5000 / 5000 (stage 1) | C | yes | capture: 5000 exp, 5000 cruor (at +0%). |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Cottus (East_Ronfaure_[S])

Ledger filled 2026-10-07 from: capture Raguza 2021.03.27 (`Playthrough Captures/voidwatch_captures/extracted/VW - Cottus`, caplog + npclogger + hptrack + actionview), BG Wiki `Cottus` page (offline dump), BG forum thread (#6, #44, #207, #248, #289, #613, #616, #646), `UNIMPLEMENTED.md`, `KI-VERIFICATION.md`.
Capture covers a ~70 s kill by a small group with 3 cells; Cottus used only 2 TP moves in it, so skill coverage is thin.

| field | value (DB/script) | source | verified | note |
|---|---|---|---|---|
| spawn gate | Crimson Stratum Abyssite (KI 366) + voidstone; event 6000 | C | yes | `CS Event 6000 ... 366`; "voidstone resonates with the crimson stratum abyssite" |
| rift positions (3) | (288,-61,368) (183,-20,-315) (434,-51,315) | C, W | yes | W grid refs G-10, H-5, I-6; capture rift 17109850 at (288,-61.5,368) |
| mob/pyxis/rift ids | mob 17109718, rift 17109850, pyxis 17109853 | C | yes | all three seen in NPCL |
| time limit | 30 min | C | yes | "You have 30 minutes" |
| model (look) | 0000E302 | C | yes | npclogger look matches `mob_pools.modelid` |
| family | Gigas (328), Briarius model | W, B (#613/#646) | yes | "Cottus is pretty much Briarius" |
| level | 80-85 | ? | **no** | NPCLogger level byte says 95, but the same field says 95 for Pancimanci, which the user states is 83 — field is not a usable level source. No ground truth for Cottus. |
| mobType | 0 | ? | no | BG Wiki class = VWNM; user ruled Pancimanci non-NM. Cottus unchecked. |
| main/sub job | BST/BST (LSB) | F=COR per UNIMPLEMENTED | no | BG Wiki job field blank. Unresolved. |
| HP | 45408 | C | partial | fixed 2026-10-07 from hptrack estimate (range 44501-45998). Single capture; confirm with a second. |
| skill: Impact Roar (664) | in list 1162, anim 408 | C | yes | actionview: ID 664, anim 408, msg 188 |
| skill: Trebuchet | id 1636, anim 1132 | C | yes | built 2026-10-07: heavy single-target ranged, resets hate. Damage multiplier [D]. |
| skill: Grand Slam (665) / Power Attack (666) | in list 1162 | D | no | Briareos-style rows reused; not seen in capture |
| skill: Mercurial Strike | NO ROW | W, F | missing | every ~45 s per W; 111..1111 damage picks next WS |
| skill: Colossal Slam | NO ROW | J | missing | |
| ranged attack | none | J | missing | occasional |
| spells | none (list 0) | J, B #613 | partial | no spell use seen in capture; consistent |
| traits | Double Attack 10 | J (trait), D (amount) | partial | W also says minor Regain: not implemented |
| Pyxis rare drop | Roller's Ring (11667) | B #248/#289 (player reports), J, F | yes | item id checked vs `item_basic`; drop rate 10% x (1+red) is D |
| key item | Vivid Periapt of Readiness (1796), always | C, KI-VERIFICATION | yes | fixed 2026-10-07: granted to every alliance member in zone on kill (Cottus.lua). |
| cruor | 5000 x green | C | yes | 11250 = 5000 x 225% green |
| EXP | 5000 x yellow | C | yes | 11250 limit points, yellow 225% |
| final lights (this run) | n/a | C | n/a | B209 R309 Y225 G225 W100. Forum run (#6): B270 R390 Y225 G225 W75 — lights vary by run/cells. |
| message ids (z81) | 8109 materialize, 8197 relinquished | V | yes | capture shows 8110/8198: consistent +1 capture offset, script ids text-checked vs dialog.yml |
| Pyxis csid | 6003 | C | yes | params 1132, 748 (meaning unknown) |

Open items for Cottus: level, mobType, job, second HP capture, Mercurial Strike / Colossal Slam rows (no verified skill ids, not built), Regain.
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Ildebrann (Ifrits_Cauldron)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 98-99 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/BLM | ? | no |  |
| HP | 129300 | ? | no | no capture; BG Wiki lists only rifts, tier and treasure (no stats). BG Wiki page is empty. |
| skills | list 1168 (+Spike Flail 1280) | J | partial | JP: Tebbad Wing, Inferno Blast, Touchdown, Absolute Terror, Baleful Roar, Fiery Breath, Spike Flail; Spike Flail added 2026-10-07 |
| spells | Fire V, Firaga IV, Firaja | J | partial | BLM per JP wiki; regain+regen, fire/ice resist, magic dmg -50% |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | see NM-DETAILS | ? | no |  |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling Petrifact (Ashen path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## HraunDragon (Ifrits_Cauldron)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 95-96 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | WAR/WAR | ? | no |  |
| HP | 15900 | ? | no |  |
| skills | list 1177: Voidsong, Petro Eyes, Body Slam, Flame Breath | J, U | partial | 2 per rift, no shared hate, respawn when Ildebrann flies; own list created 2026-10-07 |
| spells | list 0 | ? | no |  |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | see NM-DETAILS | ? | no |  |
| mods | see NM-DETAILS | ? | no |  |

## Belphoebe (Jugner_Forest)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | see summary | ? | no | no level source; NPCLogger level unreliable. |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/BLM | ? | no |  |
| HP | 61641 | C | partial | set 2026-10-07 from hptrack (61026-61840); was formula. Single capture. |
| skills | list 1174: Spring Breeze 2195 | C | yes | added 2026-10-07; was none. Capture: Spring Breeze id 2195 anim 1583 matches DB. |
| spells | list 446 + Thunder V | C | partial | Thunder V (168) added 2026-10-07. Capture also: Stun, Stonega III, Graviga, Blizzaja, Addle all in list. |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | 6000 cruor | C | yes | capture: 6000 cruor. |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Kholomodumo (Jugner_Forest_[S])

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 93-94 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/BLM | ? | no |  |
| HP | 60436 | C | yes | hptrack Est.HP 60436 (57416-60987), set earlier. |
| skills | list 1172 | B/C | partial | Accursed Armor/Amnesic Blast/Ecliptic Meteor from forum+capture; damage/duration [D]; plain Meteor has no skill row |
| spells | none | C | yes | capture shows no spells cast. |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | W/F | no | client-id check pending |
| cruor/EXP | 6000 base (stage 3) | C | yes | 9660 = 6000 x 161% green. |
| mods | see NM-DETAILS | ? | no |  |
| cruor | — | C | yes | 9660 = 6000 x 161% green (Raguza 2021.03.28) |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Hahava (King_Ranperres_Tomb)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | see summary | ? | no | no level source; NPCLogger level unreliable. |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/WAR | ? | no |  |
| HP | 71785 | C | partial | set 2026-10-07 from hptrack (71519-72052, midpoint); was formula. Single capture. |
| skills | list 1175: Yaksha Stance, Oblivion, Bliss, Raksha Stance, Illusion | C | partial | added 2026-10-07; matched by ANIM (1900/1903/1902/1904/1906), capture ids 2714/2717/2716/2718/2720 differ from DB. Three unnamed skills (capture ids 2711-2713, anims 1897-1899) have no DB row: **missing**. |
| spells | list 447 | C | yes | capture: Fire IV, Fire V, Firaga III/IV, Stun, Slowga, Silencega all in list. |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | 6500 cruor | C | yes | capture: 6500 cruor. |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Stachysaurus (La_Theine_Plateau)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 96-97 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | WAR/WAR | ? | no |  |
| HP | 193000 | ? | no | no capture; BG Wiki lists only rifts, tier and treasure (no stats). |
| skills | list 1171 | ? | no |  |
| spells | list 0 | ? | no |  |
| Pyxis drops | 4 rares/materials | W | yes | wiki: Hreysti Helm, Ogier's Gauntlets, Brego Helm, Riftsand. Matches. |
| key item | Vivid Periapt of Glory | W | yes | matches wiki. |
| cruor/EXP | see NM-DETAILS | ? | no |  |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (Jeuno path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Ogbunabali (Maze_of_Shakhrami)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | see summary | ? | no | no level source; NPCLogger level unreliable. |
| mobType | 2 | ? | no |  |
| main/sub job | SAM/SAM | ? | no |  |
| HP | 56615 | C | partial | set 2026-10-07 from hptrack (52213-57437); was formula. Single capture. |
| skills | list 1164 | C | **mismatch** | Venom Spray matches (DB 277 anim 811). Mandibular Bite: capture anim 1273 vs DB 279 anim 813, different move; no DB row for anim 1273. |
| spells | list 0 | ? | no |  |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | 5500 base (stage 2) | C | yes | capture 7040 = 5500 x 128% green; matches stage 2 base. |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Lord_Asag (Meriphataud_Mountains)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | see summary | ? | no | no level source; NPCLogger level unreliable. |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/RDM | ? | no |  |
| HP | 53000 | C | partial | set 2026-10-07 from hptrack (50123-54906); was formula. Single capture. |
| skills | list 1165 | C | yes | capture: Wings of Gehenna 2110, Nosferatu's Kiss 2108 match. |
| spells | list 448 | C | yes | capture: Fire IV, Firaja, Paralyga, Addle all in list. |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | 6000 cruor | C | yes | capture: 6000 cruor. |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## SallowSeymour (North_Gustaberg)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 100-101 | ? | no | no level source. |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/BLM | ? | no |  |
| HP | 34772 | C | partial | set 2026-10-07 from hptrack (34633-35011); was formula. Single capture. |
| skills | list 1163 | C | **mismatch** | Tremors matches (anim 171). Mud Stream (capture id 2645 anim 1839) has no DB row: **missing**. |
| spells | list 445 | C | yes | capture: Stonega II/III, Stone IV, Slowga all in list. |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | 5000 cruor | C | yes | capture: 5000 cruor; also Indigo Stratum Abyssite + 2 voidstones. |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Krabimanjaro (Ordelles_Caves)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | see summary | ? | no | no level source; NPCLogger level unreliable. |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/PLD | ? | no |  |
| HP | 47578 | C | partial | set 2026-10-07 from hptrack (47104-50085); was formula. Single capture. |
| skills | list 1159 | C | yes | capture anims match DB: Venom Shower 2512, Bubble Curtain (anim 187), Scissor Guard (anim 189). |
| spells | list 439 + Sleepga | C | partial | Sleepga (363) added 2026-10-07. Water V, Graviga, Silencega in list. |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | 5500 cruor | C | yes | capture: 5500 cruor. |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Melancholic_Moira (Pashhow_Marshlands_[S])

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 92-95 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | WAR/WAR | ? | no |  |
| HP | 50796 | C | yes | hptrack Est.HP 50796 (50290-55747, method L). Source corrected from kill-time estimate. |
| skills | list 1173 | D | no | capture showed no mob TP moves; skill rows are design guesses |
| spells | list 0 | ? | no |  |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | V | yes | client id 1810 per KI-VERIFICATION.md |
| cruor/EXP | 6000 base (stage 3) | C | yes | 12300 = 6000 x 205% green. |
| mods | see NM-DETAILS | ? | no |  |
| cruor | — | C | yes | 12300 = 6000 x 205% green (Raguza 2021.03.27) |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Aello (RuAun_Gardens)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 93-95 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/BLM | ? | no |  |
| HP | see NM-DETAILS | ? | no | no capture; BG Wiki lists only rifts, tier and treasure (no stats). |
| skills | Rending Talons, Typhoean Rage, Shrieking Gale, Wings of Agony | J | partial | Kaleidoscopic Fury (<50% HP) has no Lua yet; Shrieking Gale summons 3 handmaidens |
| spells | Fire V, Firaga IV, Firaja, Slowga, Addle, Stun | J | partial | Addle/Stun AoE, no Silencega [J] |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | Atmacite of Unity | J, U | partial | granted via vwExtraKeyItem, chance 5% [D]; Aello drops extended per JP wiki |
| cruor/EXP | see NM-DETAILS | ? | no |  |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling Petrifact (Ashen path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Aellos_Handmaiden (RuAun_Gardens)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 90-92 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | RDM/WHM | ? | no |  |
| HP | 0 (formula) | ? | no |  |
| skills | list 1176: Lethe Arrows | J | yes | spells Protectra V, Shellra V, Aero IV, Holy, Aeroga III, Paralyga, Silencega [J] |
| spells | list 442 | ? | no |  |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | see NM-DETAILS | ? | no |  |
| mods | see NM-DETAILS | ? | no |  |

## Smierc (Tahrongi_Canyon)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 92-95 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/BLM | ? | no |  |
| HP | 142000 | ? | no |  |
| skills | list 1170 | ? | no |  |
| spells | list 453 | ? | no |  |
| Pyxis drops | 4 | W | yes | wiki: Devourer, Praeco Doublet, Athos's Gloves, Riftsand. Matches. |
| key item | Vivid Periapt of Glory | W | yes | matches wiki. |
| cruor/EXP | see NM-DETAILS | ? | no |  |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (Jeuno path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Ig-Alima (Valkurm_Dunes)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 119-120 | ? | no |  |
| mobType | 2 | ? | no |  |
| main/sub job | WAR/BLM | ? | no |  |
| HP | 161800 | ? | no |  |
| skills | list 1167 | ? | no |  |
| spells | list 450 | ? | no |  |
| Pyxis drops | 8 items with per-item % | U | user-stated | dropRates: Borealis 0.2, Hoarfrost Blade 4.1, Dhampyr Sword 5.7, Wroth Scythe 18.5, Ogier's Surcoat 2.6, Heavy Metal 12.8, Riftdross 3.6, Riftcinder 1 (percent) |
| key item | Atmacite of the Valiant + Vivid Periapt of Vigilance | U, F | partial | both granted (periapt via vwExtraKeyItem); chances 5% [D] |
| cruor/EXP | see NM-DETAILS | ? | no |  |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (Jeuno path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Lancing_Lamorak (West_Ronfaure)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 94-95 | ? | no |  |
| mobType | 0 | ? | no |  |
| main/sub job | BLM/THF | ? | no |  |
| HP | 106500 | ? | no |  |
| skills | list 1169 | ? | no |  |
| spells | list 452 | ? | no |  |
| Pyxis drops | 4 items with per-item % | U | user-stated | dropRates: Athos's Boots 5.2, Blithe Mantle 26.5, Brego Gloves 2.6, Riftsand 25.8 (percent) |
| key item | Vivid Periapt of Catalysis | U, F | partial | DSP id 1781; client-id check pending; chance 5% [D] |
| cruor/EXP | see NM-DETAILS | ? | no |  |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (Jeuno path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Virvatuli (West_Sarutabaruta)

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | see summary | ? | no | no level source; NPCLogger level unreliable. |
| mobType | 2 | ? | no |  |
| main/sub job | BLM/WAR | ? | no |  |
| HP | 33343 | C | partial | set 2026-10-07 from hptrack (33011-33775); was formula. Single capture. |
| skills | list 1160 | C | yes | capture: Corpse Breath 2511 matches. |
| spells | list 443 | C | yes | capture: Silencega, Blizzaga III in list. |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | 5000 cruor | C | yes | capture: 5000 cruor. |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |

## Pancimanci (West_Sarutabaruta_[S])

| field | value (snapshot) | source | verified | note |
|---|---|---|---|---|
| level | 83 | U | user-stated | plain mob, no Pyxis per user |
| mobType | 0 | U | user-stated | not an NM |
| main/sub job | MNK/BLM | D | no | sub BLM so CalculateStats allocates MP (fix 2026-10-07) |
| HP | 0 (formula) | U | user-stated | capture hptrack shows 47878 (47401-47886) but user states plain level-83 mob, easy to kill; left on formula. Revisit if too weak. |
| skills | list 1161 + Scream | C | partial | Dream Flower (anim 45) matches; Scream (anim 50 = skill 306) added 2026-10-07. Fatal Scream (capture id 2387, anim 1660) has no DB row: **missing**. |
| spells | list 444 | C | yes | capture: Aeroga III, Stonega III, Addle all in list. |
| Pyxis drops | see NM-DETAILS | ? | no |  |
| key item | see NM-DETAILS | ? | no |  |
| cruor/EXP | 5000 (stage 1) | C | yes | capture: 5000 cruor. |
| mods | see NM-DETAILS | ? | no |  |
| petrifacts | Beguiling/Seductive/Maddening Petrifact (three-nation path) | U | partial | rare per member, VW_PETRIFACT_RATE 5% x (1+red) [D, tunable]; paths per user 2026-10-07; KI ids 1556-1558 [U] |
