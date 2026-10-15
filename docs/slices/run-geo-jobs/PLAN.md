# RUN + GEO backport (LSB -> DSP/Valhalla) - PLAN
Branch: feature/run-geo-jobs (cut from main). Source: LSB baf0b36e snapshot in D:\Claude\DSP-LSB-Gap-Audit\evidence\lsb_snapshot\server-base.
Audit refs: findings/jobs/F-jobs-001.md, reports 09c/09p/09q/09r (F-07 remap tables in findings/enums/F07_*.csv).
Rules: no invented ids; every id verified against client DAT / F-07 remap this session; porting = strip `xi.` and resolve against DSP's own constants.

## Starting state in DSP (verified 2026-10-15)
- Job ids 21/22 + char_jobs/char_exp columns exist (battleentity.h:86-87, charutils.cpp).
- RUN effect ids exist: VALLATION 531, SWORDPLAY 532, PFLUG 533, EMBOLDEN 534, VALIANCE 535, GAMBIT 536, LIEMENT 537, ONE_FOR_ALL 538, BATTUTA 570, RAYKE 571, INUNDATION 597, RUNEIST_S_ROLL 600, runes IGNIS..TENEBRAE (check 518-530).
- GEO effect ids PARTLY missing: BOLSTER 513, BLAZE_OF_GLORY 569 present; COLURE_ACTIVE and the ~30 GEO_* aura effects are NOT in status_effect.h (ends 611, custom range starts 768). Real ids must come from client/LSB remap.
- 58 Indi/Geo spell rows in sql/spell_list.sql, all commented out. 7 RUN ability rows in sql/abilities.sql commented out (animation `???`, CE/VE placeholder 1/300).
- pet_list has 'Luopan' (id 75). No luopan pet script, no job_utils dir, no job points system.
## LSB work to port
- job_utils/rune_fencer.lua (879 ln), geomancer.lua (594 ln); globals/pets/luopan.lua
- 60 geomancy spell scripts; ~34 RUN/GEO ability scripts; ~25 effect scripts (geo_*, colure_active, warding_circle, runeists_roll); job tests.

