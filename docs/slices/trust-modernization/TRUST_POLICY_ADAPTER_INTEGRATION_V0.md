# Trust adapter + personality integration, synthetic reference v0

**Date:** 2026-10-22  
**Tracking:** [#70](https://github.com/sarthax/darkstar-to-valhalla/issues/70), program [#63](https://github.com/sarthax/darkstar-to-valhalla/issues/63)  
**Dependencies:** [PR #67](https://github.com/sarthax/darkstar-to-valhalla/pull/67) (personality policy), [PR #69](https://github.com/sarthax/darkstar-to-valhalla/pull/69) (source adapter); [PR #65](https://github.com/sarthax/darkstar-to-valhalla/pull/65) structural study independent.  
**Status:** online GitHub integration development and synthetic GitHub Actions CI only. **No local testing, private Valhalla inspection, server runtime integration, live Trust runs or gameplay verification.**

## What the online integration now demonstrates

This integration branch contains both separately reviewed prototype histories and a new non-executing orchestration function:

```
synthetic fixture, versioned source
           │
           ▼
  trust_adapter_contract.project()
           │
        validation
  source_kind == synthetic_fixture?
       /       \
   blocked    synthetic facts only
                │
                ▼
trust_policy_reference.evaluate(profile)
                │
                ▼
  replay(): proposed action or blocked/unknown/inhibited/no match
                │
                ▼
 immutable Replay: gameplay_verdict == NOT_TESTED
                  dispatch_performed == false
                  effect_observed == false
```

These results are *only hypothetical choice simulations*. An example `SYNTHETIC_PROPOSAL:cure(owner)` demonstrates that the conditional rule selected symbolic Cure under mock HP facts; it does not show that a real Trust can learn, cast, complete or apply Cure on a DSP or Valhalla server.

The composition remains isolated from `src/`, `scripts/`, `sql/`, `Game/`, `Routines/`, credentials, packet assets or a live session.

## Branch ancestry and merging rules

As of this research:
- Draft PR #67 source head `30206d6e15352d63c01cf9345ae536a7a0d1a604`.
- Draft PR #69 source head `9028034274500f529ca420123c8248cc1d6f10a5`.
- The *new integration branch only* contains a two-parent merge commit `70c26c36bad6d2e8cddb6b1ddd99516a9c4647dc` preserving both commit histories, using the already-reviewed source file blob SHAs from #67 and #69. Neither original PR branch was modified and neither was merged to `main`. No force-push/rebase.

**This is a dependency PR, not permission to merge previous drafts.** Recommended future release order: independent review of #67 and #69 → merge approved dependencies to main at reviewed heads → reconcile this integration branch to then-current main with history-preserving operations and rerun exact-head CI → independent review → owner authorizes merge. If either dependency requires fixes, this integration branch must be reconciled to the reviewed source before acceptance. #65 remains a separate research PR; its structural actor/party claims should not be regarded as implemented.

## Integration contract

| Artifact | Meaning | Runtime claims |
| --- | --- | --- |
| `SOURCE_BLOCKED` | Caller says personal DSP or private Valhalla, neither adapter exists | **No projection**, never dispatch |
| `SYNTHETIC_PROPOSAL` | Mock facts lead to one rule's symbolic action/target | **No action dispatched**, no effect observed |
| `BLOCKED_UNKNOWN` | Required mock roster, enemy, freshness, buff or readiness input unknown | No proposal, cannot infer false from unknown |
| `INHIBITED` | Synthetic controller marked inactive | No proposal |
| `NO_MATCH` | Valid mock facts satisfy none of the allowlisted conditional rules | No proposal |

Every `Replay` carries `profile_id`, profile version, source kind/revision, rule ID, symbolic action+target if any, and a SHA-256 **debug fingerprint** of the *provided fixture+profile bundle*. This digest is for comparing deterministic fixture inputs, **not** a signature, authentication or a server evidence digest. All `Replay` instances have `gameplay_verdict=NOT_TESTED`, `dispatch_performed=false`, and `effect_observed=false` by design. There is no `execute`, `dispatch`, `send` or server-call method.

## Online CI scenario coverage

`python3 tools/test_trust_policy_adapter_integration.py -v` evaluates 26 synthetic integration cases:

- Healer emergency cure, routine cure, owner Regen, healthy/no-match and source provenance.
- Tank reactive interruption, fallback defense, normal threat reaction and stale/absent enemy.
- Support Haste, Refresh, emergency rescue, absent vs unknown buffs and unavailable recasts.
- Stale and cross-zone party facts, incomplete rosters, unknown action readiness and inhibited activity.
- Explicit rejection of "personal_dsp" and "private_valhalla" runtime claims, duplicate Trust IDs, ordinary pet identity collisions, invalid schema, invalid clocks and unsupported actions.
- Input immutability, deterministic outcomes and debug digest changes on altered mock facts.
- No case claims Trust execution or authoritative Valhalla/DSP compatibility.

The new `.github/workflows/trust-policy-adapter-integration.yml` runs **the original policy 29 cases + adapter 23 cases + this 26-case suite** under Python 3.11, *isolated from unrelated database-dependent test discovery*. Repository worker-gates run separately. Check actual GitHub Actions results before asserting pass counts.

## Remaining source and deployment gaps

**Not established by any test in this series:** existence of Valhalla's private Trust Lua interface, its party/normal-pet coexistence, effect and zone/source freshness guarantees, correct spell/ability IDs and legal targets, cast execution/readback, authoritative cooldowns, claim and cancel semantics, WS/MB and skillchain windows, or Trust tick performance.

The [DSP source gap ledger](https://github.com/sarthax/darkstar-to-valhalla/pull/65) flags differences in one-pet owner fields and player-party membership. The [adapter schema #69](https://github.com/sarthax/darkstar-to-valhalla/pull/69) intentionally handles those as fake distinct actor IDs in simulation; this does **not** repair DSP structures.

### Future development before deeper brains

A separately owned research slice can draft an **operator/maintainer interface questionnaire** covering private Valhalla's Trust creation, ownership collection, party target legality, health/status, action arbitration, and cleanup, with no request for proprietary code. After approved replies, propose *one bounded server-adapter proof* on the user's personal DSP migration fork. That later work would need independent review, a verified build/ID source, authorization, local live tests and completion evidence. No such work is authorized or performed here.
