# Original assignment (verbatim) - Wardrobes 5-8 V1

This is the repository owner's directive exactly as given at the start of the cloud session (2026-10-22). It is the authority for scope and approval gates. Where `HANDOFF.md` or any other document disagrees with this text, **this text wins**. Later owner instructions are recorded in `HANDOFF.md` section 3.

---

DSP Feature Development — Mog Wardrobes 5–8 V1
Primary repository: `sarthax/darkstar-to-valhalla`
Feature branch: `feature/wardrobe5-8-v1`
Local role: Primary implementation, integration, and testing agent
Approval authority: Repository owner
Status: Authorized to begin feature development, subject to the approval gates below.

## Mission
Implement Mog Wardrobes 5–8 for the December 2019 FFXI client and DarkStar/Valhalla server as one complete, independently testable feature.
This project must follow the existing DSP feature/slice workflow, not the many-small-PR development pattern used in Mission Toolkit.
The feature includes server code, storage, persistence, packet compatibility, client modification tooling, UI support, migration and rollback scripts, documentation, and automated acceptance testing.
All implementation work must ultimately reside in one cohesive feature branch. Do not merge partially completed components directly into `main`.

## Phase 1 — Repository and environment preflight
Before implementation:

1. Read DSP `AGENTS.md`, `README.md`, `docs/slices/STATUS.json`, relevant slice documentation, and GitHub worker rules.
2. Inspect current `main`, local checkout, remotes, worktrees, active branches, and outstanding PRs. Use `valhalla`, never upstream `origin`.
3. Confirm existing work does not already implement any portion of Wardrobes 5–8.
4. Check outstanding inventory safety work, especially DSP PR #51 concerning packet `0x03A` container validation.
5. Identify the deployed map-server revision, MariaDB schema revision, build configuration, and testing tools.
6. Identify the original December 2019 client, current installed client, and all separately staged modified DLLs. Verify hashes before use.
7. Establish clean baseline inventory, equipment, zoning, relogging, and persistence behavior.

Do not modify the live test server, import SQL, install a DLL, or send extended inventory packets during preflight.
Report any dirty worktree, conflicting work, deployed-source mismatch, or unverified client before continuing with risky operations.

## Phase 2 — Import the Toolkit research
Read these references from `sarthax/FFXI-Mission-Toolkit`:

