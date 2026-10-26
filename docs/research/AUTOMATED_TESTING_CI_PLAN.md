# Automated DSP + XIHeadless Testing — Research and Deferred Plan

**Status:** Research / proposed roadmap. **No infrastructure deployment approved.**  
**Recorded:** 2026-10-20  
**Scope:** `sarthax/darkstar-to-valhalla`, `sarthax/xiheadless-dsp`, `sarthax/FFXI-Mission-Toolkit`

## Decision and guardrails

The owner wants to preserve the research but **is not ready to install Linux, Docker, or a dedicated testing machine**. This document is a reference for later planning, not authorization to provision anything, enable billable runners, change branch protections, modify live DSP, or start autonomous execution.

Use the existing repository workflow and local Claude Code validation in the meantime. When revisiting, prefer small, reversible GitHub-hosted CI improvements before any self-hosted deployment. Request an explicit implementation decision first.

## Why this is interesting

GitHub Actions executes programs on provisioned runners. It can check out a PR, build code, provision an *isolated* database, run a test process, upload logs/artifacts, and report pass/fail on the PR. It is not limited to storing source code. The same scripts can be run locally for debugging, provided equivalent dependencies exist.

Three execution contexts are distinct:

1. **GitHub-hosted runner:** short-lived VM; useful for deterministic lint, builds, unit tests, controlled DB and small integration tests. No local machine required.
2. **Local developer testing:** Claude Code or developer runs scripts against a local, disposable test environment; needed for workflows requiring local assets/real clients.
3. **Self-hosted GitHub runner (deferred):** GitHub dispatches jobs to owner-managed hardware/VM; suitable for DAT-dependent or extended headless gameplay tests. Requires an online, isolated and secured machine. **Not part of the current plan.**

GitHub Actions is a job scheduler/execution environment, **not** an autonomous coding agent. An AI developer creates code/tests, Actions runs them, and a separate agent or person triages failures and reviews merges.

## What already exists in this DSP repository (as inspected 2026-10-20)

- `.github/workflows/worker-gates.yml`: on PRs targeting `main`, runs on `ubuntu-latest`; checks forbidden paths, changed Lua 5.1 syntax, selected SQL structure and collision cases, PR literal-ID sourcing, and mixed-slice scope.
- `AGENTS.md`: identifies Claude Code as responsible for local tests/integration involving MariaDB, live server, client DATs, and XIHeadless; defines PR review / local test checklist and restrictions.
- This existing CI **is not a full server compile + database + client gameplay acceptance pipeline**. Do not label a green `worker-gates` run as gameplay-validated.
- Current tooling and workflow inventory should be re-audited before implementation, because it may change.

## LSB reference architecture (research inspiration, not a drop-in DSP feature)

The LandSandBoat server project uses GitHub Actions, server-native test machinery including `xi_test`, scripted Lua tests, and reproducible database/container workflows. Their approach enables many server-side checks without launching a real FFXI client. Local execution and GitHub execution are complementary. Review upstream implementation and licensing when planning any port; DSP is architecturally different and cannot be assumed to contain `xi_test`.

References for future verification:
- https://github.com/LandSandBoat/server
- https://github.com/LandSandBoat/server/actions
- https://github.com/LandSandBoat/server/blob/base/.github/workflows/runner_test.yml
- https://github.com/LandSandBoat/server/blob/base/src/test/test_collector.cpp
- https://github.com/LandSandBoat/server/blob/base/dev.docker-compose.yml

## Proposed future architecture

| Layer | Repo/owner | What it would verify | Typical location |
|---|---|---|---|
| A: Static and build | DSP, XIHeadless | Compile, Lua syntax, SQL checks, unit tests, contract tests | GitHub-hosted |
| B: Server-native tests | DSP | Deterministic server logic, scripted state, formulas, isolated DB fixtures | GitHub-hosted or local |
| C: Headless gameplay | XIHeadless + DSP | Login, movement, combat, events, NPC interaction, quest/mission progression | Isolated integration environment |
| D: Evidence and traceability | Mission Toolkit + both engines | Scenario, source commit, observations, state delta, verdict, log/artifact references | Artifact export + Toolkit |

A unit PASS does not imply an end-to-end gameplay PASS. Distinguish **command accepted**, **command executed**, **command completed**, and **expected state verified** in the evidence contract. Preserve failure and timeout semantics developed under XIHeadless issues #32 (lifecycle), #34 (result contracts), and #47 (supervision); confirm their current status before building on them.

