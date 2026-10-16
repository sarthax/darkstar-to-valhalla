# RUN / GEO Spell Sources — Research (2026-10-16)

**Scope: research only. Nothing here is implemented. No SQL, Lua or branch changes were made.**
Evidence tags: **[LSB]** read from landsandboat-reference scripts, **[DSP]** read from D:\Claude\dsp-branches / live DB, **[WIKI]** BG Wiki offline dump (reference, not truth), **[OPEN]** not verified.
Live web cross-check (BG Wiki live, FFXIclopedia, wikiwiki.jp) has NOT been done yet; see Open Items.

## 1. Summary

| Spell group | Count | Source | DSP status |
|---|---|---|---|
| Indi- spells | 30 | Scrolls sold in Western Adoulin I-5 (Ishvad 16, Eukalline 14) | **Done** [DSP]: Ishvad.lua / Eukalline.lua stock all 30, prices match wiki |
| Geo- spells | 30 | No scrolls. Learned at a Geomantic Reservoir (one per spell) | **Gap**: 24 npc_list rows, **no script**; 6 rows missing |
| RUN spells (39 wiki pages checked) | 39 | Mostly existing WHM/RDM/BLU-style vendors and BCNM drops | **Mostly already available** via shared vendors; Foil stocked by Ledericus |

