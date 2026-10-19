# AGENTS.md — rules for AI workers (Codex, ChatGPT agents)

This repo is the DSP / Valhalla server tree. Workers (you) do the parallel code, SQL and doc work.
**Claude Code does the local testing and integration** (live server, MariaDB, client DATs, XiHeadless).
Your job is to hand it a small, correct, reviewable branch. Read this whole file before changing anything.

## Workflow

1. Take ONE issue labeled `ready`. Do only what its spec says, touching only the files it lists under "Files owned".
2. Cut your branch from `main` and name it `codex/<issue-number>-<short-name>`. (`main` is the single source; `master-dsp` is only for packaging clean diffs for the original dev. Do not base work on it.)
3. Commit, push the branch to `valhalla` (never `origin`), and open a PR into `main` using the PR template. Fill in every section, especially **ID sources** and **Local test checklist**.
4. Never merge your own PR. Never push to `main`, `feature/**`, `base/**` or any tag. Never delete branches. Never force-push a branch someone else may have pulled.
5. If CI fails, read the log and fix it on your branch. If the failure needs the live server or client DATs, say so in the PR instead of guessing.
6. If a spec is ambiguous or needs an ID you cannot source, stop and ask on the issue. Do not fill the gap with a guess.

## Hard rules (non-negotiable)

### Never invent an ID
- Every CSID, event id, message/dialog/TextID, mob id, NPC id, pool/group/drop id and key item id maps to a real client DAT entry or an existing DB row. A made-up id fails silently in game.
- You may use an id only if you can cite where it came from in this repo or the repos you can read: a mission_toolkit pull (`dialog.yml`, `entities.yml`, events output), a capture CapLog, `sql/npc_list.sql`, `docs/slices/npc-id-realign/ID_SHIFTS.csv`, or a file already in `main`.
- Cite each id and its source in the PR under **ID sources**. If you cannot source one, write `TODO(ID needs Claude lookup): <what is needed>` in the code and list it in the PR. Claude resolves it against a fresh client pull. Do not leave a placeholder that looks like a real number.
- Key item ids drift heavily between LSB, Topaz and DSP. Never copy a key item id from another server's code.
- If one id in a table is wrong, the whole table is suspect. Say so rather than patching one row.
- Do not change an id that already exists in `main` unless the issue says to. After any id move, audit Lua, `instance_entities`, `nm_spawn_points`, `treasure_spawn_points` and side tables for references.
- `sql/npc_list.sql` is the canonical npc table. Names there equal the client DAT.

### Zone / entity id encoding
- Bits 12-23 of a mob id are the zone id. Only target ids below `0x400` resolve for mob/npc; the rest are reserved for players. Verify both before picking any new id.
- An NPC and a mob must never share a numeric id (they share one client render slot).
- Mobs at exactly (0,0,0) in `mob_spawn_points` are silently never loaded for instances. Give instanced mobs a real non-zero position.

### Coordinates
- Y is inverted: `pos_y` increases downward. Do not "fix" signs. Do not invent coordinates; take them from a capture, the issue, or an existing row. Claude verifies with `!checknav` live.

### SQL
- Editing `sql/*.sql` has no live effect until it is imported. Slice SQL belongs in `sql/slices/<name>/` as an import script; docs in `docs/slices/<name>/`.
- Every `mob_pools` / `mob_groups` / `mob_droplist` row must pass `py -3 tools/check_sql_id_collisions.py --file <sql>`. Never write `DELETE ... BETWEEN` over a range wider than the ids that file inserts.
- A `poolid` used by a group must exist in `mob_pools`, otherwise `GetMobByID` silently returns nil.
- When you add or edit multi-column INSERT rows, count columns with a script, not by eye. `py -3 tools/sqlcheck.py <file>` does this for `sql/*.sql` dump files.
- Do not run `DROP`/`TRUNCATE` or anything destructive in a slice script unless the issue requires it, and say so loudly in the PR.

### Lua / engine
- Timed instance mechanics use `onInstanceTimeUpdate` plus `instance:getLocalVar()` / `setLocalVar()`. Do not use `entity:timer()` closures for them.
- NPC spawn hook is `entity.onSpawn` (not `onNpcSpawn`). Check the dispatch string in `src/map/luautils.cpp` before inventing any hook name.
- `player:startEvent(csid, ...)`: pad to the argument count confirmed by a capture for that csid; default to the full 10-value form only when there is no capture evidence. Two call sites for the same csid must agree in argument count.
- In DSP, `getAnimationSub` is nil — use `AnimationSub()`. `position_t` field order is rot, x, y, z.
- Do not use bare `TextID` globals from another zone; use zone-local constants.
- Every Assault / instance zone needs its own `onInstanceZoneIn`. In DSP it must not return a value.
- `roamflag` in SQL is inert for instanced mobs.
- A script that does not match the npc `name` in `npc_list` is silently never called. The name drives script lookup.
- New C++ Lua bindings must come with the C++ on the same branch that calls them. Shared engine files (`lua_baseentity.*`, `luautils.*`, `charentity.*`, `packet_system.cpp`, `map.*`) are conflict-prone: keep hunks minimal and keep both sides when adjacent registrations conflict.

### Git
- Remote is `valhalla` (github.com/sarthax/darkstar-to-valhalla). Never push to `origin` or any upstream.
- Never stage the `navmeshes` submodule. Use `git add <explicit paths>` rather than `git add -A`. Use `--ignore-submodules=all` with status/diff commands.
- Never commit: `conf/*.conf`, `version.info`, `GIT_VER`, `data/`, built `.exe/.pdb/.dll`, logs, `tmp/`, debug/TEMP code.
- Merge commits only; no squash, no rebase of published branches.
- If a push returns HTTP 408, retry with `git -c http.postBuffer=1048576000 push valhalla <branch>`.

## What you cannot do (so don't pretend)
You have no live server, no MariaDB, no client DATs and no navmesh. You cannot verify an id, a coordinate, a dialog string or that a cutscene plays. Write code that is correct by construction from sourced data, and put everything unverifiable in the PR's **Local test checklist** with the exact expected result. Claude Code runs it.

## Where to look (research)
- `docs/slices/<name>/` — per-slice READMEs, status and test plans. Read the slice you are touching first.
- `docs/MASTER_STATUS.md`, `docs/MERGE_LIST.md` — branch state.
- `docs/slices/npc-id-realign/ID_SHIFTS.csv` — id ledger from the npc id realign.
- `sql/npc_list.sql`, `sql/mob_*.sql`, `sql/slices/` — live data definitions.
- `tools/` — checkers (`check_sql_id_collisions.py`, `sqlcheck.py`) and `DBtool.py`.
- The mission_toolkit repo — per-zone `dialog.yml` / `entities.yml` / events pulls and capture-derived data. This is the source of truth for ids and text you can reach.
- The XiHeadless-DSP repo — headless client MCP; Claude uses it for smoke tests.

## Definition of done for a PR
- Only the files in the issue's "Files owned" changed, unless you explain why in the PR.
- CI (`.github/workflows/worker-gates.yml`) is green.
- PR body complete: summary, ID sources, SQL import steps, Local test checklist, known unverifiable items.
- Label the PR `needs-local-test`.
