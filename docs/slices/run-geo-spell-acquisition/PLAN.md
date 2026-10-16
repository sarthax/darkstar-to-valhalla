# Slice: run-geo-spell-acquisition

Branch `feature/run-geo-spell-acquisition` (cut from `main` cd6be08f76). Covers every way a player obtains RUN/GEO spells,
plus any spell effects not yet modeled, with their Lua and SQL. Research: `SPELL_SOURCES_RESEARCH.md` (read first).
Rules: never invent ids (verify spell/item/csid/text ids from a fresh same-session pull); `!checknav` coordinates; run
`tools/check_sql_id_collisions.py --file <sql> --db` and `tools/check_npc_ids.py` before import.

## Workstreams
| # | Stream | Scope | Status |
|---|---|---|---|
| W1 | Geomantic Reservoirs | 30 reservoirs: 6 missing npc rows (zones 105,108,110,151,266 + 2nd in 111), fix 0,0,0 row in 102, per-zone scripts + shared `geomantic_reservoir.lua`, event 15000, text ids, level gate decision, skill-up proc | code done 2026-10-16, untested in game. No level gate (matches LSB); skill-up proc and helper entities not modeled |
| W2 | Indi- scrolls | Already stocked (Ishvad/Eukalline). Optional: secondary Orb/BCNM drop sources, Indi-Poison quest reward | verified done |
| W3 | RUN spell vendors | Audit DSP vendor stock vs wiki table (Hasim, Tya Padolih, Zafif, Brave Ox, Gekko, Regine/Kususu, Amalasanda, nation vendors...) and add missing rows | not started |
| W4 | Drops/battlefields | BCNM/mob drops for Refresh, Phalanx, Ice Spikes, Temper, Orb-gated Indi- scrolls (mob_droplist/bcnm_loot; collision-check first) | not started |
| W5 | Quests/ROE | Know One's Onions, Inside the Belly, Crusade (ROE), Indi-Poison reward | not started |
| W6 | Spell effects | Audit spell_list rows + Lua for every GEO/RUN spell (Indi/Geo/Luopan, En-, Embolden, Temper, Crusade, Foil, Spikes...); implement missing effects/status | not started |
| W7 | Verification | Live web cross-check (BG Wiki live, FFXIclopedia, wikiwiki.jp), DSP spell_list levels, in-game test plan | not started |

## Not in this slice
Unlock quests (feature/run-geo-unlock-quests), job abilities/stats (feature/run-geo-jobs), gear acquisition.
