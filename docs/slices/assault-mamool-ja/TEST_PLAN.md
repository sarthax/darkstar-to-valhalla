# Mamool Ja Training Grounds Assault 1-4 - Live Test Plan

Package: `mamool_ja_training_grounds_missions_1-4`. Mission scope: Imperial Agent Rescue (11), Preemptive Strike (12), Sagelord Elimination (13), Breaking Morale (14). Missions 5-10 are intentionally excluded (do not test).
Prerequisites (apply first, test those plans first): `mercenary_rank_promotions`, `assault_lockbox_appraisal`, shared C++ engine fixes.
Use a non-GM character for pass/fail results; use a GM character only for setup (`!addassaultpoints`, `!wa`, `!tp`, `!checknav`, `!gotoinstid`, `!showhelper`).

## A. Install checks
| # | Step | Expected | Result |
|---|------|----------|--------|
| A1 | Engine rebuilt (Release x64), SQL imported in manifest order incl. `instance_gap_npc_list`, `instance_gap_mob_spawn_points`, `instance_list`, `instance_entities`; Lua copied; `.nav` in navmeshes; map-server restarted | Server starts, no Lua/SQL errors in map log | |
| A2 | Zone into Mamool Ja Training Grounds | No errors; zone NPCs present | |
| A3 | Map log scan after full run | No `No Valid Function`, nil-index, or missing-pool errors | |

## B. Access / entry
| # | Step | Expected | Result |
|---|------|----------|--------|
| B1 | Talk to Isdebaaq without orders | Correct refusal text, no menu | |
| B2 | Obtain MAMOOL_JA_ASSAULT_ORDERS (rank/ID tag per `mercenary_rank_promotions`) | Mission menu opens, only ranks you qualify for selectable | |
| B3 | Enter each mission as solo, then as a party | Everyone placed at correct entry position, mission text shown | |
| B4 | Leave and re-enter instance | Fresh instance, no stale state | |

## C. Per-mission playthrough
| # | Mission | Steps | Expected | Result |
|---|---------|-------|----------|--------|
| C1 | Imperial Agent Rescue (11) | Enter, complete objective, exit via Rune of Release | Objective completes, rewards given, no stuck state | |
| C2 | Preemptive Strike (12) | Enter, complete objective, exit via Rune of Release | Door/wall props (_1u9 to _1uj) open when intended; record which animation value means open | |
| C3 | Sagelord Elimination (13) | Enter, complete objective, exit via Rune of Release | Objective completes, rewards given, no stuck state | |
| C4 | Breaking Morale (14) | Enter, complete objective, exit via Rune of Release | Currently kill-all-18; record whether the objective feels right vs the 'steal supplies' name | |

## D. Common instance mechanics (run for each mission)
| # | Check | Expected | Result |
|---|-------|----------|--------|
| D1 | Kill-target mobs aggro an endgame character | They aggro autonomously (ALWAYS_AGGRO) | |
| D2 | Mobs spawn at real positions, none missing | All expected mobs present and reachable | |
| D3 | Mobs path normally (not stuck in walls); doors/props open/close visually | Matches mission design | |
| D4 | Timer expiry (let time run out) | Failure text, clean ejection, no hang | |
| D5 | Party wipe / all dead | Fails cleanly | |
| D6 | Completion: Rune of Release appears and works | Awards assault points, exits correctly | |
| D7 | Ancient Lockbox appears/opens where designed | Drops "???" item (see `assault_lockbox_appraisal`) | |
| D8 | Assault points / promotion points awarded and capped correctly | Matches rank rules | |
| D9 | Relog/zone mid-mission | Rejoin or clean eject, no corrupt state | |
| D10 | Rune map-grid message text | Matches capture grid reference | |

## E. Known risks to watch
- Breaking Morale objective text vs mission name mismatch is unresolved.
- Preemptive Strike door prop open/closed animation values not live-verified.
- Pool 3437 skill_list overwrite and pool 2531 roam mods were added 2026-09-20; confirm those mobs use the right skills / roam.

## Record
- Server build + date:
- Test character (rank / job / level):
- Failures and map-log excerpts:
