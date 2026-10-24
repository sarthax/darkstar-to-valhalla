# Valhalla Trust authoring handoff — basic pet Lua first, advanced AI later

**Status:** repository research and owner-authoring workflow clarification · **Date:** October 22, 2026  
**Tracker:** [Trust authoring #74](https://github.com/sarthax/darkstar-to-valhalla/issues/74) · parent [Trust modernization #63](https://github.com/sarthax/darkstar-to-valhalla/issues/63)  
**Structured companion:** [Owner/AoE/unknown targeting matrix](VALHALLA_PET_TRUST_TARGET_CAPABILITIES_V0.csv)

## Corrections to the earlier plan

**The accessible `sarthax/darkstar-to-valhalla` repository is the owner's personal DSP-derived migration workbench, NOT the private deployed Valhalla codebase.** The owner reports that Valhalla **already operates Trusts** built on relatively basic *customized pet Lua*, not LSB's advanced Trust/gambit executor.

The owner also reports from recollection (not verified against the private source or live server):
- A Trust's direct single-target **healing** targets the player who summoned it — the **master/summoner**, not an arbitrary party member.
- Certain Trusts can perform **AoE healing** whose normal effect reaches other eligible party members. This is not evidence that the Trust selects which ally most needs help.
- The Valhalla maintainers have asked the owner to **author new Trusts in a simple pet-Lua format**, and have said **they will rebase/adapt them** to their own customized implementation as needed.
- The owner does **not have access** to the private Trust extension; the work must not depend on obtaining or guessing that code.

**Consequences:** the previously proposed first live integration, “select the lowest-HP party member and cast single-target Cure,” **must NOT be the first Valhalla-compatible implementation target**. It silently assumes non-owner-targeted healing that is not established and may be prohibited by the pet model.

The correct near-term deliverable is **a reviewable, basic pet-style Trust submission package**, with role identity, a small set of allowed owner-focused actions, optional *approved* AoE support, and explicit target limitations. Higher intelligence remains a **separate optional project**, requiring consent and private-runtime interface support from maintainers.

## Critical difference: information, target legality, and effect reach

A pet Trust could know how to heal the master yet not know that an **unrelated party member** is injured. An AoE Cure might legally heal nearby players **without the Trust ever directly selecting those players**. Therefore define three independent questions:

| Dimension | What must be established | What owner-reported behavior suggests |
| --- | --- | --- |
| **Observation** | Can the Trust read each party member's HP/status/position, or only the master? | UNKNOWN. Do not infer group sensing from AoE effects |
| **Direct targeting** | May the Trust request a legal single-target Cure on a non-master player or another Trust? | Owner recalls **master-only** for direct healing |
| **Area effects** | Does a spell cast on an approved center apply to other eligible group members in radius? | Owner recalls **some AoE heal spells do**, exact spells/radius/eligibility UNKNOWN |

**A smarter rule set cannot bypass a server target-validation rule.** Adding an LSB-style priority table alone does not make single-target support of other party members legal. Likewise, a valid AoE spell does not imply that a script can prioritize its timing based on ally HP or that it affects other Trusts, normal pets, alliances, or everyone in range.

## Source facts: what the personal DSP workbench actually exposes

These are **available generic DSP interfaces**, not authorized Valhalla Trust APIs:

- [`CLuaBaseEntity::getMaster`, `getPet`, `getPartyMember`, `getPartySize`, `castSpell`, `useJobAbility`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/lua/lua_baseentity.h) — declared generic Lua bindings. The existence of `getPartyMember` does **not** prove that a custom Valhalla pet Trust can legally target anyone it returns.
- [`CPetController::DoRoamTick`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/controllers/pet_controller.cpp) — normal pet following, life and engagement behavior depends on the master.
- [`CPetEntity::ValidTarget`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/entities/petentity.cpp#L230-L237) — contains pet-specific target filtering; actual spell legality also depends on its spell group and recipient. **Do not read one condition in this function as proof of all Valhalla heal restrictions.**
- [`CMagicState::CanCastSpell`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/ai/states/magic_state.cpp#L164-L247) — generic spell zone, status, cost, target/range and visibility validation. It does not tell us which customized Trust healing spells use what recipient selection or AoE effect filter.
- [`CStatusEffectContainer::ApplyBardEffect` and `ApplyCorsairEffect`](https://github.com/sarthax/darkstar-to-valhalla/blob/19f00e357b78fe17411ede523a1acd01fe865ee8/src/map/status_effect_container.h) — generic effect logic, **not** proof that a pet Trust has BRD/COR role strategy or party-wide benefit.

The public source tree did not reveal Valhalla's private Trust loader, Trust-specific Lua callbacks, accepted file structure, additional target logic or multi-Trust collection. No private source was accessed or reverse-inferred.

## Practical two-track plan

### Track A — Trusts we can author for the maintainers now (preferred)

Make **small, independent pet-Lua submissions** in the format they specify. Do not preemptively copy or port LSB's full C++ Trust engine. Each submitted Trust should have a concise *behavior intent sheet*:

1. **Identity and role:** proposed named Trust, job archetype, master-follow style, melee/ranged/idle preference, support/defense focus.
2. **Action eligibility:** a narrow symbolic list of intended Cure/buff/weapon-skill/ability families, and conditions with explicit **master-only** or **approved AoE** targets. Any numeric spell, model, event, or entity IDs must come from the owner's local client/DSP tables or maintainer-approved mapping; **never guess IDs**.
3. **Master-facing rules:** examples such as “when master HP is low and Cure is available, prefer Cure on the master,” using **only real, confirmed callbacks and authoring syntax** once a working example is provided. No invented functions such as `trust:getPartyMemberHP()`.
4. **AoE rules:** “if this Trust has a maintainer-approved group heal, invoke through the accepted spell/target path.” Document which action center, effect radius, and party beneficiaries **need confirmation**; don't manually iterate over party actors to simulate AoE.
5. **Conservative fallback:** when target, spell availability, recast or scope is unknown, do not issue an unsupported targeted cast. Ordinary attacking/following should remain delegated to existing pet behavior.
6. **Maintainer adaptation record:** which Lua callback/file path/API had to be changed to rebase the submission; what target legality and effect behavior were actually observed after adaptation. Treat that transformed version as the **authoritative deployed implementation**, rather than claiming identical behavior from the submitted source.
7. **Acceptance evidence:** maintainer-reviewed server revision, relevant Trust script revision, ID provenance, test scenario, observed result and limitations.

**Do not commit a runnable Trust Lua stub yet.** The maintainers offered to rebase basic pet Lua, but **the actual accepted example, file path, registration, loader and callback signatures were not provided**. Inventing an executable `onTrustTick` or calling an imagined Trust API would waste their time or create deceptively plausible, nonfunctional scripts.

### Track B — Longer-term intelligent Trust architecture (optional)

Continue to research LSB-style role priorities and personalities from [source audit #73](https://github.com/sarthax/darkstar-to-valhalla/pull/73), [gambit policy #67](https://github.com/sarthax/darkstar-to-valhalla/pull/67), [adapter contract #69](https://github.com/sarthax/darkstar-to-valhalla/pull/69) and [composed synthetic scenarios #71](https://github.com/sarthax/darkstar-to-valhalla/pull/71). **Those are only design and GitHub Actions synthetic proofs, not target-server-compatible Trust AI.**

For true arbitrary party-member healing, five distinct server contracts would be required:
- **Roster:** trustworthy master, party and Trust identities; pet coexistence.
- **Observation:** per-ally current HP, status, distance and zone.
- **Target legality:** a Trust's ability to select that ally and cast an approved spell.
- **Effects:** target-specific outcome (Cure landed/status removed) rather than just cast dispatch.
- **Arbitration:** action availability, cooldown, cancellation, in-flight state and bounded priority evaluation.

A **small private pet-Lua adapter extension** could suffice if maintainers can expose these capabilities. **Rebuild the underlying actor/party architecture only if evidence shows its existing implementation cannot support the required contracts** and maintainers are willing to change it. The mere absence of LSB gambits does not justify replacing Valhalla's working Trusts.

## Role priorities with the owner's target limitation

| Role | Track A pet-style behavior | Advanced Track B requirement |
| --- | --- | --- |
| **Healer** | Direct Cure of **master**, plus maintainer-approved AoE heal | Fresh per-ally HP/priority and legal direct ally healing |
| **Cleanser** | Owner status cleanup only *if confirmed supported* | Per-ally negative effect readback, target legality, removal proof |
| **Bard/RDM** | Master-focused song/buff intent or approved area benefit | Per-role target selection, stacking/refresh timing, group effect truth |
| **Corsair** | Maintain approved roll ability if Trust variant supports it | Numeric roll result, Double-Up/Bust, recipients and party-wide state |
| **Geomancer** | Allowed aura spells, with pet slot and effects explicitly verified | Luopan/Trust coexistence, buff scope, Entrust recipients |
| **Tank/DD** | Existing pet follow/engage/allowed skills | Cooperative enmity, WS property and skillchain window policy |
| **Magic burst caster** | Existing permitted spell repertoire | Verified target chain/burst window, correct element and cast outcome |

The goal is to deliver **useful, honestly scoped Trust submissions to Valhalla first**, rather than waiting for a large hypothetical architecture project.

## Specific maintainer handoff — minimal answers, no code access needed

For the first portable Trust submission, ask a maintainer only for:

- One **sanitized, approved example of their accepted basic pet-Lua Trust script**, its relative file path and expected callback names.
- Whether **direct Cure targets only the summoner**, and if this limitation applies to **other single-target support spells** or specifically to healing.
- Which **AoE Cure/Curega family spells** are approved for pet Trusts, how the cast center is chosen and which party members/other Trusts/pets are actually affected.
- Whether Trust Lua can **read other party members' HP/status** even if it cannot directly target them.
- How to register a new named Trust's entity/job/spells and where sourced IDs come from, without including any private code in a public repo.
- Their preferred **submission layout and rebase/review process**: what the author should provide, what maintainers adapt, and which local acceptance evidence can be shared.

These can be answered by a short interface description or one approved public example; no proprietary repository access is necessary. Until then, advanced recipient support must remain an explicit requirement, not an assumed feature.

## Review status and proof boundaries

- **Owner-reported, not independently verified:** direct Cure master-only; some AoE healing reaches party; maintainers accept basic pet Lua then adapt/rebase.
- **Public-source verified:** generic personal-DSP Lua/pet/spell/status API symbols in the pinned workbench. Those symbols are **not a contract for private Valhalla**.
- **Design-only:** LSB personalities, extended ally-target gambit systems, and all simulated GitHub Actions tests.
- **Not performed:** local/server gameplay tests, actual Trust submissions, spell targeting verification, private Lua integration, deployment, performance or pet/Trust coexistence trials.

This document and its matrix are **documentation only**. No executable Lua, C++, SQL, client DAT, IDs or Trust engine changes are part of this research PR.
