# Trust adapter contract v0 — source facts, not Trust commands

**Date:** 2026-10-22 · **Issue:** [#68](https://github.com/sarthax/darkstar-to-valhalla/issues/68) · **Program:** [#63](https://github.com/sarthax/darkstar-to-valhalla/issues/63)  
**Implementation:** [`tools/trust_adapter_contract.py`](../../../tools/trust_adapter_contract.py), [isolated tests](../../../tools/test_trust_adapter_contract.py), [18-field source crosswalk](trust_adapter_field_crosswalk_v0.csv).  
**Status:** synthetic, non-executing data projection only. No DSP/Valhalla actor adapter has been implemented or authorized.

## What we now know from source

The **user's personal DSP repository** at `19f00e357b78fe17411ede523a1acd01fe865ee8` exposes:
- [`CBattleEntity::GetHPP/GetMPP`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/entities/battleentity.h), current HP/MP state and [`CStatusEffectContainer::HasStatusEffect/GetStatusEffect`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/status_effect_container.h).
- [`CParty::members/GetPartyInfo`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/party.cpp), but ordinary player-party insertion requires a `TYPE_PC` actor. It cannot be assumed to contain pet Trusts.
- [`CPetEntity::PMaster` / `CCharEntity::PPet`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/entities/petentity.cpp) and [petutils single-pet creation](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/utils/petutils.cpp). A normal pet has **different ownership and roster semantics** from a named Trust member.
- [`CAIContainer::CanChangeState / Internal_Cast / Internal_Ability`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/ai_container.h), plus [`CMagicState` target, cost, spell and state validation and `MAGIC_START`/`MAGIC_USE` event listeners](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/states/magic_state.cpp). A cast that starts or changes AI state is **not proof that a buff, cure or status removal actually landed**.
- [`CLuaBaseEntity::getHP/getHPP/getMP/getTP/getPartyMember/hasStatusEffect/castSpell/useJobAbility`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/lua/lua_baseentity.h), but these aren't a reviewed Trust-specific safe behavior rule interface.

These methods are real **potential adapter seams** for a future approved DSP prototype, not evidence that Valhalla's private pet/Lua Trust system exposes the same bindings or class layout.

The [previous architecture comparison #64 / draft PR #65](https://github.com/sarthax/darkstar-to-valhalla/pull/65) showed *structural* limitations on bare DSP for multiple Trust actors/party members. It remains possible Valhalla has already solved these issues privately; the owner's report of working Trusts should not be challenged by absence of code in this personal fork.

## Why this is a new slice, not a new Trust AI

The independent [behavior-policy reference #66 / draft PR #67](https://github.com/sarthax/darkstar-to-valhalla/pull/67) defines **policy-v0** input fields such as `party`, `enemy`, `effects` and `ready_actions`, with three priority-based personalities and tri-state truths.

An actual adapter would have to take a **trusted, server-derived snapshot of current actor/party/combat facts** and produce those exact fields safely. We cannot legitimately write such an adapter for private Valhalla without approved source interfaces or target-server evidence. Nor can we blindly reuse old DSP's ordinary pet pointer for 3–5 Trust party members.

This slice therefore implements a **synthetic-only projection contract**. The code lives on a fresh `main` branch and **does not import or edit** the unmerged PR #67. It produces data that matches the field shape of the policy-v0 contract. That compatibility is a schema design target, not a tested cross-PR integration.

## Contract: exact input, explicit output

Inputs are JSON-compatible dictionaries with exactly these source fields:

`schema_version`, `source_kind`, `source_revision`, `now_ms`, `max_age_ms`, `zone`, `active`, `party_complete`, `self_id`, `owner_id`, `party`, `enemy`, `ready_actions`, `trust_ids`, `ordinary_pet_id`.

For synthetic profiles:
- `schema_version` must equal `trust-adapter-source-v0`.
- `source_kind` must be `synthetic_fixture`; `personal_dsp` and `private_valhalla` are **explicitly blocked** even if the input asserts complete or authoritative status. The adapter simply does not exist in those runtimes.
- `source_revision` is nonempty and returned with the result. This is **provenance text, not authentication**.
- `party` is at most six synthetic actors. `trust_ids` is a separate 0–5-member identity list; `self_id` must name a Trust included in the party; the owner must be present, but not also a Trust. An optional `ordinary_pet_id` **must remain distinct and outside the party**.
- Actors have exactly `id`, `zone`, `observed_ms`, `alive`, `roles`, `hp_pct`, `mp_pct`, `effects`; `enemy` adds `casting`. Duplicate entity identities, future observations, invalid percentages/effects and unrecognized roles are rejected. Synthetic actors are **not client/DSP numeric IDs**.
- Action readiness uses an allowlist of seven **symbolic** names used by the current policy-v0 example: `cure`, `regen`, `provoke`, `flash`, `sentinel`, `haste`, `refresh`. No numeric spell/ability IDs, Lua functions or executable expressions are accepted.

Outputs are one frozen `Projection`:

| Source | Output status | `policy_snapshot` | Meaning |
| --- | --- | --- | --- |
| `synthetic_fixture`, valid shape | `SYNTHETIC_ONLY` | Deep-copied policy-v0-compatible facts | Safe offline experiments **only** |
| `personal_dsp`, valid shape | `BLOCKED` | `None` | No authenticated source adapter exists |
| `private_valhalla`, valid shape | `BLOCKED` | `None` | Private runtime interface unknown |
| Invalid source/schema | Exception | None | Fail-closed invalid input |

**Staleness rule:** if an actor is out-of-zone or observed older than `max_age_ms`, the synthetic projector replaces that actor's HP/MP, alive, roles and effects with `null`; enemy `casting` becomes `null`. A stale/out-of-zone *party member* forces `party_complete=null` rather than silently dropping the actor. `effects=[]` only means known empty, while `effects=null` means **UNKNOWN**, never “no buff.”

**Not an authorization model:** a caller could forge a synthetic input. That is acceptable only because the result is marked `SYNTHETIC_ONLY` and has no dispatch API. A future real adapter must prove stable actor identity/incarnation, party membership, authoritative effects and spell readiness through its owner-side code, and should not treat this simulation contract as a permission grant.

## Why this boundary reduces rebuild risk

A behavior engine requires **observations and safe symbolic proposals**. If Valhalla's existing private Trust system can supply owner, party member statuses, usable spell/action checks and a valid action path, this contract can be adapted to its existing pet controller without introducing an LSB Trust actor.

The practical **rebuild trigger** remains structural, not behavioral: if multi-Trust identity, buff targeting, pet coexistence, party packets or lifecycle cannot be made correct in the existing private system, repair those subsystems specifically. This contract does **not** decide whether they already work.

| Category | Public DSP read available | Trust-specific caveat | Next source question |
| --- | --- | --- | --- |
| Identity and zone | Entity ID, `loc.zone`, owner pet relationship | Only one ordinary `PPet` slot | Does Valhalla track independent Trust identities and owners? |
| Party | `CParty` members and stats | PC-only insertion, Trust membership not proven | Does existing Trust roster show up in ally buffs and zone updates? |
| Self/ally health | `GetHPP/GetMPP` | Must resolve actual Trust targets, not a cached zone slot | Are role and freshness available in Trust Lua or a safe helper? |
| Effects | `StatusEffectContainer` | “No effect” requires a fresh, complete snapshot | Can pet Lua read owner/other Trust effects? |
| Enemy action | `CMagicState` and event hooks | Cast start is distinct from cast result | Is enemy windup exposed to Trust AI? |
| Ability/spell readiness | `CanChangeState`, cast prechecks | Recast, target legality, spell/job rules remain authoritative | Which specific Trust API can check a legal spell before dispatch? |
| Outcome | Magic-use events and target status | Accepted/dispatched vs actually applied must differ | Can adapter observe healing/buff changes after a call? |

## Offline acceptance and explicit limits

Dedicated offline test command:

```bash
python3 tools/test_trust_adapter_contract.py -v
```

`trust-adapter-contract.yml` runs this isolated Python 3.11 test and syntax compilation, independently of the repository's existing `worker-gates.yml`. The focused test suite checks schema rejection, multi-Trust identities, ordinary-pet isolation, one-to-six actors, party completeness, out-of-zone and stale actor facts, missing effects, readiness tri-state, deterministic copies, malformed values, cancellation inputs and blocked runtime source kinds.

**No live tests were run.** This slice makes no claims about the real Valhalla Trust implementation, NPC spells, action IDs, combat timing, status completeness, pet coexistence on a running server or correctness of other PRs under review. It does not copy LSB implementation code. LSB's [gambit evaluator](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/src/map/ai/helpers/gambits_container.cpp) was used only as conceptual source inspiration.

## Next owned slice only after review

1. Independently review source symbols in the [field crosswalk](trust_adapter_field_crosswalk_v0.csv); note uncertain private Valhalla hooks explicitly.
2. Once #66/#67 and this PR are reviewed, add one **offline integration test** that feeds a synthetic adapter snapshot into the tri-state policy and proves the output remains non-executable. Do it in a separate issue/branch, not by cherry-picking unreviewed code.
3. Seek approved Valhalla maintainer answers about actual Trust entity ownership, party roster, effect access, action legality and lifecycle. **No need to demand private repository access**.
4. Only then propose one bounded Trust-targeted server callback on the personal DSP test environment with its C++ Lua binding, source IDs, worker review, CI and authorized local gameplay acceptance.

**Current state:** the behavior abstraction and source field seams are becoming concrete; the actual Valhalla adapter and its actor/party integration remain **UNKNOWN**.
