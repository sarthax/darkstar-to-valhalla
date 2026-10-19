# AI worker pipeline

Workers (Codex cloud, ChatGPT agents) build slices in parallel on `codex/<issue>-<name>` branches and open PRs into `main`.
Claude Code does local testing and integration. GitHub issues and labels are the queue. Rules for workers: `/AGENTS.md`.

## Flow
1. Claude or ChatGPT chat writes an issue from `.github/ISSUE_TEMPLATE/worker-task.md` (label `ready`).
2. A Codex task takes it, pushes `codex/<issue>-<name>`, opens a PR from the template, labels `needs-local-test`.
3. `worker-gates` CI runs (forbidden paths, Lua syntax, sqlcheck, id collisions, id-source citation, scope warnings).
4. Claude Code pulls the branch, imports SQL, restarts the map server, runs the PR's Local test checklist
   (XiHeadless smoke tests where possible), resolves `TODO(ID needs Claude lookup)` items against a fresh client pull.
5. Pass: label `tested-ok`, merge `--no-ff` into `main`, tag `slice/<name>-vN`, push to `valhalla`.
   Fail: label `failed`, comment the exact failure; the worker fixes on the same branch.

## Gates that stay local (need DB / client DATs)
`check_npc_ids.py`, `check_mob_ids.py`, `check_sql_id_collisions.py --db`, `!checknav`, in-game verification.

## One-time GitHub setup (manual, on valhalla)
- Run `tools/ci/setup_labels.sh` to create labels.
- Ruleset: workers may create `codex/**` only; `main`, `feature/**`, `base/**` and `slice/**` tags stay protected (existing rulesets 24628380 / 24628381).
- Give the worker accounts/apps write access limited to this repo; no access to `origin`.
- Repo is a public fork: never commit credentials, `conf/*.conf` or local paths with secrets.
