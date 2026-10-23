# Trust modernization T0 — DSP pet architecture versus LSB Trust architecture

**Date:** 2026-10-22 · **Issue:** [#64](https://github.com/sarthax/darkstar-to-valhalla/issues/64) · **Parent:** [#63](https://github.com/sarthax/darkstar-to-valhalla/issues/63)

**Research-only.** No engine, SQL, Lua, packet, entity ID, live-character or Trust implementation changes. This evaluates **the owner's personal DSP-derived workbench**, not Valhalla's private deployed server. The owner reports that the **actual private Valhalla server already implements simpler, pet/Lua-based Trusts**. Their architecture cannot be proven from the workbench; no private source was read or assumed.

## Executive decision

**Do not start by rebuilding the Valhalla Trust system.** The source evidence supports two *different* conditional conclusions:

1. **On the personal DSP baseline alone**, a complete 3–5-member Trust system cannot be achieved simply by adding a smarter `onMobSpawn` Lua routine. The ordinary pet path has an owner `PPet` single slot, the player-party `AddMember` path requires `TYPE_PC`, friendly targeting differs, and death/zone/packet paths are specialized for ordinary pets. A *new* full Trust feature here requires a **distinct Trust actor/collection and party integration or equivalent structural changes**, not necessarily a full copy of LSB.
2. **On Valhalla's existing private pet-based Trust system**, these structural challenges may **already have been solved** using custom Lua/engine changes. Without authorized architectural details or observable tests, there is **no demonstrated reason to discard those actors or replace their party lifecycle** merely to introduce gambit-style rules. A **behavior/target/action adapter** is the preferred hypothesis *conditional on validation*.

Therefore separate the two workstreams: (a) **behavioral intelligence** can be researched and prototyped now from LSB, with a narrow, data-only specification; (b) **Trust actor replacement** is an exceptional decision driven by failing entity/party/lifecycle acceptance, not by missing sophisticated gambits.

**Source-pinned structured evidence:** [24-row gap ledger](TRUST_ARCHITECTURE_GAPS_2026-10-22.csv). Each row names both source paths and required validation; classifications are **engineering triage**, not measured effort or proof of deployed behavior.

## 1. Source identity and scope

| Source | Repository and revision | What this audit establishes |
| --- | --- | --- |
| **Personal DSP workbench** | [`sarthax/darkstar-to-valhalla@19f00e357b78fe17411ede523a1acd01fe865ee8`](https://github.com/sarthax/darkstar-to-valhalla/tree/19f00e357b78fe17411ede523a1acd01fe865ee8) | Existing old DSP pet entity/controller/party/C++ action and Lua hooks. **Not** deployed Valhalla code |
| **LSB modern source** | [`LandSandBoat/server@ed34371b7477713c9db9b9758f92df597a65e4ab`](https://github.com/LandSandBoat/server/tree/ed34371b7477713c9db9b9758f92df597a65e4ab) | Dedicated server Trust entity/controller, gambit evaluator, named Lua Trust profiles, party-aware actions |
| **Deployed private Valhalla** | Not available | Owner reports functioning pet/Lua Trusts with simpler behavior; **exact entity, party, summons, target and scripts UNKNOWN** |
| **Related experiments** | [XIHeadless Trust behavior review #212 / PR #213](https://github.com/sarthax/xiheadless-dsp/pull/213) | 19 sampled Trust personalities, source-declared priorities; separate client-side action/execution architecture |

Both public server codebases expose GPL-family licensing; whether/which specific LSB source may be copied into the owner's downstream migration work requires a separate per-file/dependency/license review. This audit paraphrases design and cites paths; it copies **no implementation**.

## 2. DSP call path and the key structural blocker

**Normal DSP pet lifecycle, confirmed from the personal workbench:**

```text
Lua spawnPet / server pet action
  → petutils::SpawnPet(master, petId)
      → ASSERT master.PPet == nullptr
      → LoadPet determines normal pet type and allocates CPetEntity
      → master.PPet = pet ; pet.PMaster = master
      → Zone::InsertPET(pet); pet.Spawn()
          → CPetEntity::Spawn → luautils::OnMobSpawn(pet)
          → CPetEntity has generic CMobController-derived CPetController
      → existing player pet UI + PetSync
  → CPetController::Tick → CMobController::Tick (generic AI)
      → DoRoamTick follows master / warps as necessary
      → AI state machine handles valid Cast, Ability, WeaponSkill commands
  → CPetEntity::Die / petutils::DetachPet / DespawnPet
      → clears the one master.PPet reference and pet command UI
  → char.petZoningInfo stores one pet's ID/HP/MP/TP for zoning
```

Evidence:
- [`src/map/utils/petutils.cpp` `SpawnPet` and `DetachPet`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/utils/petutils.cpp#L762-L807) use/clear `master->PPet`; [`LoadPet`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/utils/petutils.cpp#L1114-L1250) does not select a `PETTYPE_TRUST` branch.
- [`src/map/entities/petentity.h`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/entities/petentity.h) has `PETTYPE_TRUST=7`, and [`petentity.cpp`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/entities/petentity.cpp#L66-L100) chooses the individual name as script name. **These are lightweight hooks, not a complete Trust actor/spawner.**
- [`CPetController::Tick/DoRoamTick`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/controllers/pet_controller.cpp#L32-L85): generic mob tick, owner follow, owner-death handling; generic pet weapon skills explicitly disabled by constructor.
- [`CCharEntity::PetInfo_t`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/entities/charentity.h#L104-L113) only holds one pet's basic zoning info. This is not proof no custom Valhalla collection exists.
- [`CAIContainer`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/ai_container.cpp#L197-L254) already provides internal cast, WS, ability, ranged and action state transitions; [`CMagicState`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/states/magic_state.cpp#L38-L125) validates legal target, cost and interruption. **These are reusable engines**, though Trust-specific action legality and priority are not proven.

**The second structural blocker is the party model:** [`CParty::AddMember`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/party.cpp#L477-L546) for PC parties asserts `PEntity->objtype == TYPE_PC`, casts to `CCharEntity`, and inserts `accounts_parties` rows. Simply adding a `CPetEntity` to that path would be unsafe and conceptually wrong. Multiple Trusts must be represented separately but correctly counted, displayed and targetable. An ordinary pet is **not automatically a real six-member party slot**.

**The third blocker is ally targeting:** [`CPetEntity::ValidTarget`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/entities/petentity.cpp#L230-L237) differs from LSB's explicit Trust-friendly and party targeting. Even a perfectly written healing gambit can fail if the selected ally isn't a legal spell target.

### LSB actor path (design reference, not transplant instruction)

```text
Trust spell/ownership checks and summon
  → distinct CTrustEntity owner/trustId, TYPE_TRUST
      → CCharEntity owns PTrusts collection (not ordinary one-pet slot)
      → CTrustController movement/target selection/AI
          → CGambitsContainer::Tick
               → valid target selector (owner/party/role/enemy/etc.)
               → typed predicates (HP/MP/TP/status/skillchain)
               → legal action choice + busy/cooldown checks
               → existing spell/ability/WS action states and event result
      → CParty counts Trusts through owner's collection
      → death/disband/dismiss removes Trusts separately
```

Citations: [`CTrustEntity`](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/src/map/entities/trust_entity.cpp#L51-L69), [`CTrustController`](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/src/map/ai/controllers/trust_controller.cpp#L87-L125), [gambit helper](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/src/map/ai/helpers/gambits_container.cpp#L120-L175), [`CParty::MemberCount`](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/src/map/party.cpp#L232-L254).

**Important complexity:** LSB's ability/predicate engine uses directly available server entity/status/party pointers. XIHeadless uses protocol observations, so its predicates must sometimes return **UNKNOWN**, not silently assume equivalent state. LSB itself is not an exhaustive ideal: some Lua Trusts are sparse and the TP-closer code contains an explicit TODO for validating that a legal WS closer exists.

## 3. Gaps that a behavior adapter can realistically address

These categories use generic engines already present in the old DSP workbench. A **bounded evaluator + thin Trust-runtime adapter** is worth prototyping if the actual Trust actor/party model already satisfies its own contracts:

| Gap | Potential extension | Hard dependency |
| --- | --- | --- |
| Character identity / personality | Declarative per-Trust target selector + conditions + ordered priorities + action preferences, including profile version and deterministic seed | The deployed source must expose one callback/tick/update path per active named Trust |
| Healer personalities | Critical vs routine HP thresholds, self/owner/party priorities, cleansing, MP conservation, emergency overrides | Valid current ally roster, friendly targeting, StatusEffectContainer, legal spells |
| BRD/COR/RDM/GEO support | Buff upkeep, correct recipient roles, no overwrite, cooldown selection, observed status persistence | Server-side ally buff application and party membership with Trusts |
| Tank reaction styles | Provoke/Flash/interrupt, enmity owner targeting, proactive magic/physical mitigation | Valid enemy action casting/readiness events, enmity, legal job abilities |
| Skillchains/MB | WS opener vs closer, preserve TP, burst element proposal, fallback if no chain | Verified target Skillchain status/property and *valid available* WS/spell |
| Position preference | Melee/mid/long/no-move stance with lawful follow/cancellation | Existing pathfinder, leader identity, zone/distance and reachable target |
| Cadence and action conflict | Busy gate, per-rule retry, cooldown, prioritization, cancellation and failure reason | Existing legal `CAIContainer` states and server results |
| Reproducibility | Trace `profileId/seed/rule/actor/target/reason/outcome` into testing evidence | Bounded logging, authority, redaction; no packet or character duplication |

Avoid a "black box autonomous Lua bot" architecture: prefer **declarative data + safe, typed, server-authorized action requests**. Do not invoke unsourced IDs, accept player-submitted executable Lua or treat a queued cast as applied healing.

## 4. Cases where structural rebuild becomes justified

These are conditional design tests for the **actual private Valhalla runtime**. Not having LSB gambits does **not** itself justify rebuilding anything.

| Gate | Preserve/extend existing Valhalla Trust actors if... | Rebuild the broken *subsystem* if... |
| --- | --- | --- |
| **G-A: Multi-Trust cardinality** | 1, 3 and 5 Trusts coexist independently and consume valid party slots | Trusts overwrite a single owner pet pointer or cannot occupy the claimed party size safely |
| **G-B: Party representation** | Party UI, HP/MP/status, ally spell effects and group buffs can identify each Trust correctly | Trusts are visual followers only, not valid allies to Cure/Haste/Rolls/party targeting; current packet representation cannot be fixed in a small adapter |
| **G-C: Ordinary pet coexistence** | A master with a legal avatar/automaton/jug pet can also use allowable Trusts without pointer aliasing/ownership errors | Summoning a Trust destroys/replaces the only pet reference or corrupts another active companion |
| **G-D: Authoritative lifecycle** | Death/despawn, party change, zoning, logout/disconnect and re-summon safely resolve all Trusts | Duplicate/orphan actors or stale owner/party records persist across normal lifecycle transitions |
| **G-E: Extensible decisions** | Lua/C++ hooks permit read-only conditions and safe action choice without bypassing core state machine | Current pet AI cannot inspect party/buff/target/action state *and* has no safe extension seam, even after bounded investigation |
| **G-F: Performance/testability** | One/three/five Trusts can make correct, bounded decisions with stable tick cost and observable outcomes | Current design inherently produces uncontrolled scans/actions or cannot be tested/debugged under server load |

**Decision rule:**
- If **G-A through G-D pass**, preserve the existing actor/party implementation and **build a new behavior layer**; add engine primitives only when needed.
- If **G-A/G-B/G-C/G-D fail**, a **focused entity/party/lifecycle redesign** may be warranted. It still does not imply copying all of LSB's entity, Lua, C++ and packet infrastructure at once.
- If **only G-E fails**, build an adapter/hook/typed evaluator—not a wholesale Trust rebuild.
- If **G-F fails**, benchmark and fix the responsible subsystem before broadening support.
- If the private source and runtime evidence are unavailable, architecture choice remains **UNKNOWN**, but public DSP/LSB research and offline design continue.

## 5. Architecture choices, scored qualitatively (not measured)

| Candidate | Structural changes required on bare old DSP | Compatibility risk against private Valhalla | Benefit | When to pick |
| --- | --- | --- | --- | --- |
| **A. Enhance existing Valhalla pet Trusts with a safe rule adapter** | Minimal *only if deployed Trust owner+party model already exists* | **Probably lowest**, conditional on source/evidence | Quicker sophisticated healer/support/role personalities; avoids replacing working summon/party code | G-A–G-D pass; existing tick and action API safely extendible |
| **B. Full LSB dedicated TrustEntity/controller/gambits backport** | **Highest**: party+entity+packets+Lua bindings+spell tables+AI controller+build dependencies | **Highest** without proven backwards compatibility | Most direct structural parity with mature LSB Trust architecture | Structural gates fail broadly and partial adapters cannot satisfy them |
| **C. Hybrid separate Trust owner/party adapter plus independent declarative behavior engine** | **Moderate–high** on bare DSP; moderate/low if private Valhalla supplies actors | **Moderate**, still requires explicit interfaces | Reuses existing entity/lifecycle where possible, preserves options for future direct DSP prototype and Headless-like profiles | Default **research architecture**, not approved implementation |

**Research recommendation:** C is a strong interface-design approach, with **A as the likely deployed-Valhalla implementation** if existing party/lifecycle checks pass. Reserve B for evidence-backed structural failure, not for a desire to reuse all LSB Trust abilities quickly. No numeric cost, throughput, memory, tick rate or milestone date is asserted without profiling.

## 6. What can proceed without private Valhalla code

**Remote/public T0 follow-on (safe now):**
1. Extract an **interface dependency graph** from DSP `CAIContainer`, `CParty`, pet Lua hooks, spell/status validity and source-derived behavior predicates; mark unsupported or mismatched LSB APIs by exact symbols. Avoid writing new Lua bindings before their owning C++ contracts are known.
2. Define a **data-only, versioned gambit profile**: `target`, `condition_groups`, `action_preference`, `recast_policy`, `priority`, `abort`, `evidence`, `source_sha`. Include deterministic safety defaults and first 3 representative personalities (healer, tank, buffer).
3. Build offline **pure rule tests** with synthetic party/actor facts: triage, status missing vs unknown, buff upkeep, invalid target, action collision, WS opener/closer absence, cooldown and cancellation. Do not control a server.
4. Prepare an adapter contract for both ordinary DSP and future Valhalla; neither is a claim that current private Valhalla exposes those hooks.

**Later private Valhalla compatibility questions (no repository access required):** 
- What class/entity type represents a named Trust, and what owns the collection?
- Does it use the ordinary `PPet` slot, or maintain a separate list? Can normal pets coexist?
- How does it join/count toward party size, appear in packet updates and receive friendly effects?
- What Lua callback/execution interfaces choose skills, targets, buffs and spells?
- How do zone, death, disband and reconnect clean up active Trusts?
- Can it report action accepted, execution running, server effect completed/refused?
- Are per-Trust profiles and rules legally/configurably supported by the private maintainers?

**No need to request their proprietary source by default.** A sanitized architectural sketch or maintainer responses can tell us whether a thin adapter is viable. Their code is their deployment and integration authority.

## 7. Validation and no-regression checklist (deferred; no live work here)

| Environment | Test | Expected contract |
| --- | --- | --- |
| Static/offline | Repeated Create/Remove one actor in a deterministic fixture | Owner list, party representation and cleanup return to baseline |
| Isolated dev | Summon **one** legal Trust | Unique identity, proper owner, valid party slot and safe follow |
| Isolated dev | Sustain **three, then five** legal Trusts | No single-pointer collision, correct roster/party bounds and buff status |
| Isolated dev | Normal pet + Trusts | Existing pet remains intact, distinct owner/target/status |
| Isolated dev | Buff, Cure, status removal on owner/other Trust | Only valid party targets receive observed server effects |
| Isolated dev | Stop/disband, zone, death, logout/relog | Zero duplicate/orphan Trusts and no stale party slot |
| Isolated dev | Attack/skillchain/magic-burst policy after individual rules tested | Ability availability + target/claim legality + observed action outcome |
| Isolated dev | Worst-case 1/3/5 Trust policy tick profile | Measured bounded tick cost and no unbounded repeat actions |
| Toolkit/XIHeadless | Capture/evidence side by side | Actor type, build SHA, rule profile and result provenance preserved |

None of these tests were executed by this remote source audit; **all are NOT RUN**. Client IDs, mob IDs, packet offsets, config and SQL dependencies must come from approved server source and local evidence, not guesswork.

## 8. Known limitations, blockers and next decision

**Verified only against accessible source:** personal DSP one-pet controller/party path; LSB separate Trust entities, actor party collection and gambit engine. The private Valhalla code is unavailable; the owner confirms simpler pet/Lua Trust functionality exists there, but we cannot know which G-A–G-F gates it passes. No source code, private data, database, character or network access was changed or used.

**Next actionable choice:** continue source-only typed predicate/adapter design under a new explicitly owned, non-overlapping issue. **Do not label a Trust actor rebuild as ready** until a Valhalla-specific actor/party compatibility check shows structural failure. Keep [server-driven account-character research #61](https://github.com/sarthax/darkstar-to-valhalla/issues/61) separate, and preserve [XIHeadless Trust tool issue #53](https://github.com/sarthax/xiheadless-dsp/issues/53) as runtime-integration blocked pending a verified target-server control contract.

### Short statement of findings

> **There is a good case to rebuild the *behavior layer* for intelligent Trusts. There is not yet a demonstrated case to rebuild Valhalla's *entity/lifecycle/party system*.** On bare personal DSP, the second category has genuine architectural gaps; on Valhalla it must be judged by its already-working custom code and observed acceptance.
