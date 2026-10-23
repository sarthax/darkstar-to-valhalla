# Trust behavior reference v0 — composable personalities without a Trust engine rewrite

**Issue:** [#66](https://github.com/sarthax/darkstar-to-valhalla/issues/66)  
**Program:** [#63](https://github.com/sarthax/darkstar-to-valhalla/issues/63)  
**Architecture source:** [#64 / draft PR #65](https://github.com/sarthax/darkstar-to-valhalla/pull/65)  
**Status:** deliberately standalone Python 3.11 **research reference**; no server/runtime integration, no Trust, pet or client actions.

## Goal and non-goals

Provide a deterministic, **side-effect-free behavioral contract** which can express some of the *declared preferences* found in LSB's named Trust Lua scripts without selecting an entity architecture prematurely. The output is **at most one symbolic action proposal**; no magic/ability IDs, action packets, Lua bindings, networking, process access or tool/gameplay commands are exposed.

This is a research prototype in the owner's personal DSP migration workbench. **It is not Valhalla's private code or proof that its simple pet-Lua Trusts support these interfaces.** The private deployment is an optional future compatibility adapter, not assumed source.

Two tasks must remain separate:

- **Behavior**: choose *what kind of beneficial or defensive action might be appropriate* using observed facts and a profile.
- **Execution**: check game permissions, real spell/ability availability, party membership, target legality, recast, cast-state conflicts, movement, claim, cost, and server result; the **actual trusted game server** must own these decisions. This prototype contains none of that integration.

### Source inspirations (ideas re-expressed in original Python, not copied Lua)

[LSB `kupipi.lua`](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/kupipi.lua) uses an urgent and routine cure threshold; [`trion.lua`](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/trion.lua) has reactive interruption/defensive ability rules; [`koru-moru.lua`](https://github.com/LandSandBoat/server/blob/ed34371b7477713c9db9b9758f92df597a65e4ab/scripts/actions/spells/trust/koru-moru.lua) chooses buffs according to recipients' roles. All were reviewed against LSB SHA `ed34371b7477713c9db9b9758f92df597a65e4ab`.

These fixtures are **simplified abstractions**, not accurate full retail/LSB Trust behavior or a complete order of their source gambits. None of the example characters' hidden private Valhalla implementations were consulted.

## Reference files

| File | Purpose |
| --- | --- |
| `tools/trust_policy_reference.py` | Pure rule/profile/snapshot validator and deterministic proposal evaluator |
| `tools/test_trust_policy_reference.py` | Synthetic unit tests including three-state truth and safety cases |
| `docs/slices/trust-modernization/trust_personality_examples_v0.json` | Three versioned **symbolic-only** behavioral personas |
| `.github/workflows/trust-policy-reference.yml` | Automated Python 3.11 offline tests for this exact code, independently of normal DSP worker-gates |

## Contract v0 — identities, evidence, facts

Profile bundle:

```json
{
  "schema_version": "trust-policy-reference-v0",
  "profiles": [
    {
      "id": "healer_triage_v0",
      "version": 1,
      "source": "LSB-inspired hypothetical behavior",
      "rules": [
        {
          "id": "emergency_cure",
          "priority": 10,
          "target": "lowest_hp_party",
          "conditions": [{"op": "hp_at_most", "value": 25}],
          "action": "cure"
        }
      ]
    }
  ]
}
```

The actual fixture bundle defines **three** named profiles:

1. **`healer_triage_v0`** — lowest-HP party member at or below 25% first, then ordinary healing at or below 75%, followed by owner Regen upkeep.
2. **`defensive_tank_v0`** — observed enemy casting → propose Flash; if Flash unavailable and own Sentinel missing, propose Sentinel; otherwise enemy-alive Provoke preference. **This is *not* validation that the Trust has or can use those abilities.**
3. **`support_upkeep_v0`** — emergency rescue at or below 35% first, then Haste on a melee recipient lacking it, then Refresh on a caster recipient lacking it.

Reference **target selectors** are explicitly allowlisted: `self`, `owner`, `lowest_hp_party`, `tank`, `melee`, `caster`, `enemy`. Reference **predicates**: `hp_at_most`, `mp_at_most`, `status_present`, `status_absent`, `enemy_casting`, `target_alive`. Reference **actions**: `cure`, `regen`, `provoke`, `flash`, `sentinel`, `haste`, `refresh`.

**None are in-game numeric IDs**. No source code, executable Lua, arbitrary Python expressions, dynamic imports or user-provided callable fields are accepted. The evaluator requires exact field names, bounded rules and condition lists, unique priority and rule identifiers, sane HP/MP percentages, unambiguous actor identity and only allowlisted actions.

Snapshot facts are **synthetic caller assertions** of:

- `now_ms`, `max_age_ms` (monotonic relative fixture clock, **not network or timestamp provenance**);
- `zone` (e.g. `fixture-zone`, deliberately not a real DSP numeric zone ID);
- `active` (true/false/null), `party_complete` (true/false/null);
- `self_id`, `owner_id`, `party` (up to six named synthetic actors), `enemy`;
- `ready_actions` (dictionary of action-name → true/false/null).

Each synthetic actor carries a unique `id`, `zone`, `observed_ms`, `alive`, `roles`, `hp_pct`, `mp_pct`, `effects` and the enemy adds `casting`. Missing knowledge is an explicit **null**. The evaluator rejects invalid shapes and ambiguous duplicate actor IDs. `effects=[]` means an explicitly observed empty set, whereas `effects=null` means the effects are **UNKNOWN**.

A real adapter will need **trusted game-derived provenance**, server control authority, actor and target incarnation/slot reuse guards, packet/state continuity and authoritative job/action availability. This v0 model has **none of those integrations** and may not be handed straight into the DSP or XIHeadless dispatcher.

## Evaluation algorithm and conservative uncertainty

- Validate the entire profile and snapshot before any proposal.
- `active=false` returns `INHIBITED`; `active=null` returns `BLOCKED_UNKNOWN`.
- Evaluate strictly by ascending unique numeric rule priority.
- Resolve a target using role selector, owner, lowest HP, or enemy. A role-based target requires a complete same-zone party roster; stale/incomplete actor facts result in `BLOCKED_UNKNOWN`.
- Sort target IDs deterministically when several eligible role recipients exist; tie-break equal HP by ID. No random movement, action, timers or side effects.
- Evaluate all conditions as AND: a proven false can rule out a candidate; an unresolved condition returns `BLOCKED_UNKNOWN`.
- Require an explicit eligible action readiness of `true`. Unknown/null/missing readiness blocks the proposal; false skips it without issuing a command.
- Return at most one frozen `Decision`: `PROPOSED`, `BLOCKED_UNKNOWN`, `INHIBITED`, or `NO_MATCH`. Proposals include symbolic `action`, `target_id`, `rule_id`, `profile_id` and `profile_version`.

**Conservative priority rule:** An unresolved higher-priority safety/triage predicate blocks all lower-priority actions. For example, if the party roster contains a stale member or an unknown HP value, the evaluator refuses to recommend Haste instead of potentially needed Cure. This is intentionally conservative for a safe reference; a future richer scorer may prove independence between rules, but must justify it with tests.

**Not simulated:** actual healing amount, damage, TP retention, WS/MB window, bust/recast, buff overwrites, enemy enmity, phase transitions, action retries, cooldown consumption, ability ownership, attack permission, network timing, sleep/wake, or real combat result. A `PROPOSED` status is **not** a command dispatched or even an allowed spell for a particular character.

## Tests and reproducibility

Use Python 3.11 standard library only. No DSP/MySQL/Windows/Ashita dependency:

```bash
python3 -m unittest discover -s tools -p 'test_trust_policy_reference.py' -v
```

The repo's default `worker-gates.yml` checks paths, Lua and SQL safety but **does not itself execute new Python tests**; this slice adds a dedicated, narrowly scoped GitHub Actions test workflow for the reference evaluator.

The test suite covers triage urgency, healthy/no-match, unknown HP vs actual absence, stale actor and incomplete roster, wrong zone, action readiness unknown/unavailable, explicit buff absence vs unknown, enemy reactive priorities, deterministic role and HP ordering, negative/invalid/schema field handling, collision detection, cancellation/inactivity and proof that the evaluator does not mutate inputs or provide execute/dispatch methods.

CI assertions establish only **offline implementation properties** and the correctness of these synthetic examples. They do not establish real server behavior, Valhalla compatibility, Trust personality accuracy or live player/Trust safety.

## Go/no-go for later adapter work

**GO**: evolve data-only rule vocabulary, add offline test fixtures for alternative healer/tank/buffer personalities, and map missing LSB predicates to available old DSP server facts.

**WAIT**: create an executable DSP/Valhalla adapter until the real Trust actor's party/target/cast interfaces and deployment-owner approval are known. Before real integration, source the ability/spell IDs against the target server; confirm all action execution/recast/outcome semantics, concurrent state arbitration and cancellation, and run trusted isolated acceptance cases.

**NO-GO**: make these JSON snippets executable Lua, import GPL C++ code wholesale, grant client-originated `ready_actions` unrestricted authority, use guessed numeric IDs, add a second combat loop, or treat a candidate proposal as landed action. The structural rebuild criteria remain in [#64 / PR #65](https://github.com/sarthax/darkstar-to-valhalla/pull/65); this slice is deliberately independent.
