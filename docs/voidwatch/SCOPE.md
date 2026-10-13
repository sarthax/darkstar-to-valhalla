# Scope — Voidwatch for DSP

## Systems entailed (from Phase 0; wiki-derived items need verification)
| # | System | Notes | Local evidence |
|---|---|---|---|
| 1 | Voidwatch Officer NPCs (~18 field/city + 5 service towns) | issue stratum abyssites, Voidstones, Ops quests, periapts/ascent items for cruor | EventsDump, wiki, DSP npc_list rows |
| 2 | Voidwatch Purveyor NPCs (~20) | sell Voiddust / ascent items for CP / Allied Notes / Imperial Standing | same |
| 3 | Atmacite Refiner NPCs (~20) | infuse/purge/enrich atmacites | same |
| 4 | Planar Rift NPCs (3 per VW zone) | spawn NM; atmacite functions; ascent-item trade; Phase Displacer→Void cluster | npc_list rows both |
| 5 | Riftworn Pyxis | post-kill per-player loot pool, exp, cruor, KI rewards, 3-min lifetime | npc_list rows; Abyssea Pyxis spec is precedent |
| 6 | VWNM mobs (~71, ~55 zones) | pools/groups/spawns + per-NM scripts (adds, TP moves, <50% phases) | LSB sql (data only); behavior unknown |
| 7 | Key item economy | Voidstone (stock + 20h recharge), abyssites, periapts, atmacites, void cluster | KI ids match LSB in DSP |
| 8 | Cruor currency | earning from VW, spending at Officers; exists for Abyssea | charutils.cpp |
| 9 | Alignment/path/tier logic | ascent items change spectral alignment; abyssite tier gates NM | **main wiki page missing from dump** |
| 10 | Status effect 475 `voidwatcher` | already in DSP enum; behavior unspecified | status_effect.h |
| 11 | Voidwatch quest line (30 quests, Ops: Border Crossing → Provenance) | Crystal War era storyline | wiki quest pages |
| 12 | Provenance + Radiance battlefields (Beguiling/Seductive/Maddening) | endgame tier; 6-spawn groups | LSB sql, wiki |
| 13 | Loot tables | per-NM treasure tiers ({{xxdrop}} etc.), spell scrolls, crafting mats | wiki partial, FFXIDB option (see memory: ffxidb drop-rate source) |
| 14 | Client/server packet/menu support | Officer/Rift menus are event-driven (CSIDs) | EventsDump, dat-extractor |

## Phasing of scope (proposed tiers)
- **Core loop (MVP):** 1, 4, 5, 6 (a handful of NMs), 7, 8, 10 — one zone, one path, end-to-end.
- **Economy:** 2, 3, 9, 13, remaining NMs.
- **Content:** 11 quests, 12 Provenance/Radiance, full NM roster, all zones.

## Out of scope (until user says otherwise)
- Retail-exact NM stats/AI beyond what captures/wiki can substantiate.
- Abyssea (separate project), Topaz-side implementation (target is DSP; DSP-only per 2026-09-03 pivot).
- Engine rewrites; prefer Lua + SQL, minimal C++.