## 2. Indi- spells [WIKI + DSP]
- Ishvad (Western Adoulin): Poison 100, Voidance 372, Precision 1400, Regen 2335, Attunement 2425, Focus 6692, Barrier 10926, Refresh 21000, CHR 21000, MND 23940, Fury 25270, INT 30912, AGI 32640, Fend 34000, VIT 43740, DEX 46440.
- Eukalline: Acumen 52080, STR 53460, Slow 53460, Torpor 61875, Slip 83160, Languor 94185, Paralysis 103040, Vex 504000, Frailty 537030, Wilt 576300, Malaise 617100, Gravity 617100, Fade 703800, Haste 709716 (DSP value).
- Extra wiki-listed sources (not needed to be playable): Indi-Poison quest reward; Fade/Frailty/Gravity/Malaise/Vex also drop from Orb-type battlefields (Qu'Bia Arena, Horlais Peak, Chamber of Oracles, Throne Room). Indi-Haste page lists no extra source.
- **No work required** unless we want the secondary drop sources.

## 3. Geo- spells — Geomantic Reservoirs
Mechanic [WIKI + LSB]: click the reservoir as **main job GEO**, must already know the matching Indi- spell and not yet know the Geo- spell. LSB plays event **15000** with a random 230–300 value, then `addSpell(geoSpell)` and prints LEARNS_SPELL. The wiki's skill-up "!!" proc (guaranteed Geomancy skill-up if clicked on the blue icon) is a TODO in LSB too. The wiki also states a GEO level ≥ Indi level + 4; LSB does **not** enforce level. [OPEN: decide whether to enforce]

LSB script per reservoir: `scripts/zones/<Zone>/npcs/Geomantic_Reservoir[_2].lua`, shared logic `scripts/globals/geomantic_reservoir.lua`. Positions below are from the LSB `!pos` headers.

| Geo- spell | Zone (id) | LSB !pos x y z | DSP npc_list row |
|---|---|---|---|
| Poison | East Ronfaure (101) | 379.572 -39.057 57.502 | present |
| Refresh | La Theine Plateau (102) | 400.026 70.700 365.002 | present |
| Regen | La Theine Plateau (102) | -5.052 54.625 -405.673 | present x2; one at 0,0,0 (dynamic/hidden, fix needed) |
| Barrier | Batallia Downs (105) | -677.645 -32.000 157.981 | **MISSING** |
| Precision | Konschtat Highlands (108) | -246.883 40.168 301.159 | **MISSING** |
| MND | Rolanberry Fields (110) | 243.900 -31.194 -255.254 | **MISSING** |
| INT | Beaucedine Glacier (111) | 8.527 -59.729 -104.909 | present (1 row) |
| Acumen | Beaucedine Glacier (111) | 275.620 -0.137 247.116 | **MISSING (2nd row)** |
| Torpor | Xarcabard (112) | -141.138 -34.642 127.197 | present |
| Voidance | Tahrongi Canyon (117) | 78.056 15.998 117.224 | present |
| Fury | Sauromugue Champaign (120) | 384.047 45.466 384.224 | present |
| Attunement | Qufim Island (126) | 185.136 20.528 -208.424 | present |
| DEX | Behemoth's Dominion (127) | -232.162 -20.199 4.927 | present |
| Slow | Beadeaux (147) | 162.194 -3.250 38.661 | present |
| Fend | Davoi (149) | 173.098 3.643 -386.962 | present |
| AGI | Castle Oztroja (151) | -210.032 -16.000 95.255 | **MISSING** |
| Languor | Bostaunieux Oubliette (167) | -13.337 0.009 -333.022 | present |
| CHR | Lower Delkfutt's Tower (184) | 340.285 -15.601 19.968 | present |
| Slip | Eldieme Necropolis (195) | 10.804 -0.031 -18.927 | present |
| Focus | Gusgen Mines (196) | -20.869 -59.736 -180.233 | present |
| STR | Crawlers' Nest (197) | -170.623 -1.376 347.089 | present |
| VIT | Garlaige Citadel (200) | -83.898 5.568 139.600 | present |
| Paralysis | Fei'Yin (204) | 4.239 -0.009 255.206 | present |
| Wilt | Yahse Hunting Grounds (260) | 412.263 4.161 111.199 | present |
| Frailty | Ceizak Battlegrounds (261) | -450.391 0.001 -0.491 | present |
| Gravity | Foret de Hennetiel (262) | 232.687 -0.500 152.658 | present (zone confirmed by LSB) |
| Malaise | Morimar Basalt Fields (265) | -166.764 -1.377 -49.194 | present |
| Fade | Morimar Basalt Fields (265) | 337.643 -16.745 305.544 | present |
| Haste | Marjami Ravine (266) | 189.015 -40.000 241.025 | **MISSING** |
| Vex | Upper Delkfutt's Tower (158) | -358.799 -175.425 82.985 | present |

(30 spells = 30 LSB reservoirs. DSP has 24 rows; need +6 = Barrier, Precision, MND, Acumen, AGI, Haste. Every present row also needs its own Spell-to-reservoir mapping by position because DSP rows share a single name `Geomantic_Reservoir`.)

### Implementation notes for a later session (NOT done)
- DSP has no `Geomantic_Reservoir.lua`. Because DSP resolves scripts by npc name, per-zone scripts are needed (zones with two reservoirs: 102, 111, 265 must disambiguate by npc id or position; LSB uses `_2` suffix names, which in DSP means separate npc_list names).
- Existing DSP rows must be compared with the LSB coordinates above; ids and positions must come from a fresh DAT/`!logpos`/navmesh check (project rule: Y inverted, `!checknav` first, never invent ids).
- Event 15000 and the LEARNS_SPELL / NOTHING_OUT_OF_ORDINARY text ids are zone-specific in DSP's client data. They must be pulled from dialog.yml per zone. [OPEN]
- Spell and item ids for Geo- spells, plus `indiSpellMap`, need verification against DSP's spell_list (names differ from LSB enums).

### Wiki vs LSB discrepancies to resolve
- Wiki says GEO level gate = Indi level + 4; LSB has none.
- Wiki Indi-Gravity level 88 vs Geo-Gravity 92 in the same wiki; Gravity location: wiki "Foret de Hennetiel I-7", LSB zone 262. Treat LSB as authoritative for location.
- Wiki per-spell GEO levels (5,8,14,19,20,26,32,34,34,37,38,40,43,44,46,49,50,52,52,56,62,68,72,74,80,86,92,92,97,98) should be checked against DSP `spell_list` job levels. [OPEN]

## 4. RUN-learnable spells [WIKI]
Most RUN spells are already purchasable from shared vendors (no RUN-specific sources needed). Wiki sources:

| Spell (RUN lvl) | Source |
|---|---|
| Barstone 4, Barsleep 6, Barwater 8, Barpoison 9, Barparalyze 11, Baraero 12, Barfire 16, Barblind 17, Barblizzard 20, Barsilence 22, Barthunder 24, Barvirus 38, Barpetrify 42 | Hasim, Lower Jeuno H-9 (156–15,120 gil) |
| Baramnesia 76 | Tya Padolih, Mhaura (27,820) |
| Aquaveil 15 | Regine / Kususu (368) |
| Shell 10/30/50/70/90, Protect 20/40/60/80 | nation vendors, Selbina, Hasim, Zafif, Brave Ox, Shohrun-Tuhrun (IV/V partly Abyssea/Adoulin) |
| Blink 35, Stoneskin 55 | nation vendors, conquest-rank gated |
| Regen 23 / II 48 | Tya Padolih; III 70 no vendor listed; IV 99 Gekko, Port Jeuno (50,400) |
| Refresh 62 | BCNM drops (Balga's Dais: Royal Succession / Steamed Sprouts) |
| Phalanx 68 | BCNM drops (Toadall Recall, Factory Rejects) |
| Flash 45 | Zafif (Al Zahbi 27,600), Brave Ox (32,200) |
| Foil 58 | Ledericus, Western Adoulin H-5, 83,160 (RUN only) — **already in DSP Ledericus.lua** [DSP] |
| Crusade 88 | Brave Ox 143,451; ROE |
| Blaze Spikes 45 | Amalasanda (Lower Jeuno) 10,428; quest Know One's Onions; Horlais Peak Shooting Fish |
| Ice Spikes 65 | Waughroon Shrine Royal Jelly, Balga's Dais Steamed Sprouts; quest Inside the Belly |
| Shock Spikes 85 | Hilkomu-Makimu, Mamaroon (Nashmau 9,000), Chutarmire (Selbina 8,280) |
| Temper 99 | BCNM/Orb drops (Monarch Linn Nest of Nightmares, Walk of Echoes Sixth Walk, others) |

DSP vendor scripts present: Eukalline, Ishvad, Ledericus, Brave_Ox, Hasim, Gekko, Tya_Padolih, Zafif. [DSP]
**Not yet researched:** En- spells (Enfire etc.), Embolden/other RUN-unique spells, and whether DSP vendor inventories include each item listed above (only Foil confirmed). [OPEN]

## 5. Open items
1. Live web cross-check of Geo- levels/locations and RUN sources (BG Wiki live, FFXIclopedia, wikiwiki.jp).
2. Verify DSP `spell_list` rows, job levels and Geo-/Indi- spell ids; identify En-/Embolden coverage.
3. Per-zone dialog ids and event 15000 availability in the DSP client (use mission_toolkit/dat-extractor).
4. Decide level-gate enforcement and skill-up proc handling.
5. Audit DSP vendor stock for each RUN spell row in section 4.
6. Reservoir npc_list work: 6 missing rows, one 0,0,0 duplicate in zone 102, name/script mapping (see 3).
