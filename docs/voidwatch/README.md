# Voidwatch → DSP Backport Project

Persistent project, same pattern as the Assault / Nyzul / Salvage backports.
Created 2026-10-06. **Phase 0 (analysis) only — nothing built, no server files touched.**

## Start here (new session)
1. `STATUS.md` — current phase, what is verified, what is not
2. `ROADMAP.md` — phased plan
3. `SCOPE.md` — what "Voidwatch" entails, in/out of scope
4. `research/FINDINGS-2026-10-06.md` — Phase 0 evidence (LSB state, DSP state, wiki data)
5. `OPEN_QUESTIONS.md` — decisions and unknowns
6. `research/vwnm_inventory.csv` — per-NM cross-inventory (wiki vs LSB vs DSP)

## Headline finding
**LSB does not implement Voidwatch.** `settings/default/main.lua` says `ENABLE_VOIDWATCH = 1 -- (Not Implemented)`.
LSB ships *data only* (NPC rows, mob pools/groups/spawns, enums, KIs, status effect 475), with **zero Voidwatch Lua**
(no Planar_Rift / Voidwatch_Officer / Purveyor / Riftworn_Pyxis scripts, no voidwatch globals). So this is **not a
port from LSB** — LSB is a data/ID source; the mechanic logic must be **built from BG Wiki + client DAT/captures**,
under the project's "never invent IDs, wiki is reference not truth" rules.

## Rules inherited from the other projects (apply here)
- Never invent a CSID/event/message/KI/mob/NPC id. Verify via `mission_toolkit.py` / `dat-extractor` same session.
- Wiki = orientation only; verify anything load-bearing (ids, dialogue, numbers) against DAT/captures/other sources.
- Check `mission_toolkit` first (events, dialog, entities, captures) before calling anything unknown.
- Instanced-mob lessons do NOT directly apply (Voidwatch is a normal-zone battlefield-like spawn, not an instance),
  but zero-position spawn rows, mob_pools-must-exist, and `onInstanceTimeUpdate`-style (no stale timer closures) do.
- Update these docs at session end (`docs/project-memory/SESSION-END-PROTOCOL.md`).
