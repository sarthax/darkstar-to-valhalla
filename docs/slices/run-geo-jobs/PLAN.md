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
