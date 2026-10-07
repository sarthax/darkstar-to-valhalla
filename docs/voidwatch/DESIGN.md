# Voidwatch for DSP — Design (Phase 2 draft, 2026-10-06)
Evidence tags: [C] retail capture, [V] verified local file/client, [W] wiki, [D] design choice (not retail-proven). Nothing here is implemented; no server edits made.

## 1. Retail loop to reproduce [C]
Officer (abyssite + voidstone KIs) -> Planar Rift click (csid 6000+idx) -> option 1 -> msgs "fiend materializes" + "voidstone expended" + 30 min, status 475 Voidwatcher -> NM spawns as ordinary zone mob (no instance) -> fight with weakness/stagger/blitz -> kill: cruor + limit points + "Final Spectral Alignment" -> Riftworn Pyxis (rift csid+3) shows up to 8 items -> obtain/relinquish. See research/CAPTURE-ANALYSIS-*.md, MESSAGE-IDS-RUAUN.md.

## 2. Architecture (reuse DSP Abyssea code; Lua + SQL, no C++ in MVP) [D]
| Piece | Approach | Precedent |
|---|---|---|
| Rift NPC | `onTrigger` per zone -> startEvent(6000+idx, 8 params); `onEventFinish` option 1 -> checks KIs, takes voidstone, SpawnMob, sets status 475 on party | Abyssea qm + Traverser stones |
| Spawn | `GetMobByID`/SpawnMob from mob group rows in the zone (group ids from POOL-GROUP-ID-PLAN, 18300+); despawn at 30 min or Rift reset | Abyssea NM spawns |
| Fight state | mob local vars: weakness list, stagger meter, alignment colours (blue/red/yellow/green/white), blitz timer; ticks via `onMobFight`, NOT entity:timer closures | project rule |
| Weakness hooks | WS + spells via existing take-listeners; **new** hooks for JA, pet/avatar/wyvern, automaton | Abyssea red/yellow/blue weakness (TextIDs 7318-7320) |
| Messages | per-zone TextIDs, block per MESSAGE-IDS-RUAUN offsets (10780-10914 in Ru'Aun); re-pull each zone | dialog.yml |
| Pyxis | spawn Riftworn Pyxis NPC after kill, per-player item pool (<=8), startEvent(6003+idx, items...), 3 min lifetime | Abyssea pyxis spec |
| Economy | cruor (existing Abyssea currency), abyssite/periapt/atmacite KIs (ids verified vs client) | KI-VERIFICATION.md |

## 3. State variables [D]
Player: voidstone stock + recharge timestamp (KI + char var), per-path abyssite tier KIs (existing KIs), cruor, status 475 end time. Mob (instance-less): weakness set, stagger, 5 alignment values (caps blue/red 350, yellow/green 225, white 100 [C]), blitz end time, participants list (for Pyxis eligibility).

## 4. Event/param contracts [V]/[C]
- Rift csid 6000-6002 params: p0-p2 raw (meaning unresolved), p3 = 3x7-bit, p4 = 3x4-bit packed (atmacite slots, unverified), p5, p6 raw, p7 = abyssite KI id; p6 = cruor in capture. Pad full 8.
- Pyxis csid 6003-6005: up to 8 item-id params, 0 = empty.
- Pad counts must match across call sites for same csid (project rule); confirm against capture before coding.

## 5. Simplified (invented) rules for MVP — must be flagged in code [D]
1. Blitz trigger: after ~9 weakness hits (or ~20 s first blitz) the hitting player's next hit "devastates" and starts a 7-30 s blitz. Retail rule unknown.
2. Weakness rotation interval/selection: use Abyssea getNew*Weakness analogue; "aura changes" msg 10905.
3. Reward quality/quantity scaling by blue/red alignment, exp by yellow, cruor by green; cruor base 5000/5500/6000/6500 by tier I-IV [C].
4. Pyxis item pool from FFXIDB/wiki drop data; selection method unknown.

## 6. MVP definition (Phase 4) [D]
One zone: **Ru'Aun Gardens / Aello** (pool/group/spawn from LSB converted per POOL-GROUP-ID-PLAN; confirm group ids against live DB and check mob_spawn_points mobid/dropId collisions first). End-to-end: Officer KIs (can be GM-granted initially) -> Rift -> Aello -> weakness/blitz -> cruor -> Pyxis. Skills for Aello must exist/work (SKILL-AUDIT.md). Success = a party completes the loop with all messages matching the Ru'Aun block.

## 7. Prerequisites before coding (Phase 3)
1. Group id block 18300+ vs live DB; mobid/dropId collision check.
2. mob_pools conversion (22 vs 28 col) for Aello + handmaidens; skills lua gaps for Aello.
3. Decide Q1 (prior working VW?), Q2 (fidelity), Q7 (first-slice) — still open.
4. JA/pet weakness hook feasibility test in DSP.
5. Per-zone message-id/CSID pulls for any zone beyond Ru'Aun.

## 8. Known unknowns
Rift p0-p2, blitz trigger, weakness degree rule, Pyxis item selection, 475 effect behavior, Void cluster/Phase Displacer effect on level, Officer/Purveyor/Refiner menu csids.
