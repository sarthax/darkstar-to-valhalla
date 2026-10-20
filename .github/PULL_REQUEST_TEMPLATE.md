## Summary
<!-- What this PR does, in 2-4 lines. Link the issue: Closes #N -->

## Files owned / changed
<!-- Confirm only the files the issue listed changed. Explain any extra. -->

## ID sources
<!-- REQUIRED if any entity id, CSID, TextID, pool/group/drop id or key item id was added or changed.
     One line per id: <id> -> <where it came from: pull supplied by Claude, committed CapLog, npc_list row, main file>.
     Unsourced ids must be replaced by TODO(ID needs Claude lookup) in the code and listed here.
     Write "n/a" only if no ids were touched. -->

## SQL import steps
<!-- Exact import script(s), order, and whether a map-server restart is needed. "n/a" if none. -->

## Local test checklist
<!-- Claude Code runs this. For each item: zone, NPC/mob, action, EXACT expected result.
- [ ]
- [ ]
-->

## Could not verify (needs live server / client DAT / navmesh)
<!-- Be explicit. Coordinates for !checknav, dialog text, cutscene behaviour, etc. -->

## Checklist
- [ ] Branch is `codex/<issue>-<name>`, cut from `main`, pushed to `valhalla`
- [ ] No `conf/*.conf`, `version.info`, `navmeshes`, build artifacts or debug code
- [ ] `check_sql_id_collisions.py` run on any pool/group/droplist SQL
- [ ] Labeled `needs-local-test`
