# HANDOFF - Wardrobes 5-8 V1: cloud session -> local agent

Written 2026-10-22 at the end of a cloud Claude Code session (`session_01GdoYTjFwqukcGepkVKnF9K`, repo checkout `/home/user/darkstar-to-valhalla` in a Linux sandbox). Everything on branch `feature/wardrobe5-8-v1` was produced **without a running server, a database of the owner's, a game client, or the DAT files**. Read this document completely before touching anything. Companion files: `LOCAL_AGENT_PROMPT.md` (copy-paste prompt), `ASSIGNMENT.md` (the owner's verbatim directive; it wins over anything here), `CLIENT_ADDRESS_MAP.md`, `evidence/`, and `tools/client_patch/wardrobe5-8/README.md`.

## 0. TL;DR
* Branch `feature/wardrobe5-8-v1` (pushed to `valhalla`) = `main@86d4467` + the feature. **Wardrobes 5-8 are NOT implemented/accepted.** Per the owner's rule, do not mark them implemented until real client/server acceptance passes.
* **Server side is written** (containers 13-16, capacity persistence, reversible SQL migration, ingress/egress bounds, session-capability handshake, Lua/GM tooling) but has only been **syntax-checked and unit-tested offline**. It has never been fully built or run. First job: build it.
* **Client side is research + design only.** No patch code, no patched binary, nothing run against a client. Six reproducible, SHA-gated audit tools plus evidence JSON exist. The design (`CLIENT_PATCH_DESIGN.md`) needs three owner decisions.
* **No approval gate was crossed.** Nothing touched the owner's live/test server, DB or client install. The only database used was a throw-away MariaDB inside the cloud sandbox.
* **Most valuable immediate unblockers only a local agent can do:** (1) full build + baseline regression, (2) the Phase-1 preflight items I could not do (deployed revision, schema revision, client hashes, Stage-3 DLL restoration), (3) answer whether the 2019 menu DATs define entries 13-16, (4) find the POL1 **repack** tool (the Toolkit research branch has none).

## 1. Reading order
| # | File | Why |
|---|---|---|
| 1 | `ASSIGNMENT.md` | Owner's authority, scope, approval gates |
| 2 | this file | State, gaps, next steps |
| 3 | `README.md` | Design, per-area findings, edge-case tables |
| 4 | `TEST_PLAN.md` | Acceptance matrix (offline items done; live items open) |
| 5 | `HANDSHAKE_DESIGN.md` | Capability handshake (server implemented) |
| 6 | `CLIENT_AUDIT_RESULTS.md` | Verified client facts (inbound/outgoing path, equip sets, style lock) |
| 7 | `CLIENT_PATCH_DESIGN.md` | Milestone C design, facts F1-F12, risks, owner decisions |
| 8 | `CLIENT_ADDRESS_MAP.md` | Every address worth knowing, with notes |
| 9 | `MANIFEST.md` | Revisions/hashes of what was tested |
| 10 | `CLIENT_AUDIT_WORKORDER.md` | Original audit questions (Q1-Q5 answered) |

