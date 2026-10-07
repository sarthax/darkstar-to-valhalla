# Roadmap

Legend: ⬜ not started · 🔧 in progress · ✅ done

| Phase | Goal | Status |
|---|---|---|
| 0 | Analysis: LSB/DSP/wiki state, scope, record-keeping | ✅ 2026-10-06 (see `research/FINDINGS-2026-10-06.md`) |
| 1 | Close research gaps (below) — no server edits | 🔧 step 1 done 2026-10-06; steps 2,5,6,7,8,9 done (9 pending ack); 4 done (captures ingested); 3 partial (weakness text decoded, per-zone ids open) |
| 2 | Design doc: data model, state vars, menu/CSID map, MVP definition | ✅ draft 2026-10-06 (DESIGN.md) |
| 3 | DSP data prerequisites: pools (22-col conversion), groups, spawn points, instance-less spawn mechanism; id guardrail | ⬜ |
| 4 | MVP vertical slice: one zone (suggest Ru'Aun Gardens/Aello — wiki-richest) end to end | ⬜ |
| 5 | Economy: cruor, Purveyor/Refiner, atmacites, periapts, voidstone stock | ⬜ |
| 6 | Roster expansion NM-by-NM (+ loot via FFXIDB), then quests | ⬜ |
| 7 | Provenance / Radiance, polish, packaging as backport package | ⬜ |

## Phase 1 — research gap closure (next actions)
1. ✅ DONE 2026-10-06 (see `research/WIKI-MECHANICS-DIGEST.md`, `research/wiki_raw/`). Original: Scrape missing BG Wiki pages: `Voidwatch` (main), `Category:Voidwatch`, Atmacite, Periapt, Ascent Item, Phase Displacer,
   Spectral alignment, Voidwatch Ops list (use `scrape_bg_wiki.py`; check how it handles ns 14 / redirects). Re-run inventory.
2. ✅ (roster found: +Kaggen, +Modron; CSV regen optional) Re-run inventory with fuller NM list (wiki "Notorious Monster" misses; reconcile Gasha/Pil/Wazir/Yalungur pool-name matching).
3. 🔧 PARTIAL (see research/CAPTURE-ANALYSIS-ZACH2GOOD.md) Decode Officer/Rift/Purveyor/Refiner events with `explore_event.py` + `dat-extractor` for CSIDs, menu options, param layout.
   Cross-check EventsDump numbering vs fresh dialog.yml (known off-by-1).
4. ✅ captures now exist (34 zach2good, ingested); remaining plan = weakness/stagger targeted pass. Original: no Voidwatch fight captures exist. Define what to capture on a retail-like source (Officer menu, Rift trade, NM spawn,
   fight packets, pyxis loot, cruor message ids) — ask user whether such captures can be obtained.
5. ✅ DONE (zone_audit.csv) Zone audit: which of the ~55 VW zones exist in DSP incl. [S] zones, Provenance, Walk of Echoes; confirm npc_list zone ids.
6. ✅ DONE (research/SKILL-AUDIT.md, POOL-GROUP-ID-PLAN.md) Diff DSP vs LSB: pool schema (22 vs 28 col), skill lists (e.g. Aello skill_list 471 in both?), `mob_skill_lists`/`mob_skills` present for VW TP moves
   (Rending Talon, Shrieking Gale, Wings of Agony, Typhoean Rage, Kaleidoscopic Fury…) — skills missing in DSP = engine/data work.
7. ✅ DONE (research/DESIGN-INPUTS-ABYSSEA-SPAWN.md) Study DSP Abyssea code (cruor, temp KI, pyxis) for reuse; study existing Valhalla `ABYSSEA_PYXIS_BACKPORT_SPEC.md`.
8. ✅ DONE 2026-10-06 (research/KI-VERIFICATION.md; client ROM/175/35.DAT via xi_tinkerer.parse_dmsg_table; corundum = 2065-2067)
9. ✅ RECOMMENDED, awaiting user ack (same doc) Decide spawn mechanism (normal-zone dynamic mob spawn vs BCNM-like) — see OPEN_QUESTIONS Q3.

## Risks
- Behavior fidelity: NM abilities/AI are undocumented locally → risk of "inventing" mechanics. Mitigation: flag unverified, ship simple versions.
- Engine gaps in DSP (skills, status 475 behavior, tier/alignment storage, per-player pyxis loot pool).
- Schema drift DSP↔LSB SQL; ID drift Topaz↔LSB does not apply to DSP KIs (verified) but NPC ids offset (DSP vs LSB) — always use DSP's own ids.
- Zone coverage / navmesh / spawn coordinates need `!checknav`-style verification (DSP side tool equivalent TBD).