* [PR #1312 — December 2019 client audit](https://github.com/sarthax/FFXI-Mission-Toolkit/pull/1312)
* [PR #1303 — POL1 modification and repacking](https://github.com/sarthax/FFXI-Mission-Toolkit/pull/1303)
* `docs/reports/ffximain_2019_wardrobe_backport_stage4.md`
* `docs/reports/wardrobe_2019_toolkit_research_closeout_handoff.md`
* `docs/reports/wardrobe_2019_dsp_transition_readiness_2026-10-21.md`

These files are on Toolkit branch:
`research/2019-wardrobe-backport-gates-20261021`
Do not assume they are merged into Toolkit `main`.
Verified original client
December 2019 `FFXiMain.dll`:

* Size: 2,870,352 bytes
* SHA-256: `514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f`
* POL1-decoded `.text` SHA-256: `af2126c057d86559bfad2e164f7f7fd0a26bbc89ab29ea9cbde5cea807c7d2b8`

Previous Stage 1–3 DLL experiments successfully booted, connected to the server, and passed basic menu smoke tests. They did not implement or validate Wardrobes 5–8.
Confirm that the original DLL has been safely restored before any new client test.
Confirmed technical constraints

* Original inventory supports 13 containers, IDs 0–12.
* Each container uses 81 slots with 44-byte item records.
* Existing item records end at active-store offset `0x14D5C`, immediately followed by active cursor state.
* Extending the original record array directly would overwrite existing state.
* A separate per-store storage region has been modeled synthetically but not implemented in the client.
* Original packet `0x1C` uses 13 capacity entries; newer clients use a different 18-container format.
* Packet `0x1E`, `0x1F`, and `0x20` handlers require bounds and compatibility review.
* Original Wardrobe modes are 8, 10, 11, and 12.
* Mode 9 is already occupied by `/bank2`.
* The original UI selector supports modes 2–12.
* Thirteen UI-related objects have verified update and cleanup paths.

Never assume the newer client's implementation can be copied by changing a few constants.

## Phase 3 — Establish the complete V1 feature
Create and retain the feature branch:
`feature/wardrobe5-8-v1`
Follow repository branch protection and permissions. If the local integration role cannot create or update a protected feature branch, request owner authorization rather than bypassing protection.
Create a feature record under:
`docs/slices/wardrobe5-8/`
Maintain:

* `README.md` — design, scope, dependencies, progress, known gaps
* `TEST_PLAN.md` — unit, integration, gameplay, persistence, compatibility and rollback acceptance
* SQL `up.sql` and `down.sql` scripts if migrations are needed
* A source/revision manifest describing exactly what was tested
* Appropriate entry in `docs/slices/STATUS.json`

Separate implementation milestones within the feature, but do not split the completed feature into separate releases or independently merged components.
Parallel workers can contribute through subordinate task branches. The local integrator assembles reviewed work into the feature-of-record branch.

## Phase 4 — Implement in controlled milestones
### A. Server storage and persistence
Audit DSP inventory enums, storage allocation, capacity handling, inventory operations, character loading/saving, sorting, item movement, equipment, and database persistence.
Design support for Wardrobes 5–8 without changing existing container behavior.
Make any required schema migrations reversible and compatible with the established DSP database engine and local configuration.

### B. Protocol compatibility
Design explicit legacy and extended packet handling.
The unmodified 2019 client must continue receiving only its supported 13-container layout.
Extended packets must require an independently verified per-session capability determination. Unknown clients default to the legacy-safe behavior.
Review all relevant packet ingress and egress bounds.
Do not enable experimental packet handling on the live test server before separate owner approval.

### C. Modified 2019 client
Use the verified Toolkit POL1 research and binary fingerprint gates.
Investigate a safe extended-storage design, including allocation, manager switching, resets, teardown, equipment, item accessors, and file/snapshot consumers.
Implement any new mode objects, Wardrobe commands, menu entries, UI controller references, and cleanup paths as part of the same feature.
Store reproducible patch definitions, tools, and test metadata in source control.
Never commit proprietary original or modified FFXI DLL binaries.

### D. Regression and acceptance testing
Develop automated offline tests before enabling live behavior.
Use XIHeadless and the local server test infrastructure for applicable acceptance tests:

* Legacy inventory and Wardrobes 1–4 remain functional.
* Wardrobes 5–8 display appropriate capacities and items.
* Item move, equip, unequip, trade restrictions and sorting work.
* Items persist after zoning, logout/login and server restart.
* Invalid container IDs and malformed requests fail safely.
* Multiple characters and store-instance resets cannot cross-contaminate inventories.
* Legacy-client compatibility remains intact.
* Rollback returns the system to the original behavior without losing existing items.

Use disposable test characters and fixtures. Preserve server-authoritative evidence rather than treating client acknowledgements as proof of persistence.

## Phase 5 — Approval gates
The repository owner personally approves integration and deployment.
You may perform read-only audits, create feature-branch source changes, run local builds, and run non-mutating unit tests within the approved development workflow.
Request explicit approval before:

1. Applying schema migrations or other mutating changes to the running test database.
2. Enabling extended inventory packets or experimental client/server behavior.
3. Installing modified DLLs into the active client installation.
4. Running destructive or persistent-state-altering acceptance tests.
5. Merging the completed feature into `main`, tagging its release, or deploying it.

Green GitHub CI or a local `tested-ok` label is not equivalent to owner approval.
Do not force-push, delete the feature branch, auto-merge PRs, or modify upstream repositories.

## Phase 6 — Final V1 deliverables
When the implementation is ready for owner review, provide:

1. One integrated `feature/wardrobe5-8-v1` branch.
2. Complete C++, Lua, SQL, packet and client patch source as applicable.
3. Repeatable migrations, installation instructions, backups and rollback.
4. Completed unit-test and live acceptance-test evidence.
5. Exact server and client build hashes.
6. Outstanding defects, known risks and compatibility limitations.
7. A proposed immutable `slice/wardrobe5-8-v1` release tag, not created until approval.
8. A final owner approval request.

Retain the feature branch and all version history. Later work may use `feature/wardrobe5-8-v2` when appropriate.

## Immediate assignment
Begin Phase 1 and Phase 2 now, followed by feature-branch setup and the V1 architecture/test plan.
Continue safe source implementation after the baseline and dependencies are verified, but do not cross any live-mutation or deployment approval gate.
Your first report should include:

* DSP `main` and deployed-server revision
* Local environment readiness
* Current client fingerprints
* Existing inventory implementation and conflicting PRs
* Proposed V1 storage/protocol/client architecture
* Feature-branch and tracking-document status
* Baseline test results
* Risks requiring owner approval
* The next implementation milestone

Do not mark Wardrobes 5–8 implemented until the complete feature has passed actual client/server acceptance testing.
