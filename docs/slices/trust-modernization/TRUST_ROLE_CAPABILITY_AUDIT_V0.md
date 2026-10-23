# Trust behavioral capability coverage — source-to-adapter audit v0

**Tracking:** [#72](https://github.com/sarthax/darkstar-to-valhalla/issues/72) under [Trust modernization #63](https://github.com/sarthax/darkstar-to-valhalla/issues/63)  
**Recorded:** 2026-10-22  
**Status:** Public-source engineering research. GitHub-hosted CI validates the catalog, but **no local or live DSP/Valhalla testing has occurred**. No Trust gameplay or server logic was changed.

## Core assessment

The question is no longer merely whether DSP *has* spell/status/party C++ methods. The important distinction is whether an existing **named Trust actor**, which might be represented as a pet on private Valhalla, can **observe authoritative party facts, legally target the right ally/enemy, choose a real ability, avoid action collisions, and prove the effect actually happened**.

This catalog models those prerequisites for **12 source-derived behavior use cases** using **26 capabilities**. Against the accessible personal DSP baseline:

- **11 capabilities — `symbol_found`**: generic DSP C++ or Lua symbol was inspected; source presence only, *never* Trust runtime verification.
- **9 capabilities — `trust_bridge_missing`**: an adjacent generic source seam exists, but a Trust-specific owner/party/predicate/outcome adapter has not been established.
- **6 capabilities — `not_reviewed`**: no credible source-backed path was established during this pass; UNKNOWN rather than “unsupported in the deployed private server.”
- **All 12 behaviors remain `NOT_TESTED` at runtime.** Even a `SOURCE_SEAMS_FOUND` classification is **never** READY, executable, deployed or live-accepted.

The owner's repository `sarthax/darkstar-to-valhalla` is a **personal DSP development and migration workbench**, not the private Valhalla source. The actual Valhalla maintainers already have working but simpler **pet/Lua-based Trusts** according to the owner's report. No inference of their custom data model, Trust identities, packet or permission behavior is made here.

**Pinned sources:**
- Personal DSP: [`19f00e357b78fe17411ede523a1acd01fe865ee8`](https://github.com/sarthax/darkstar-to-valhalla/tree/19f00e357b78fe17411ede523a1acd01fe865ee8)
- LandSandBoat: [`ed34371b7477713c9db9b9758f92df597a65e4ab`](https://github.com/LandSandBoat/server/tree/ed34371b7477713c9db9b9758f92df597a65e4ab)
- Machine-readable evidence: [`trust_role_capability_catalog_v0.json`](trust_role_capability_catalog_v0.json)

## Concrete DSP source surfaces

| Area | Inspected personal DSP source and symbol | What it does not prove for Trusts |
| --- | --- | --- |
| Health | [`CBattleEntity::GetHPP`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/entities/battleentity.h) | Ally/Trust owner identity, fresh targeted observation and reliable healer recipient ranking |
| Party and role targeting | [`CLuaBaseEntity::getPartyMember`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/lua/lua_baseentity.h), [`CParty::GetPartyInfo`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/party.cpp) | Named Trusts represented as independent party members, correct owner, other Trust recipients, pet coexistence or 3–5 Trusts |
| Status/buffs | [`CStatusEffectContainer::HasStatusEffect`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/status_effect_container.h) | Complete current buff snapshots, timed expiry, correct targeted status, or safe null-vs-absent |
| BRD song stacking | [`CStatusEffectContainer::ApplyBardEffect`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/status_effect_container.h) | Trust song priority, maintained ally song buffs, song cap compatibility or observed effect application |
| COR status application | [`CStatusEffectContainer::ApplyCorsairEffect`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/status_effect_container.h) | Dice roll outcome, lucky/unlucky, Bust, Double-Up/Fold, per-ally status strength/coverage |
| GEO luopan | [`CPetController` uses `PETTYPE_LUOPAN`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/controllers/pet_controller.cpp) | Sylvie-like Indi/Entrust policies, legal aura targeting or Trust+luopan coexistence |
| Spell legality and events | [`CMagicState::CanCastSpell`, `MAGIC_USE`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/states/magic_state.cpp) | Cast-start/success vs landed Cure, status or interrupt; per-Trust real recast |
| Ability dispatch | [`CAIContainer::Internal_Ability / CanChangeState`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/ai_container.h) | Correct job ability availability, target legality, action arbitration/cancellation or observed effect |
| TP/WS properties | [`CLuaBaseEntity::getTP / getWSSkillchainProp`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/lua/lua_baseentity.h) | That generic pet Trusts can WS, a legal closer exists, or a real target/window is open |
| Pet Trust ownership | [`PETTYPE_TRUST`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/entities/petentity.h) and [generic pet controller](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/controllers/pet_controller.cpp) | A robust named Trust party/owner collection and independent Trust lifecycle; source reports a generic pet WS limitation |

**Why not use a blanket yes/no feature table?** Source access to `ApplyCorsairEffect` means the engine can apply a class of statuses; it does **not** mean a Trust can decide which roll to use, understand its numerical outcome, choose Double-Up or check the whole party received that roll. The same caveat applies to Bard stacking and GEO luopan support.

## Behavior inventory, ordered by likely future value

| Behavior / LSB reference | Primary constraints uncovered | Research recommendation |
| --- | --- | --- |
| **Emergency healer** — [Kupipi](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/kupipi.lua) | Trust roster, ally legality, Cure outcome | First runtime adapter proof once authorized |
| **Debuff remover** — Kupipi | Per-ally effect identity and cleanse result | Next after one legal Cure |
| **RDM buffer** — [Koru-Moru](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/koru-moru.lua) | Ally role targeting, Haste/Refresh effect confirmation | Reuse generic observed status and role selection |
| **Bard song upkeep** — [Joachim](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/joachim.lua) | Song stacking status exists but Trust song selection and effect coverage unverified | Build passive status/readback acceptance before active song behavior; LSB notes unfinished bard policy |
| **Corsair roll upkeep** — [Qultada](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/qultada.lua) | Roll result and ability recast unreviewed | First validate roll/party effect facts before roll strategy |
| **Corsair Double-Up** — Qultada cited *only as a limited comparator* | Actual Qultada Lua does **not** implement full Double-Up; numeric outcome and Bust policy unknown | Use [AshitaRoller4](https://github.com/professorpalmer/ashitaroller4) separately as policy research, not target server truth |
| **GEO Indi/Entrust** — [Sylvie UC](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/sylvie_uc.lua) | Need aura selection, owner target, luopan/pet coexistence | Qualify private interface before adapting old DSP pet logic |
| **Tank enmity** — [Trion](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/trion.lua) | Exact enmity owner and ability ready unavailable | Treat “attacked recently” as different from actual top-enmity source |
| **Tank interrupt** — Trion | Enemy windup and actual interrupt outcomes | Distinguish `MAGIC_START`, queued Flash and server effect |
| **Skillchain opener** — [Ayame](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/ayame.lua) | Trust WS dispatch, property mapping, target window | Depends on actual legal WS + skillchain observation |
| **Skillchain closer** — [Tenzen](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/tenzen.lua) | Valid WS, TP hold and observed opener/window absent | LSB closer implementation has a known validity TODO; do not inherit |
| **Magic burst** — [Shantotto II](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/shantotto_ii.lua) | Confirmed eligible element, target, window, spell result | Reference next after accepted WS outcome/SC readback |

This is **not 12 functional Trust roles**. These are **12 behavior requirements** used to estimate future adapter effort. The names and public LSB scripts are *source provenance*, not copied Trust AI code or validation of private Valhalla support.

## Machine-checkable classification

The standalone `tools/trust_role_capability_audit.py` loads the pinned JSON and returns one of:

- `SOURCE_SEAMS_FOUND`: every prerequisite cites a generic source symbol, but **runtime remains `NOT_TESTED`**, `runnable=false`, `dispatched=false`.
- `ADAPTER_GAPS`: one or more reviewed generic source seams require a dedicated Trust extension or safe actor/party/effect bridge.
- `SOURCE_UNKNOWN`: one or more indispensable features have **not been source-reviewed**; cannot infer support or absence. Takes precedence when gaps and unknowns coexist.

The audit **never** reports READY/RUNTIME_VERIFIED or success based only on reviewed source. Its reference code is a static inventory evaluator, **not** a scheduler, gameplay planner, packet decoder, Trust Lua interpreter, or action dispatcher. It doesn't connect to [#67 policy reference](https://github.com/sarthax/darkstar-to-valhalla/pull/67), [#69 source projection](https://github.com/sarthax/darkstar-to-valhalla/pull/69), or [#71 synthetic integration](https://github.com/sarthax/darkstar-to-valhalla/pull/71); all remain independent draft PRs.

## Test and release evidence

GitHub Actions `Trust role capability audit` is configured to run:

```bash
python3 -m py_compile tools/trust_role_capability_audit.py tools/test_trust_role_capability_audit.py
python3 tools/test_trust_role_capability_audit.py -v
python3 tools/trust_role_capability_audit.py
```

The focused suite uses only Python 3.11 standard library; it tests strict ID/revision/path/status validation, duplicate prerequisites, all 12 behavior classifications, absence of runtime-ready claims, deterministic reporting and misuse of private-source claims. The normal worker-gates workflow also applies to the exact PR head.

**No local or live tests were performed.** GitHub-hosted tests check only this **source inventory's correctness**, not any Trust's action effects, zones, packets, account safety, credentials or role intelligence on a running DSP/Valhalla server.

## What should happen next

1. Obtain independent review of this catalog against pinned public source symbols, correcting any stale or misinterpreted field. Merge only with owner authorization and CI green.
2. Ask Valhalla maintainers for **sanitized API contracts**, not private code: (a) ownership and party Trust roster, (b) usable legal spell/ability checks, (c) status snapshots and true roll/song/bubble applied effects, (d) target-specific WS/chain event readback, (e) authorized isolated testing process.
3. Use the answers to choose **one small, highest-impact end-to-end integration**, preferably a verified Cure on one Trust/owner in a disposable dev world, rather than rewiring all Trust entities.
4. Continue role/personality design only for capabilities whose prerequisites can be safely observed and whose action ownership is agreed. Carry all unsupported/unknown capabilities forward explicitly.

**Rebuild threshold:** a missing gambit decision engine is a *behavior-layer* gap. Rebuilding the Trust entity/party system should require actual Valhalla evidence that its existing pet-based ownership, multi-Trust targeting, lifecycle or status delivery are structurally incapable, as separately defined in [architecture PR #65](https://github.com/sarthax/darkstar-to-valhalla/pull/65). We have **not** established that.