Proposed evidence manifest fields (illustrative, **not a committed schema**):
- scenario ID and version; required acceptance criteria
- DSP commit, XIHeadless commit, Toolkit/evidence version
- test fixture and environment ID; start/end timestamps
- command result and terminal status; actual vs expected state
- evidence references, log/capture links, artifact hashes, verdict
- clear flags for `not_run`, `blocked`, `failed`, `passed`, and `manual_validation_required`

Never include production credentials, personal identifiers, real account passwords, or proprietary client assets in CI artifacts.

## Optional implementation phases — explicitly deferred until approved

### Phase 0: Audit and baseline (no deployment)
- Inventory all current Actions workflows, scripts, test entry points, fixtures, PR gates, and CI minutes in the three repos.
- Compare LSB server-native testing with DSP portability, maintenance cost, and licensing.
- Benchmark existing local test durations and artifact size, and define the minimum viable automated checks.
- Cross-reference open issues; avoid duplication and conflict with active XIHeadless development.

### Phase 1: Reusable tests and GitHub-hosted lightweight CI
- Extract deterministic tests to scripts runnable on both a developer workstation and GitHub.
- Preserve `worker-gates.yml` and avoid regressing static checks.
- Start with fast checks, contracts, and isolated fixtures. Add structured machine-readable results and failure artifacts.
- Use reviewable PRs, rate limits, caches and sensible artifact retention.
- Do **not** provision Linux/Docker locally; no dedicated machine required for hosted tests.

### Phase 2: Isolated DSP integration, only if feasible
- Prove DSP compilation and disposable MariaDB initialization on an ephemeral runner.
- Prove reliable clean startup and teardown; no network access to the live server/database.
- Add one small headless smoke scenario, then expand based on evidence.
- Gate claims by actual test coverage; handle unavailable client assets or DATs as explicit `blocked` rather than silent passes.

### Phase 3: Dedicated self-hosted integration (deferred, separately approved)
- Only if necessary, consider a dedicated VM/machine with restricted runner permissions and network/database isolation.
- Require secure management of secrets, cleanup between jobs, concurrency limits, provenance and capacity benchmarks.
- Use for large datasets, proprietary local assets, persistent clients, and long gameplay test suites.
- Do not run unreviewed PR code against owner production resources.

### Phase 4: Coordination and acceptance
- Relate test cases to GitHub issues and implementation PRs, record evidence in the Mission Toolkit, and distinguish CI green from actual acceptance.
- Failure triage can be assigned by separate dispatcher/agent workflows; GitHub Actions alone does not fix failing code.
- Require appropriate human/Claude local validation and merge approval, especially for gameplay-sensitive changes.

## Capacity and cost planning assumptions (verify current rates before use)

GitHub billing, included private-repo minutes, concurrency, runner hardware, public/private policies and artifact retention policies change over time. Treat prior chat illustrations such as 2,000 (Free) / 3,000 (Pro) included minutes and ~US$0.006/min for a standard 2-core Linux runner as **planning examples only, not a spending authorization or current guaranteed quote**.

Workload formula: **monthly runner minutes = sum of each job's billed runtime**, even when jobs run in parallel. For illustration, 10 simultaneous 10-minute jobs can consume ~100 runner-minutes. A single five-minute job may execute hundreds of assertions. Account-level allotments apply across eligible private repos, not once per repo.

Capacity should be measured from actual workflow runs, CI caching and dependencies. Record:
- Median and P95 job duration, minutes per PR and monthly totals
- Builds per day, test-suite runtime, failure/retry rate
- Number of simultaneous jobs and longest queue times
- Artifact bytes per run and retention policies
- Number of headless clients per integration environment
- Monthly budget/spending limits and projected overage

Official live references:
- https://docs.github.com/en/billing/concepts/product-billing/github-actions
- https://docs.github.com/en/actions/reference/limits
- https://docs.github.com/en/actions/reference/runners/self-hosted-runners

## Recommendation while deployment is on hold

Keep `worker-gates` and local Claude Code/XIHeadless validation unchanged. Use this document for future planning and as a seed for GitHub issues **only when the owner requests implementation**. First future step is the Phase 0 repository audit; no changes to current machines or infrastructure are necessary now.

## Revisit triggers

Revisit when repeated manual test handoffs become the main bottleneck, when there is reliable demand for cross-PR regression evidence, or when the owner requests a GitHub-hosted proof of concept. A Linux/Docker workstation or dedicated system is **not a prerequisite to preserving or discussing the plan**.