## 2. Approval gates - status
| Gate (from `ASSIGNMENT.md` Phase 5) | Status |
|---|---|
| 1. Apply migrations/mutations to the running test DB | **Not crossed.** `up.sql`/`down.sql` exist and were exercised only on a scratch DB inside the sandbox (synthetic rows) |
| 2. Enable extended packets / experimental behaviour | **Not crossed.** Server code defaults OFF (`wardrobe58_enable: 0`, empty allow-list) |
| 3. Install modified DLLs | **Not crossed.** No modified DLL exists |
| 4. Destructive/persistent acceptance tests | **Not crossed.** None run |
| 5. Merge to `main`, tag, deploy | **Not crossed.** No PR, no tag. `STATUS.json` has a `wardrobe5-8` entry (`active`, `mergedToMain:false`, `versions:0`) |
Other actions taken: created and pushed the feature branch (the owner's Phase 3 instruction); merged PR #51's branch into the feature branch with a merge commit (see section 4). No force-pushes. No other branches modified.

## 3. Owner statements during the session (chronological; quotes are verbatim)
1. The assignment (`ASSIGNMENT.md`).
2. "Copy conf files from DSp-Branch to connect to DB and server from our cloned DSP checkout. Continue" -> **nothing to copy**: `conf/*.conf` in the checkout (and on `master-dsp`) are identical tracked localhost defaults (`root/root@127.0.0.1:3306/dspdb`). The real settings exist only on the owner's machine. They must never be committed (AGENTS.md).
3. "just to make sure you are not building a server with sql right?" -> confirmed: only syntax-only compiles and a throw-away DB in the sandbox.
4. "no that's ok i just didn't want to impact dsp-fresh right now, but if we have backups and clones that's fine. continue" -> the owner has a local DSP install/DB called **dsp-fresh** they want protected. Treat it as live: use clones/backups for anything mutating, and still obtain explicit approval for gate items.
5. Handshake design review: **accepted all three questions**: (a) threat model = accidents, not adversaries; (b) allow-list by patch-set ID in conf; (c) run the client audit before server handshake code.
6. DLL uploads: the first uploaded file was `53e91099...c699c` (= the **Stage 3** build, not the original); the owner then supplied the real original (`514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f`) with "Sorry, this was original". Installed-client and Stage-3 restoration state is therefore **still unconfirmed**.
7. Directions given in order: "yes, start on the server-side validation work" -> "implement the server-side handshake now" -> "finish the remaining server paths first" -> "Check latents and other edge cases" -> macros/style-lock question -> "look for where the client stores sets" -> "find the style-lock storage next" -> "start the client patch design" -> question about analysing a newer client -> "start with the old-DLL searches" -> this handoff request.
8. **Unanswered owner decisions** (`CLIENT_PATCH_DESIGN.md` section 6): approve the new-PE-section approach and the single static sidecar; V1 UI scope (UI objects/item lists only vs also menu entries/windows/`/wardrobe5-8`); allow Unicorn as a local-only dev dependency. Also: the PR #51 handling (I merged its branch into the feature; the owner did not object, but did not explicitly confirm).

## 4. Repository state
* Base: `main` = `86d4467d446569c741d76d296e640c3b844ad844` (PR #54 merge). Feature branch pushed to `valhalla` (github.com/sarthax/darkstar-to-valhalla). Worktree was clean after every push.
* **Remote naming:** in the sandbox `origin` pointed at the owner's fork URL `https://github.com/sarthax/darkstar-to-valhalla` (not upstream); I added `valhalla` with the same URL and pushed through it (AGENTS.md says push to `valhalla`). A stop-hook complained about a missing `origin/` tracking ref; harmless, fixed with `git fetch origin +refs/heads/feature/wardrobe5-8-v1:refs/remotes/origin/feature/wardrobe5-8-v1`. On the owner's machine, check what `valhalla`/`origin` really are.
* The sandbox clone was shallow (depth 1, then 50 for a few branches); `git merge-base` and history views may need `git fetch --depth` or a fresh full clone.
* **PR #51** (`fix/inventory-sort-invalid-container-20261018`, draft, open, +13/-1 in `packet_system.cpp`, "build and runtime tests have not been run"): merged into the feature branch as `d7b8c690` (merge commit, per AGENTS.md). If #51 lands on `main` first, merging `main` into the feature should be a no-op for that hunk. #57 (docs) and #54 (merged) are unrelated.
* Commits on the branch after `86d4467` (oldest first): `0d37b28a` docs scaffold + STATUS; `063e4197` containers 13-16 + capacity persistence + migration; `d7b8c690` merge PR #51; `7ebebc2b` `IsValidContainerID` + test; `b4e7a50f` handshake design; `b5929820` audit work order + scanner; `12728715` ingress/egress validation; `fb06de83` audit Q1; `b4783dfd` audit Q2-Q5; `bb8a325d` server handshake; `e8da0421` remaining paths; `8646a73f` edge cases; `c9dcb243` macros/style-lock + 0x053 clamp; `48fde119` equip-set audit; `58c1c33b` style-lock storage; `b17ba645` patch design; `5d475589` UI/menu audit; plus the handoff commit(s) on top. `git log --oneline 86d4467..HEAD` is authoritative.
* Changed non-doc files: `src/map/{item_container.h, packet_system.cpp, map.cpp, map.h, Makefile.in}`, `src/map/entities/charentity.{h,cpp}`, `src/map/utils/charutils.{h,cpp}`, `src/map/lua/lua_baseentity.cpp`, `src/map/ai/states/item_state.cpp`, new `src/map/packets/{inventory_guard.h, w58_handshake.h, w58_ack.h, w58_ack.cpp}`, `win32/vcxproj/DSGame-server.vcxproj{,.filters}`, `scripts/globals/status.lua`, `scripts/commands/delitem.lua`, `sql/slices/wardrobe5-8/{up,down}.sql`, `tests/wardrobe5-8/*`, `tools/client_patch/wardrobe5-8/*`.
* Not touched: `conf/*.conf`, `navmeshes`, `master-dsp`, any other branch.

## 5. What exists, with maturity
| Area | What | Maturity |
|---|---|---|
| Containers 13-16 (`LOC_WARDROBE5..8`) | enums, `CCharEntity` members, `getStorage`, `MAX_CONTAINER_ID` kept at 13 (legacy), `MAX_CONTAINER_ID_EXTENDED` 17, `IsValidContainerID`, `IsEquippableContainer` | syntax-checked, unit-tested (table logic) |
| Persistence | capacity load/save in separate statements; items load with unknown-container guard; reversible migration (parks items/equip/capacities) | migration exercised on scratch MariaDB 10.11 with repo table definitions; C++ not run |
| Ingress validation | 0x028, 0x029, 0x037, 0x03A, 0x050, 0x051, 0x053, 0x0FA, 0x0FB; central helpers null-safe | compiled only. Fixed pre-existing unguarded handlers and two OOB-read/write classes (0x051 count, 0x053 count + `styleItems` index) |
| Egress guard | `pushPacket` drops 0x1E/0x1F/0x20/0x50/0xFA for invalid containers and any packet ID >= 0x11F | unit-tested against real packet builders |
| Handshake (server) | hello/ack packet `0x103`, allow-list by 8-byte patch-set ID, default deny, flag cleared at every zone-in, atomic flag, grant pushes ack + 13-16 items + re-announces worn gear | logic + ack bytes unit-tested; handler compiled only |
| Ownership scans | `HasItem` etc. cover 0-16 (Rare items, style-lock validity) | compiled only |
| Lua/GM | `LOC_WARDROBE5-8`, `changeContainerSize` accepts 13-16, `delItem/hasItem/getFreeSlotsCount` widened, `!delitem` to W8 | luac syntax-checked; not run |
| Client research | static analysis of the **verified original** DLL: network path, packet formats, equip-set/style-lock storage, UI object model, menu gates | verified by disassembly + 6 reproducible tools; nothing executed |
| Client patch | **design only** | none |

## 6. What was NOT done (be explicit)
**Phase 1 preflight items that need your machine:** (5) deployed map-server revision, MariaDB schema revision, build configuration, test tools; (6) installed client hash, all staged DLL hashes (only two files were seen in the sandbox: Stage 3 and the original), confirmation that the original DLL is restored after Stage 3; (7) baseline inventory/equip/zoning/relog/persistence behaviour.
**Never done:** a full server build (only `g++ -fsyntax-only` of the changed files; `map.cpp` shows 3 Winsock errors on Linux that also occur on unmodified `main`); VS2019 build; running the server; XIHeadless; any CI run (the branch has no PR, so `worker-gates` has not necessarily run); any client run; any DAT inspection; any POL1 repack; any emulation. The repo `README.md` was not read in full (AGENTS.md and `docs/ai-pipeline/README.md` were). Toolkit PRs #1312/#1303 themselves were not read on GitHub - only the branch docs; the Toolkit repo was read-only in the sandbox.
**Inferred, not proven:** same-thread safety of sending from the 0x1C handler; that all 15 store-pointer writers just re-activate store 0; `0x19FAD4` entry source; `USER` folder path of `es*.dat`; behaviour of the original client when listing a set that names Wardrobe 5-8 in its menu (the apply path is proven safe).

## 7. Environment differences and gotchas
* The sandbox was Linux/g++ 13; DSP's real build is VS2019 (`win32/vcxproj`) / `Makefile.in`. Expect MSVC-only compile issues (e.g. `std::atomic<bool>` as a class member default-initialised with braces, `uint8`/int conversions in `getStorage(LOC_WARDROBE5 + i)`, `std::array` comparisons). Fix, don't hack around.
* Sandbox-only installs (do not assume they exist for you): `mariadb-server`, `libmariadb-dev`, `libzmq3-dev`, `liblua5.1-0-dev`, `lua5.1`, pip `capstone`, `pefile`. The **committed** tools need only Python 3 plus Toolkit's `pol1_unpack.py`; the committed C++ tests need only g++/MSVC.
* `pol1_unpack.py` was taken from Toolkit research branch commit **`a6de1db8be8c52189acb89e53d9272e91365bbae`** (2026-10-21). The Toolkit docs quote an older head `71184c0e...`; the later commit adds docs. **That branch has no POL1 repack tool** (only unpack/compare/report); PR #1303's repack code must be located separately. `CLIENT_PATCH_DESIGN.md` assumes it exists - verify before relying on it.
* Several source files use CRLF and tabs; I preserved each file's line endings with exact-match replacements. Do not run a formatter over them. Use explicit `git add <paths>`, never `git add -A` (navmeshes submodule); use `--ignore-submodules=all` with status/diff.
* The ad-hoc disassembly in the session used Capstone against the decoded text kept in the sandbox scratchpad (not in git). The decoded text, the original DLL and any patched DLL must **never** be committed.
* Offline test runner: `bash tests/wardrobe5-8/run_all.sh` (3 C++ programs, 5 Python suites, sqlcheck). Last run in the sandbox: all pass.

## 8. Quick verification commands
```
git fetch valhalla feature/wardrobe5-8-v1 && git checkout feature/wardrobe5-8-v1
git log --oneline 86d4467..HEAD
bash tests/wardrobe5-8/run_all.sh                       # offline tests
git diff --stat --ignore-submodules=all 86d4467..HEAD   # scope of change
# client facts (need the ORIGINAL DLL + Toolkit commit a6de1db8 on PYTHONPATH):
PYTHONPATH=<toolkit>/src python3 tools/client_patch/wardrobe5-8/audit_layout_and_store.py <FFXiMain.dll>
```
Every tool refuses any DLL whose SHA-256 is not `514653a2...f060f`; compare each output with the matching file in `evidence/`.

## 9. Evidence and tool index
| Evidence file (`evidence/`) | Tool | Test |
|---|---|---|
| `inbound_registrations_original_2019.json` | `audit_inbound_registrations.py` | `test_audit_inbound_registrations.py` |
| `outgoing_packets_original_2019.json` | `audit_outgoing_packets.py` | `test_audit_outgoing_packets.py` |
| `patch_surface_original_2019.json` | `audit_patch_surface.py` | `test_audit_patch_surface.py` |
| `ui_containers_original_2019.json` | `audit_ui_containers.py` | `test_audit_ui_containers.py` |
| `layout_and_store_original_2019.json` | `audit_layout_and_store.py` | `test_audit_layout_and_store.py` |
Equip-set/style-lock findings and the network-path disassembly are documented with addresses in `CLIENT_AUDIT_RESULTS.md` and `CLIENT_ADDRESS_MAP.md` but are **not** covered by a tool; re-verify them by disassembling the listed addresses.

## 10. Corrections made during the session (so you know which earlier statements changed)
* Store-pointer writers: first scan said 5; a decoder flaw hid the `89 /r` forms; the exact-opcode scan says **15**. The first inbound-registration scanner over-reported (shared callbacks); it was replaced by the exact call-target version.
* "Past the inbound table" memory: first called unknown; later found to be a timing interval at `mgr+0x3EDEC` (an out-of-table ID would call it).
* `Set%03d` is a default set **name**, not a file name; the files are `es0.dat`..`es4.dat`.
* The container UI objects were first thought possibly bespoke; they are one generic class (F9).
* `up.sql` originally failed on a fresh DB (only ever tested after a `down`); fixed and retested. `down.sql` originally left `char_equip` rows pointing at containers 13-16; now parked.
* The first DLL upload was the Stage 3 build, not the original; no analysis used it.

## 11. Open items
**Owner decisions:** see section 3.8. **Technical unknowns:** menu DAT contents for entries 13-16 (hard dependency for dedicated menu entries); POL1 repack tool and whether the repacked stream still fits; whether a new PE section is accepted by the launcher; classification of the ~100 inline layout sites and ~30 UI consumers per wardrobe object; the eleven whole-store `0x3B080` copies; command/handler table relocation; `USER` path of `es*.dat`; MariaDB version/engine of the real DB (`ADD COLUMN IF NOT EXISTS` needs MariaDB >= 10.0.2; unsupported on MySQL 5.x); whether `Begin()` returning NULL under load breaks the hello (design retries).

## 12. Recommended next steps (in order; "G" = needs owner approval first)
1. Read-only: check out the branch; read the docs; run `run_all.sh`.
2. Read-only preflight (the missing Phase 1 items): `main` vs deployed revision, schema revision, build config, client hashes (original / installed / every staged DLL / Stage 3), restore-and-verify the original DLL. Report any mismatch before going further.
3. Build the branch (VS2019 or Makefile) with the feature OFF; fix compile errors; run the existing regression suite and XIHeadless baseline against **main** and then the branch; they must match.
4. Read-only: DAT question - run the dat-extractor/Toolkit tooling on the 2019 install: does the item-menu resource define entries 13-16 (labels "Wardrobe 5".."Wardrobe 8")? Also list the menu DATs the five builders use.
5. Read-only/offline: locate the POL1 repack code (Toolkit PR #1303), do a **no-op repack of the original in scratch** and record whether size/hash match Stage 2 (`27636cc5...923d2c`). No installation.
6. Offline: C1 - classify every inline layout site and UI consumer (inputs: `evidence/patch_surface_original_2019.json`, `ui_containers_original_2019.json`); record in a new `CLIENT_SITE_CLASSIFICATION.md`.
7. G (dependency): build the Unicorn emulation harness described in `CLIENT_PATCH_DESIGN.md` section 4.
8. G (gate 1/2/4): on a **clone** of the test DB, apply `up.sql`; run `TEST_PLAN.md` sections 3 and 6 with the feature flag on and a disposable character; a headless/fake extended client (XIHeadless) should send the `0x103` hello with an allow-listed patch-set; confirm legacy sessions never receive containers 13-16. Then `down.sql` rollback.
9. G (gate 3): only after the owner approves the client design decisions and an isolated trial: C2/C3 implementation and a local client trial (original DLL restored and hash-checked afterwards).
10. Final deliverables per `ASSIGNMENT.md` Phase 6; propose `slice/wardrobe5-8-v1` but do not create it.

## 13. Never do
Commit `conf/*.conf`, retail/patched DLLs, decoded code, credentials; force-push; delete the branch; merge to `main` or tag without the owner; install a DLL or run migrations on dsp-fresh or any shared DB without the matching gate approval; send containers 13-16 or the 18-container layout to an unverified client; mark the feature implemented before real acceptance.

## 14. Session chronology (condensed)
Preflight and research import -> branch + docs -> (conf request: nothing to copy) -> server storage/persistence/migration -> PR #51 merged into the feature, helper + tests -> handshake design (owner accepted) -> DLL mix-up resolved -> client audit Q1 (inbound table 0x11F, unchecked dispatcher), Q2-Q5 (send path via `Begin()`, ring slots, no per-packet crypto) -> server ingress/egress validation -> server handshake -> remaining server paths (use-item guard, ownership scans, equip re-announce, migration fixes) -> latent/edge cases -> macros and style lock (0x051/0x053 fixes) -> equip-set storage (`es*.dat`) -> style-lock storage -> client patch design -> newer-client discussion -> old-DLL UI object and menu-gate audit -> layout tool, address map, this handoff.

## 15. Status log (append one line per future session)
| Date | Agent | Summary | Tip commit |
|---|---|---|---|
| 2026-10-22 | cloud Claude Code | Initial V1 work + handoff (this file) | see `git log` |
| 2026-10-21 | local Claude Code | Local setup, feature-OFF build, offline tests, DAT question (D, partial), no-op repack (E), XIHeadless baseline main vs branch. Details in section 16. Nothing deployed, migration NOT applied anywhere | docs commit on this branch (tip before this docs commit: `38036e6b73`) |

## 16. Local session findings (2026-10-21)
- **Base commit:** the documented base `86d4467` is NOT an ancestor of `main` in the local repo. Branch tip `38036e6b73` was used as-is; nothing rebased.
- **Client DLL:** Stage 3 was installed; backed it up as `FFXiMain.stage3.53e91099d0d7.dll` and restored the original (SHA-256 `514653a2...f060f`, verified equal to the backups and the ChatGPT samples).
- **Build:** DSGame (VS2019 x64, feature OFF) builds. DSGame sha256 `6625e487...973c`, 1,633,280 bytes. DSConnect built from the branch is 243,200 bytes; the deployed one is 852 KB and was used for tests (`git diff main...HEAD` touches nothing in `src/login` or `src/common`; the size difference is not investigated). msbuild post-step `get_git_ver_win.bat` exit 9009 (git not on cmd PATH) only affects `GIT_VER`.
- **Offline tests:** `run_all.sh` needs g++, which this machine lacks. The three C++ tests were run with the MSVC `cl.exe` equivalent: all pass. The five Python `test_audit_*` suites were not re-run by me here.
- **Step D (DAT question): NOT resolved.** Searched the client DATs (`ROM/168/25`, `176/96`, `178/35`, `168/24`): no text for "Wardrobe 5-8"; `ROM/178/35.DAT` has the Mog Case/Sack/Wardrobe table with blank entries `0x9D-0x9E`; `/wardrobe`..`/wardrobe4` are command IDs 111-114 in `ROM/168/24.DAT`. Which menu DATs the five menu builders load is UNKNOWN: it needs a disassembler on the decoded `.text` (capstone not installed; pip over SSL needs approval). Section 6 decision 2 (C3a vs C3b) therefore still lacks its input.
- **Step E (no-op repack):** tools exist locally: decode `mission_toolkit/src/workbench/client/pol1_unpack.py`, repack `FFXI-Tools/xi-tools/src/xi/dll/pol1_io.py` (`pack_dll`). Identity repack is byte-identical to the original (sha256 `514653a2...f060f`, 2,870,352 bytes), but that path reuses the original payload. Recompressed unmodified `.text` (3,264,206 B) = 1,938,821 B vs budget 1,963,536 B (24,715 B headroom). A one-byte-changed repack round-trips through the independent decoder. Not compared with Stage 2 (no Stage 2 file available). Nothing was installed.
- **Step C baseline (XIHeadless, feature OFF, clone DB `dspdb_w58_test`, never the live DB):** same scripted session on main (deployed 2026-10-16 DSGame) and on the branch DSGame: login, GM-add items, equip, zone 106 -> 235, logout, relog, DB checks. Matching: 13 inventory entries after add, equip ok, zone change ok, inventory unchanged by zoning, same 13 entries after relog, char_equip and char_storage capacities unchanged across relog, `char_storage` capacity columns identical. Differing: Mog Safe contents/row count, because the two test characters (xitest06 main, xitest07 branch) started with different safe contents, not a build difference. Limits: different characters, one scenario, no map-server restart persistence check, no multi-character check.
- **Test environment notes:** the lobby TCP ports had to be the standard 54001/54230/54231 because XIHeadless hardcodes them (map UDP 54230 too, matching `zone_settings` in the clone). Nothing else was listening and the conf points at the clone DB. Servers started from a background shell child died within seconds; they stay up only when started with `Start-Process` (own console, sandbox off). Server exes in the run dir vanish after exit, so copy a fresh one per run. Use `py -3.11` (3.15 beta breaks the helper tools).
- **Not done:** `up.sql` applied nowhere; feature flag never enabled; no extended-client or hello test.
- **Approvals still needed (section 12 items 7-9, plus CLIENT_PATCH_DESIGN section 6):** apply `up.sql` to a clone; enable the feature flag on it; an extended-client test; the three owner design decisions.

## 17. Clone-DB server tests (2026-10-21, owner approved section 12 items 7-9: clone DB only, no live DB, no installed DLL changes)
- **Migration:** `up.sql` applied to the clone `dspdb_w58_test` only (4 wardrobe columns + `char_inventory_w58_backup`, `char_equip_w58_backup`). Round trip on the clone with a disposable character (xitest07, 30 slots in Wardrobe 5, one row in container 13): `down.sql` dropped the columns and parked the item row; `up.sql` restored the item and the 30-slot capacity.
- **Legacy session, feature ON** (branch DSGame, `wardrobe58_enable=1`, test patch-set `0102030405060708`): unmodified XIHeadless login. Containers 0-16 listed through the bot: 13 entries in inventory, 18 in the Mog Safe, nothing in 13-16. Zone change 235 -> 235 worked, inventory count unchanged. The container 13 row stayed in the DB. Limit: the bot reports what its parser shows, not a packet capture, so "nothing on the wire" is not independently proven.
- **NOT done (item 9):** no extended session. XIHeadless cannot send a raw packet, so the `0x103` hello/ack path, the grant push of containers 13-16, equip and persistence for Wardrobe 5-8 are untested. Needs a send tool plus an ack parser in XIHeadless (C#), or a patched client; the latter is excluded by the approval.
- **Test setup note:** the b2 run dir `map_port` must be 54230 (matches `zone_settings`); 55230 gives ConnectionReset on zone-in. The conf has the two wardrobe58 lines appended (backup `map_darkstar.conf.w58bak2`).

## 18. Extended-session test on the clone DB (2026-10-21, owner approved)
Tooling (local research copy `D:\Claude\FFXI-Tools\headless-research\xiheadless-dsp`, not committed here, built to `bin/Release/net9.0`, the existing `bin/mcp` build untouched): `IInventory.SendRaw`, MCP tools `send_raw`, `w58_hello` (patchset/magic/proto/flags overridable), `w58_ack`; parser case 0x103 stores the last ack. Driver: `xitest07`, clone DB `dspdb_w58_test`, branch DSGame with `wardrobe58_enable=1`, allow-list `0102030405060708`; DB rows: Wardrobe 5 cap 30 + item 4112 x3 in container 13, Wardrobe 6 cap 30 + 4112 x2 in container 14.
| Step | Result |
|---|---|
| Legacy login, no hello | containers 13-16 empty at the client, ack count 0 |
| Hello, patch-set `FFFF...` (not allow-listed) | refused (server log: "patch-set not allowed"), nothing sent, ack 0 |
| Hello, bad magic / proto 2 | nothing sent, ack 0 |
| Hello, allow-listed patch-set | ack received, 24 bytes: `W58A`, proto 1, flags 0, sizes `1F 1F 01 01`, caps `1F 1F 01 01` (u16 LE 31,31,1,1); items now visible in 13 and 14, 15/16 empty |
| Zone 235 -> 106 without a new hello | no new ack/push (ack count stayed 1) |
| Hello after the zone | granted again (ack count 2) |
| DB after | rows in containers 13/14 unchanged (3 and 2) |
**Open observations:** (1) the bot shows quantity 1 for both items although the DB has 3 and 2 and the server sets quantity on load and sends it in the item packet; cause not investigated (bot parser? a later packet? server path for 13-16?). (2) The bot's inventory view is not a packet capture and the bot keeps its client-side view of 13-16 after a zone, so "server stops sending after zoning" is shown by the ack/refusal behaviour, not by an emptied view. (3) Not covered: move/equip/sort/trade for 13-16, persistence across map restart, Rare-item checks, two-character isolation, `down.sql` with an extended session. (4) Item 9 as a real patched client is still untested.

### 18a. Quantity mismatch resolved (2026-10-21): test-fixture artefact, not a bug
Item 4112 (potion) has `stackSize = 1` in `item_basic`, and `CItem::setQuantity` clamps to the stack size (`src/map/items/item.cpp:179`). The fixture rows (quantity 3 and 2) were therefore loaded as 1, and the server sent 1; the bot parser is correct. Existing behaviour for every container, unrelated to this slice. Use a stackable item (stackSize > 1) for quantity tests in 13-16. The invalid DB rows were left untouched on the clone.

## 19. Move, persistence and crafted-container tests on the clone DB (2026-10-22, owner approved; clone `dspdb_w58_test` only)
Servers: clone servers started by the testing coordinator (the local launcher kept losing its exes to an antivirus file shield, which the owner switched off temporarily). Same server build as sections 17-18 (game exe sha256 starts `6625e4871b6d`). Item: 4148 antidote (stackSize 12). Bot: XIHeadless research copy, raw 0x029 via `send_raw`.

**Extended session (xitest07, hello granted, wardrobe5 and 6 capacity 30):**
| Step | Result |
|---|---|
| `!additem 4148 5`, move 5 from bag to container 13 | OK; bag empty of 4148, container 13 slot 1 = 5; DB row `(13,1,4148,5)` |
| Raw 0x029 container 13 -> bag, qty 2 | OK; bag has 2, container 13 has 3; DB `(0,..,2)` and `(13,..,3)` |
| Raw 0x029 container 13 -> container 14, qty 1 | OK; 13 has 2, 14 has 1; DB matches |
| Crafted 0x029 to 17, to 255, from 17, from 200, to 16 (empty), from 15 (empty) | no state change anywhere, DB identical, session alive and in zone |
| Relog (new session) plus new hello | container 13 = 2, container 14 = 1, bag = 2; DB unchanged |

**Legacy session (xitest06, feature on, no hello):**
| Step | Result |
|---|---|
| Move 5 to container 13 | refused (bot ok=false); bag still 5, container 13 empty, DB `(0,..,5)` only |
| Same six crafted container ids | no state change, session alive |
| Relog | container 13 empty at the client, DB unchanged |

Map server stayed up the whole time (process alive, no crash/assert lines in `map-server.log`).
**Not covered yet:** equip and sort from 13-16, trade, Rare-item checks, two-character isolation, map-server restart persistence, `down.sql` with an extended session, a real patched client. The crafted-id test covered 0x029 only, not 0x037/0x03A/0x050/0x0FA/0x0FB.

## 20. Equip, sort, Rare and isolation tests on the clone DB (2026-10-22, owner approved; clone `dspdb_w58_test` only)
Same servers and bot as section 19. Raw packets via `send_raw`: 0x050 body = `slot, equipSlot, container, 0`; 0x03A body = `container, 0, 0, 0`. Items: 17024 ash_club (all jobs, level 1, stack 1), 16534 onion_sword, 4148 antidote (stack 12), 12008 ravagers_mask (flags include Rare 0x8000). Character was WHM20; an earlier run with 16535 bronze_sword did not equip because the job cannot use it, so that run proves nothing and is not counted.

| Step | Result |
|---|---|
| Extended: 0x050 main hand (equipSlot 0) from container 13 | `char_equip` row `(equipslotid 0, slotid 1, containerid 13)`; item stays in container 13 |
| Extended: move the equipped item out of 13 (0x029 13 -> bag) | no change: item still in 13, equip row intact |
| Extended: 0x050 with container 14, 15, 16 (empty slots) | no state change |
| Relog, new hello | equip row and container contents unchanged |
| Extended: 0x03A on container 13 with fragments `(slot10, 4148 x2)` and `(slot11, 4148 x4)` | merged to `(slot10, 4148 x6)`, DB matches; items of different ids were not reordered. DSP's sort only merges partial stacks, it never reorders, so this is existing behaviour |
| Extended: `!additem 12008` while a Rare 12008 sits in container 13 | add refused; bag stays empty of 12008, container 13 keeps the single item |
| Legacy (xitest06): DB row `(13, 1, 17024)` fixture, then 0x050 with container 13 and 0x03A on 13 | container 13 empty at the client, no equip row written, DB row untouched, nothing moved to the bag |
| Isolation: xitest07's container-13 items vs xitest06 | xitest06 never saw them; xitest06's fixture row never appeared in xitest07's container 13; each character's DB rows stayed under its own charid |

**Limits:** the Rare check covers only `!additem` into the bag with the duplicate in container 13. AH purchase, trade receipt, treasure-pool and quest `HasItem` checks were not run. I did not check that the client received the equip update, only the server state and DB. The legacy equip test covered one fixture item, one equip slot and one container id.
**Still not covered:** trade, equip set (0x051), map-server restart persistence, `down.sql` with an extended session, crafted ids on 0x037/0x03A/0x050/0x0FA/0x0FB, a real patched client.

## 21. Equip sets, restart persistence, rollback and crafted ids (2026-10-22, owner approved; clone `dspdb_w58_test` only)
Servers: `coord-connect.exe` and `coord-game.exe` from `D:\Claude\w58-run-b2`, started and stopped by a local launcher (the exes were no longer being deleted). Same bot and fixtures as section 20.

| Test | Result |
|---|---|
| 0x051 equip set, one entry (club, container 13), extended session | equipped; `char_equip (0, 1, 13)` |
| 0x051 with count 255 plus entries naming containers 17, 200 and 255 | entries with those containers ignored; session alive. Zero-filled entries after the real ones act on slot 0 and un-equipped the main hand, which is how my crafted packet was built, not a bug in this slice. Reading is capped at 16 entries in source (`dsp_min(count, 16)`); the fixed-size packet makes a read past that impossible to show at runtime, so the cap is confirmed by source only |
| 0x051 entries naming empty containers 15 and 16 | no state change |
| Legacy session, 0x051 count 255 with containers 13, 14 and 17 | nothing equipped, DB unchanged, session alive |
| Map and connect servers killed and restarted, then login | container 13 (4 items), 14 (empty) and the equip row `(0, 1, 13)` identical to before |
| `down.sql` then `up.sql` on a DB holding extended-session data (club worn from 13, 5 items in 13 across two characters) | after down: all 13-16 rows and the equip row parked, columns dropped. After up: inventory, equip and capacities identical to before (diff empty), all three backup tables gone |
| Crafted container ids 17, 18, 100, 200, 255 on 0x050 (slot 1 and slot 4) and 0x03A, both session types | inventory and equip state identical before and after; sessions alive |

**Rare items, source only:** `charutils::HasItem` loops over all 17 storage ids regardless of client version, and it backs the item-add check (`charutils.cpp:1239`), the trade receipt check (`:1510`) and the treasure pool check (`treasure_pool.cpp:432`) plus Lua `hasItem`. A runtime trade or treasure test was not run; the only runtime Rare check is section 20 (`!additem`).
**Limits:** my crafted 0x037 packets had a bad size, so the server dropped them before parsing and 0x037 is NOT covered; 0x0FA and 0x0FB were not sent; `down.sql` was run with the servers stopped and no old binary was started against the parked DB, so "old binary logs in cleanly after down" is untested.
**Still not covered:** trade at runtime, AH, 0x037/0x0FA/0x0FB with crafted ids, an old binary against a rolled-back DB, a real patched client.

## 22. Legacy-client regression with the original FFXiMain.dll (2026-10-22, owner approved; clone `dspdb_w58_test` only)

Setup: original, unmodified `FFXiMain.dll` (SHA-256 `514653a2...f060f`, verified before and after) through `xiloader.exe --server 127.0.0.1` against the clone servers (feature on, no 0x103 handshake, i.e. legacy session). Every touched client file was backed up first.

Result:
- Logins as xitest06 (clone char "Venthu") and the owner's personal char (cloned DB) both reached Bastok Markets. Map log: 0 error/assert/crash lines. Connect log: only the client-version warning (got 301912, expected 301709), not fatal.
- Owner check in the real client: the menu shows only Mog Wardrobe 1-4 (no 5-8). Human check of the menu only; equip/move/sort in the real client were not exercised (covered by the XIHeadless tests in sections 19-21).
- The xitest06 session ended with `map_cleanup: timed out` after the client was closed; nothing abnormal.

Restore: the client tree was diffed against the pre-test manifest. 39 files changed and 3 were new, all client runtime state (SYS bins, TEMP logs, USER config incl. the new `USER\554a` folder). Post-test copies are kept in `post_test_state`, the originals were restored and the new folder removed. Re-diff shows 0 differences, the DLL hash is unchanged and the HKLM PlayOnlineUS registry export is identical. Clone servers stopped.

Not covered: a patched Wardrobe 5-8 client (none exists), trade/AH/treasure Rare checks, 0x037/0x0FA/0x0FB with crafted ids.

## 23. Step D, interim finding: menu builders are data-driven (2026-10-22, read-only static analysis of the original DLL; Unicorn 2.1.4 + capstone 5.0.7 installed in the scratch venv only)

Method: `.text` unpacked with Toolkit `pol1_unpack.py` (the on-disk `.text` is POL1-packed, so disassembling the raw file gives garbage), then capstone. RVAs below match the earlier findings (F11).
- `0x1159A0(menu, newState, itemId)` is a menu **item-state setter**: it walks the item list at `menu+0x14`, finds the item of type 1 whose id (word at item+0x3A) equals `itemId`, and calls `0x1167B0(item, state)`. State 5 hides it. It is called from 276 sites.
- The wardrobe builder at `0x1306D0` (vtable slot 0 of the class at `0x32A810`, RTTI pointer `0x1015FBD0`) tests capacity of the UI objects at `0x10621FE0/E4/E8` via `0xE8C60`; when 0 it hides items 3, 4, 5. Builders for the other gates follow the same pattern.
- Conclusion: the entries are **items already present in a menu definition loaded at runtime** and are only hidden. A Wardrobe 5-8 entry therefore needs either (a) new item definitions in the menu resource (DAT, but no Wardrobe 5-8 text exists in the DATs checked so far), or (b) items injected into the live menu object by patched code (item struct size/layout still to be measured from `0x1167B0` and the item constructor). Which DAT feeds the menu object (`[owner+8]`, set outside the constructor at `0x15F5B2`, which zeroes it) is still **not identified**.
- Feasibility: C3b is not ruled out, but route (b) is a larger patch than the capacity-gate change. Fallback remains server-side banking commands (owner decision 2026-10-22).

Next (static, read-only): find the writer of `[owner+8]` and the menu-resource loader; measure the item struct; list the 4 Mog-wardrobe item ids actually present in the menu DAT.

## 24. Step D, retail DAT evidence (2026-10-22, owner approved: build downloader, read PlayOnline manifest, selective single-file downloads)

Tooling: `mission_toolkit/tools/retail_fetch` built locally with `cargo build --release` (it had only ever run in CI). Files fetched with `ffxi-retail-selective --file <f> --version <v> --output D:\Claude\FFXI-Tools\retail_research` (isolated folder, **not** the installed client; the page's default root is inside the client, so use `--output` or set the root). Total transfer about 100 KB; no binaries beyond these five DATs; nothing committed.

| File | Local (Valhalla client) | Retail 30210706_0 (2021-07) | Retail 30260805_0 (2026-08) | 30260805_0 SHA-256 |
|---|---|---|---|---|
| ROM/27/76.DAT (container names) | 17,824 B | 18,756 B, Wardrobe 1-4 | 19,076 B, **"Mog Wardrobe 5".."8" present** | `0d9a5d99...ade17d` |
| ROM/168/25.DAT (menu) | 36,165 | 36,503, wardrobe..4 | 36,798, **`wardrobe5`..`wardrobe8` elements** | `da32340e...fb8d6` |
| ROM/176/96.DAT (menu) | 37,263 | 37,601, ..4 | 37,862, **`wardrobe5`..`8`** | `d35af3a0...25ae7` |
| ROM/178/35.DAT (menu) | 51,030 | 51,406, ..4 | 51,707, **`wardrobe5`..`8`** | `0c7d87f6...81158` |
| ROM/168/24.DAT (menu) | 57,319 | 57,871, ..4 | 58,360, **`wardrobe5`..`8`** | `0ed51c61...405ca` |

Findings:
- The **only retained versions containing Wardrobe 5-8 are the 2026-08 ones**; the 2021-07 versions do not (checked in all five files).
- The menu is built from these data-driven element definitions (`wardrobe`, `wardrobe2`..`4` in the Dec-2019 client; `wardrobe5`..`8` added in retail). This closes the "which DAT feeds the menu" gap for the **definitions and labels**; it makes route (a) of C3b viable: ship/overlay the five retail DATs, and the DLL patch only has to create the four UI objects and the gates (entries 13-16), not new menu data.
- XIPivot-style overlay would avoid modifying the installed client's own DATs (XIPivot Ashita zip is already in `C:\ValhallaXI`); not yet tested.

Open (needs client-side test, owner approval and backups): (1) whether the unpatched Dec-2019 DLL accepts the 2026 menu DATs without crashing or mis-rendering (menu DATs are shared by all menus, so a layout change since 2019 would break more than wardrobes); (2) which version of the retail DATs is safe to ship beyond the Dec-2019 client; (3) legal/distribution posture for redistributing the DATs vs having users fetch them with the downloader.

## 25. Step D, DAT version choice and drift (2026-10-22, static, owner offline)

Owner guidance: Mog Wardrobe 5-8 arrived about Feb-Mar 2022; use the DAT version that aligns closest; newer data we do not need (e.g. Recycle) should be avoided.
- The manifest retains **no** version of the five menu DATs from Feb-Mar 2022. Retained: 30210706_0 (2021-07, no Wardrobe 5-8) and 30260805_0 (2026-08, has them). The closest retained version that contains Wardrobe 5-8 is therefore 30260805_0.
- Name-set drift is larger local(Dec-2019) -> 2021-07 than 2021-07 -> 2026-08, so the 2021-07 files are no safer a base than the 2026 ones for the Dec-2019 DLL.
- ROM/168/25.DAT, 2021-07 -> 2026-08, is a handful of inserts: 78 B at 0x270c = `wardrobe5`..`8` plus `recycle` (record shape `0d <id lo> <id hi> "/wardrobeN\0" 00 02 02`), 10 B "Aria", 160 B job-code entries, 17 B "Term Filter", plus small 1-byte replaces that look like count/offset fields. Wardrobe 5-8 ids are 0x0bcf..0x0bd2; Recycle is 0x0bd3 (type 09).
- Consequence: a **surgical splice** is plausible (insert only the four wardrobe records, leave out recycle/Aria/Term Filter/job codes), but the count/offset fields must be understood first. Whole-file replacement drags in all other newer data.
- Static check: the unpacked DLL `.text` contains no "wardrobe" string (ASCII or UTF-16), confirming the labels and elements live only in the DATs.

Client test plan for the owner's return (not run; nothing in the client was touched): back up with the usual routine, overlay via XIPivot (preferred) or copy-with-backup, test the original DLL first with (1) whole 30260805_0 files, then (2) spliced files if (1) misrenders; manifest diff and DLL re-hash afterwards. Needs the owner present and a written go-ahead.

## 26. Live DAT test result and CORRECTION to sections 24/25 (2026-10-22)

Test: backed up the five DATs, installed the 2026-08 retail versions (hashes verified) next to the original DLL (`514653a2`), logged in on the test server. Result (owner screenshot): client loaded, Mog House menu rendered normally, **still only Mog Wardrobe 1-4**, no crash. DATs restored afterwards (hashes equal to the pre-test values, DLL unchanged).

Correction: in `ROM/168/25`, `176/96`, `178/35`, `168/24` the `wardrobe2..8`/`recycle` records are **slash-command name tables** (`0d <id> <len> "/wardrobe5\0"`, neighbours `/mutebgm`, `/mount`), one file per language/variant, **not menu element definitions**. Sections 23-25 wrongly called them menu elements and "route (a)". Only `ROM/27/76` carries the `Mog Wardrobe 5..8` labels. The actual menu item definitions (and the help text "Remove or store items in your fourth Mog Wardrobe.") were not located: a plain/XOR-0x80 scan of the client's ROM tree finds the help string in no DAT, and `Mog Wardrobe 4` (XOR 0x80) only in `27/76` plus zone dialog files.
Consequence: the DAT swap proves nothing about the menu except that these files are harmless to the Dec-2019 client. Menu entries for 5-8 still need the DLL side (builder at `0x1306D0` hides items by capacity and selects by `[esi+0x14]` via the table at `0x1013079c`/`0x101307b4`). Next: find where the menu items are created (the loader behind `[owner+8]`) and the help-text source before deciding C3b feasibility.

## 27. `/wardrobe5` with 2026-08 DATs (2026-10-22)
Owner test: with the five 2026-08 DATs installed and the original DLL, `/wardrobe5` is silently ignored. The command list is evaluated by DLL code; the DAT name table alone does not enable it. No DAT-only route to Wardrobe 5-8 access exists; DLL patch (or server-side banking commands) is required. DATs restored, DLL hash `514653a2` unchanged.

## 28. The Storage menu definition found (2026-10-22, static; supersedes the DAT conclusions in 23-25)

- The wardrobe class (vtable `0x32A810`, singleton `[0x10565E0C]`) is the controller for menu resource **`menu    mnstorag`** (string at `0x103640DC`, opened via `0x10157C10`). Slot 6 (`0x1306E0`-area) opens it; the builder hides items 3/4/5 by capacity.
- `mnstorag` lives in the big menu DATs (about 4 MB each; chunk name `mnst`, type 0x30): `ROM/119/51`, `91/15` (flag `01 05`), `0/1`, `118/111`, `176/75`, `178/14` (flag `01 02`). Which one the client loads for our install is not yet determined. The retail manifest holds a 2026-08 version only for `119/51` and `91/15` (fetched, SHA-256 `04101ec2...` and `27c2d2c7...`, in `retail_research`, not committed).
- DAT chunk walk (16-byte header; size = `((u32@+4 >> 7) & 0x7FFFF) * 16`; type = low 7 bits) parses both files exactly. The `mnst` chunk is 528 B locally vs 848 B in 2026-08: **+320 B = 4 item records of 0x50 B**. Header count/cursor-wrap bytes go `05 -> 09`; items reference button textures `windowps803/804/993-995` locally and add `windowps1062..1065` (= the new Wardrobe 5-8 buttons, graphics rather than text).
- Splice built (not installed): `retail_research/spliced/ROM/{119/51,91/15}.DAT` = local DAT with only the `mnst` chunk replaced by the 2026 one (chunk walk verified, sizes +320 B). Variant B `retail_research/spliced_wind/...` also swaps the `wind` texture chunk (type 0x31, 894 KB) so the 1062..1065 button graphics exist; unverified that it is a superset of the local textures.
- Expected effect of the splice on the unpatched DLL: the four new rows appear (the builder only hides 3/4/5), selection of them is probably ignored (item dispatch handles ids 1-5). This is the cheapest live check of the menu route. DLL then needs: capacity gates for the four new items, and the item-activation dispatch (not yet located).
- Client files were NOT touched in this step. Live test deferred (the owner's client is in use for another test).