## Phases
P0 Foundations (no gameplay): F-07 remap for effect/mod/ability ids; add missing GEO effect enum ids + any missing Mod ids; verify each against client DAT. Confirm client ships RUN/GEO (open gating question). Deliverable: ID_TABLE.csv with evidence.
P1 RUN data: abilities.sql real rows (ids via +16 remap, CE/VE from LSB, animations resolved), traits, skill_ranks/skill_caps/exp for job 22, merit/job-gift gating, spell access (Enhancing set, Foil etc.).
P2 RUN logic: new scripts/globals/job_utils/rune_fencer.lua adapted to DSP; ability scripts; effect scripts (rune effects, vallation/valiance, battuta, rayke...); C++ hooks as discovered (rune count cap, Mod hooks, damage SDT mods, Swipe/Lunge).
P3 GEO data: spell_list real rows, abilities, traits, skills (geomancy/handbell skill ids 'Handbell'/'Geomancy' - verify exist in DSP skill enum), instruments.
P4 GEO logic: Luopan pet spawn (C++ pet type, model per element, HP/despawn, Full Circle), Indi (self aura/ party radius) + Geo (luopan aura) via effect system, potency formula, Bolster/Blaze/Ecliptic/Life Cycle/Dematerialize/Lasting Emanation/Theurgic Focus/Widened Compass/Entrust.
P5 Integration: job change/unlock quests, equipment (job masks), packets (job/effect icon ranges), mobs using RUN/GEO job mobutils, tests, docs, TEST_PLAN.md.
Each phase = commit + tag slice/run-geo-jobs-vN on this branch; SQL as sql/slices/run-geo-jobs/*.sql with exact import commands.
## Risks
Job points absent in DSP (LSB reads them); unknown animation ids; client version gate; C++ pet/aura changes touch shared engine files (hunk-level ownership per BRANCH_PLAN).

## P0 result 1 - effect ids (docs/slices/run-geo-jobs/effect_id_diff.csv, LSB data/status_effects.yaml vs DSP status_effect.h)
- 37 RUN/GEO effects already MATCH by name+id (all rune effects 523-530, RUN 531-538, 568-571, Bolster, Entrust, etc.).
- 31 "ID-CONFLICT" are NOT drift: LSB names them geo_* (539-567, 580), DSP names the same numeric ids REGEN_II...WEIGHT_II / HASTE_II / RUNEIST_S_ROLL(600 = runeists_roll). Same client id, name-only difference. No remap needed; Lua should use DSP's names or add aliases.
- Only truly MISSING: colure_active = 612 (add EFFECT_COLURE_ACTIVE = 612 to status_effect.h; confirm in client before use).
- Correction to earlier claim: the GEO aura effects are NOT absent from the enum; only COLURE_ACTIVE is.
- Still to do in P0: Mod ids (F07_mod_remap.csv has 21 exceptions) used by rune_fencer/geomancer.lua, ability/spell/pet ids, client-ships-RUN/GEO check.

## P0 result 2 - Mod ids (mod_id_diff.csv)
- 66 Mods referenced by LSB rune_fencer/geomancer/luopan Lua: 28 SAME id in DSP, 38 MISSING from modifier.h (RUN/GEO-specific ones: SWORDPLAY 1008, INQUARTATA 963, PARRY_SPIKES 1022/1023, GAMBIT/LIEMENT/RAYKE_DURATION, GEOMANCY_SKILL 123, GEOMANCY_BONUS 961, INDI_DURATION 960, BOLSTER_EFFECT 1028, LIFE_CYCLE_EFFECT 1029, FULL_CIRCLE 1025, AURA_SIZE 1030, ...). All 38 target ids verified FREE in DSP modifier.h (Mods are server-internal, not client ids, so same numbers can be used).
- TRAP: LSB FIRE/ICE/WIND/EARTH/THUNDER/WATER/LIGHT/DARK_SDT = 54-61 share ids with DSP's FIRERES..DARKRES but SEMANTICS DIFFER: DSP stores damage reduction in 1000ths ("875=87.5%"), LSB SDT is base 10000 signed (positive = less damage). RES_RANK mods (192-199) do not exist in DSP at all. Vallation/Valiance/Gambit/Rayke/Pflug must be adapted with an explicit scale conversion (decide in P2), not a blind rename.
## P0 result 3 - ability ids (ability_id_diff.csv)
- LSB id - 16 == DSP id holds for all 40 LSB RUN/GEO abilities; DSP ability.h enum has all except swipe(328), vivacious_pulse(367), entrust(370).
- DSP sql/abilities.sql: 22 active (bolster, sforzo, runes, swordplay, one_for_all, ward, effusion, vivacious_pulse), 9 RUN commented (vallation, lunge, pflug, embolden, valiance, gambit, liement, rayke, battuta), 12 GEO + swipe + entrust absent.
- DSP staged rows are NOT retail: levels, recast, recastId wrong (e.g. vallation lvl20/300s vs LSB lvl10/180s/recastId 23; battuta has recastTime/recastId swapped). Use LSB values; DSP recastId=0 on every RUN row must be fixed (client recast timers).
- Animation ids: DSP's 291-302/327 equal LSB's (no drift). LSB's own animation values for vallation/pflug/valiance/gambit/liement/rayke/battuta/lunge are 0-8 (low, likely placeholders) -> mark UNVERIFIED, need client/capture.
- Message ids 660-672 (luopan/rune/swordplay/vallation...) come from LSB msg_basic.h; DSP message_basic.h lacks them. Must verify they exist in client 30170905_5 before use (open).

## P0/P1 results 4 (data tables)
- skill_ranks: identical to LSB for geo/run; only skill 45 handbell is commented out in DSP ("Does not display correctly in-game"). skill_caps/exp_base: same shape, rows exist for skills 44/45.
- traits: DSP 443 rows vs LSB 719. DSP has some job 21/22 traits; LSB adds tiers, accuracy bonus, cardinal chant (mod 959), elemental celerity (mod 901). LSB max HP/MP boost use mods 1095/1096 vs DSP 2/5 (mod-id drift): trait rows must be remapped, not copied.
- spell_list: DSP's 58 Indi/Geo rows (768+) are commented placeholders; LSB rows are real but have extra columns (family, radius, status_effect, status_effect_tier). Needs column-adapted import (P3).
- merit ids: DSP merit.h already has GEO/RUN merit enums (e.g. MERIT_LUNGE_EFFECT, MERIT_BATTUTA, MERIT_RAYKE); LSB merit.h grep returned nothing at that path (not compared yet).
- sql/slices/run-geo-jobs/run_abilities.sql and geo_abilities.sql: generated from LSB (id = LSB-16, radius column dropped, runes/ward/effusion/rune_enchantment excluded because DSP rows already exist). Import with `REPLACE INTO`; apply via `py -3 dbtool.py` or direct MariaDB. message1 (660-672), animation and recastId values are UNVERIFIED against the client. Not live until the user runs them.

## P0 foundations applied (code)
- modifier.h/status.lua: 32 mods added (RES_RANK 192-199 + single-id mods + ELEMENTAL_CELERITY 901, CARDINAL_CHANT 959). *_SDT mods deliberately NOT added (collide with FIRERES..DARKRES 54-61; scale decision pending).
- status_effect.h/status.lua: EFFECT_COLURE_ACTIVE = 612 (unverified vs client).
- ability.h: ABILITY_SWIPE 328, VIVACIOUS_PULSE 367, ENTRUST 370.
- Not compiled yet.

## P2 started: runes + Swordplay (Lua, DSP-style)
- scripts/globals/runefencer.lua (global table RUNEFENCER), 8 rune ability scripts + 8 rune effect scripts, swordplay ability/effect.
- Resist mapping: LSB MEVA -> DSP *RES mods; scale UNVERIFIED (bar spells add power directly, so same here). Merit/job-point bonuses are 0 (TODO). REQUIRE_RUNE message id 660 unverified.
- Not syntax-checked with a Lua interpreter (none found in the shell) and not tested in game. Needs the abilities SQL imported first.
