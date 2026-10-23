"""Standalone, non-executing Trust personality rule reference (schema v0).

Only evaluates sanitized, synthetic facts into a proposed *symbolic* action.
It cannot invoke FFXI, DSP, Valhalla, sockets, Lua, or a combat dispatcher.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Any, Mapping


class Truth(Enum):
    FALSE = "false"
    TRUE = "true"
    UNKNOWN = "unknown"


class DecisionStatus(Enum):
    PROPOSED = "proposed"
    BLOCKED_UNKNOWN = "blocked_unknown"
    INHIBITED = "inhibited"
    NO_MATCH = "no_match"


@dataclass(frozen=True)
class Decision:
    status: DecisionStatus
    profile_id: str
    profile_version: int
    rule_id: str | None = None
    action: str | None = None
    target_id: str | None = None
    reason: str = ""

    # No execute(), dispatch(), socket, game state mutation, or background loop.


_ALLOWED_TARGETS = {
    "self", "owner", "lowest_hp_party", "tank", "melee", "caster", "enemy"
}
_ALLOWED_ACTIONS = {
    "cure", "regen", "provoke", "flash", "sentinel", "haste", "refresh"
}
_ALLOWED_OPS = {
    "hp_at_most", "mp_at_most", "status_present", "status_absent",
    "enemy_casting", "target_alive"
}
_PARTY_TARGETS = {"owner", "lowest_hp_party", "tank", "melee", "caster"}
_REQUIRED_PROFILE = {"id", "version", "source", "rules"}
_REQUIRED_RULE = {"id", "priority", "target", "conditions", "action"}
_REQUIRED_CONDITION = {"op"}
_REQUIRED_SNAPSHOT = {
    "now_ms", "max_age_ms", "zone", "active", "party_complete",
    "self_id", "owner_id", "party", "enemy", "ready_actions"
}


def _text(value: Any, label: str) -> str:
    if not isinstance(value, str) or not value or len(value) > 128:
        raise ValueError(f"{label} must be a nonempty bounded string")
    return value


def _int(value: Any, label: str, minimum: int = 0) -> int:
    if type(value) is not int or value < minimum:
        raise ValueError(f"{label} must be an integer >= {minimum}")
    return value


def _tristate(value: Any, label: str) -> None:
    if value is not None and type(value) is not bool:
        raise ValueError(f"{label} must be true, false, or null (unknown)")


def _percentage(value: Any, label: str) -> None:
    if value is None:
        return
    if type(value) not in (int, float) or not 0 <= value <= 100:
        raise ValueError(f"{label} must be null or a percentage from 0 to 100")


def validate_profile(profile: Mapping[str, Any]) -> None:
    """Reject unknown executable fields rather than accepting arbitrary DSL code."""
    if not isinstance(profile, dict) or set(profile) != _REQUIRED_PROFILE:
        raise ValueError("profile keys must exactly match reference schema v0")
    _text(profile["id"], "profile.id")
    _int(profile["version"], "profile.version", 1)
    _text(profile["source"], "profile.source")
    rules = profile["rules"]
    if not isinstance(rules, list) or not rules or len(rules) > 64:
        raise ValueError("profile.rules must have between 1 and 64 rules")
    ids, priorities = set(), set()
    for r in rules:
        if not isinstance(r, dict) or set(r) != _REQUIRED_RULE:
            raise ValueError("rule has unexpected or missing fields")
        ident = _text(r["id"], "rule.id")
        priority = _int(r["priority"], "rule.priority")
        if ident in ids or priority in priorities:
            raise ValueError("rule ids and priorities must be unique per profile")
        ids.add(ident)
        priorities.add(priority)
        if r["target"] not in _ALLOWED_TARGETS:
            raise ValueError("unknown target selector")
        if r["action"] not in _ALLOWED_ACTIONS:
            raise ValueError("unknown symbolic action")
        conds = r["conditions"]
        if not isinstance(conds, list) or not 1 <= len(conds) <= 8:
            raise ValueError("rules require 1–8 AND conditions")
        for c in conds:
            if not isinstance(c, dict) or c.get("op") not in _ALLOWED_OPS:
                raise ValueError("invalid condition")
            op = c["op"]
            expected = {"op", "value"} if op in {
                "hp_at_most", "mp_at_most", "status_present", "status_absent"
            } else {"op"}
            if set(c) != expected:
                raise ValueError("condition uses unexpected arguments")
            if op in {"hp_at_most", "mp_at_most"}:
                _percentage(c["value"], "condition.value")
                if c["value"] is None:
                    raise ValueError("threshold cannot be unknown")
            elif op in {"status_present", "status_absent"}:
                _text(c["value"], "condition.value")


def _validate_actor(actor: Mapping[str, Any], label: str, enemy: bool = False) -> None:
    if not isinstance(actor, dict):
        raise ValueError(f"{label} must be an object")
    keys = {"id", "zone", "observed_ms", "alive", "roles",
            "hp_pct", "mp_pct", "effects"}
    if enemy:
        keys.add("casting")
    if set(actor) != keys:
        raise ValueError(f"{label} has unexpected/missing keys")
    _text(actor["id"], f"{label}.id")
    _text(actor["zone"], f"{label}.zone")
    _int(actor["observed_ms"], f"{label}.observed_ms")
    _tristate(actor["alive"], f"{label}.alive")
    _percentage(actor["hp_pct"], f"{label}.hp_pct")
    _percentage(actor["mp_pct"], f"{label}.mp_pct")
    if actor["roles"] is not None:
        roles = actor["roles"]
        if not isinstance(roles, list) or len(roles) > 8 or any(
            role not in {"tank", "melee", "caster", "healer", "support"} for role in roles
        ):
            raise ValueError(f"{label}.roles has invalid roles")
        if len(roles) != len(set(roles)):
            raise ValueError(f"{label}.roles has duplicates")
    if actor["effects"] is not None:
        effects = actor["effects"]
        if not isinstance(effects, list) or len(effects) > 256 or any(
            not isinstance(effect, str) or not effect for effect in effects
        ):
            raise ValueError(f"{label}.effects must be a list of status names")
        if len(effects) != len(set(effects)):
            raise ValueError(f"{label}.effects has duplicates")


def validate_snapshot(snapshot: Mapping[str, Any]) -> None:
    if not isinstance(snapshot, dict) or set(snapshot) != _REQUIRED_SNAPSHOT:
        raise ValueError("snapshot keys must exactly match reference schema v0")
    _int(snapshot["now_ms"], "now_ms")
    _int(snapshot["max_age_ms"], "max_age_ms", 1)
    _text(snapshot["zone"], "zone")
    _tristate(snapshot["active"], "active")
    _tristate(snapshot["party_complete"], "party_complete")
    _text(snapshot["self_id"], "self_id")
    _text(snapshot["owner_id"], "owner_id")
    actors = snapshot["party"]
    if not isinstance(actors, list) or len(actors) > 6:
        raise ValueError("party must be 0–6 synthetic actors")
    for actor in actors:
        _validate_actor(actor, "party actor")
    ids = [actor["id"] for actor in actors]
    if len(ids) != len(set(ids)):
        raise ValueError("duplicate party actor id")
    if snapshot["enemy"] is not None:
        enemy = snapshot["enemy"]
        _validate_actor(enemy, "enemy", enemy=True)
        if enemy["id"] in ids:
            raise ValueError("enemy and party actor identity collision")
        if set(enemy) != {
            "id", "zone", "observed_ms", "alive", "roles",
            "hp_pct", "mp_pct", "effects", "casting"
        }:
            raise ValueError("enemy needs casting field")
        _tristate(enemy["casting"], "enemy.casting")
    ready = snapshot["ready_actions"]
    if not isinstance(ready, dict) or not set(ready).issubset(_ALLOWED_ACTIONS):
        raise ValueError("readiness may name only allowlisted symbolic actions")
    for name, val in ready.items():
        _tristate(val, f"ready_actions.{name}")


def _fresh(actor: Mapping[str, Any], facts: Mapping[str, Any]) -> Truth:
    if actor["zone"] != facts["zone"]:
        return Truth.FALSE
    age = facts["now_ms"] - actor["observed_ms"]
    return Truth.TRUE if 0 <= age <= facts["max_age_ms"] else Truth.UNKNOWN


def _target_candidates(
    selector: str, facts: Mapping[str, Any]
) -> tuple[Truth, list[Mapping[str, Any]]]:
    party = facts["party"]
    if selector in _PARTY_TARGETS and facts["party_complete"] is not True:
        return Truth.UNKNOWN, []
    if selector == "enemy":
        return (Truth.UNKNOWN, []) if facts["enemy"] is None else (
            Truth.TRUE, [facts["enemy"]]
        )
    if selector in {"self", "owner"}:
        key = facts["self_id"] if selector == "self" else facts["owner_id"]
        matches = [a for a in party if a["id"] == key]
        return (Truth.TRUE, matches) if matches else (Truth.UNKNOWN, [])
    if selector == "lowest_hp_party":
        if not party or any(a["hp_pct"] is None for a in party):
            return Truth.UNKNOWN, []
        # A stale roster member might actually have become lowest HP.
        if any(_fresh(a, facts) is Truth.UNKNOWN for a in party):
            return Truth.UNKNOWN, []
        same_zone = [a for a in party if _fresh(a, facts) is Truth.TRUE]
        if not same_zone:
            return Truth.FALSE, []
        return Truth.TRUE, [min(same_zone, key=lambda a: (a["hp_pct"], a["id"]))]
    if selector in {"tank", "melee", "caster"}:
        if any(a["roles"] is None or _fresh(a, facts) is Truth.UNKNOWN for a in party):
            return Truth.UNKNOWN, []
        matches = sorted(
            (a for a in party if a["roles"] and selector in a["roles"]
             and _fresh(a, facts) is Truth.TRUE), key=lambda a: a["id"]
        )
        return Truth.TRUE, matches
    raise ValueError("unknown target selector")


def _predicate(
    op: str, target: Mapping[str, Any], facts: Mapping[str, Any],
    value: Any = None,
) -> Truth:
    if op == "enemy_casting":
        enemy = facts["enemy"]
        if enemy is None or _fresh(enemy, facts) is not Truth.TRUE:
            return Truth.UNKNOWN
        val = enemy["casting"]
        return Truth.UNKNOWN if val is None else (Truth.TRUE if val else Truth.FALSE)
    if op == "target_alive":
        val = target["alive"]
        return Truth.UNKNOWN if val is None else (Truth.TRUE if val else Truth.FALSE)
    if op in {"hp_at_most", "mp_at_most"}:
        field = "hp_pct" if op == "hp_at_most" else "mp_pct"
        val = target[field]
        return Truth.UNKNOWN if val is None else (
            Truth.TRUE if val <= value else Truth.FALSE
        )
    if op in {"status_present", "status_absent"}:
        effects = target["effects"]
        if effects is None:
            return Truth.UNKNOWN  # unavailable is NOT an observed empty set
        present = value in effects
        good = present if op == "status_present" else not present
        return Truth.TRUE if good else Truth.FALSE
    raise ValueError("unknown predicate")


def evaluate(profile: Mapping[str, Any], snapshot: Mapping[str, Any]) -> Decision:
    """Produce at most one *proposal*, never an action or a gameplay verdict.

    A higher-priority UNKNOWN blocks lower-priority fallback, avoiding a buff
    proposal while the emergency-heal requirement cannot be evaluated.
    """
    validate_profile(profile)
    validate_snapshot(snapshot)
    base = {"profile_id": profile["id"], "profile_version": profile["version"]}
    if snapshot["active"] is False:
        return Decision(DecisionStatus.INHIBITED, **base, reason="actor_inactive")
    if snapshot["active"] is None:
        return Decision(DecisionStatus.BLOCKED_UNKNOWN, **base, reason="actor_activity_unknown")

    for rule in sorted(profile["rules"], key=lambda r: (r["priority"], r["id"])):
        selection, targets = _target_candidates(rule["target"], snapshot)
        if selection is Truth.UNKNOWN:
            return Decision(DecisionStatus.BLOCKED_UNKNOWN, **base,
                            rule_id=rule["id"], reason="target_selection_unknown")
        if selection is Truth.FALSE or not targets:
            continue

        for actor in targets:
            fresh = _fresh(actor, snapshot)
            if fresh is Truth.FALSE:
                continue
            if fresh is Truth.UNKNOWN:
                return Decision(DecisionStatus.BLOCKED_UNKNOWN, **base,
                                rule_id=rule["id"], reason="target_freshness_unknown")
            if actor["alive"] is None:
                return Decision(DecisionStatus.BLOCKED_UNKNOWN, **base,
                                rule_id=rule["id"], reason="target_life_unknown")
            if actor["alive"] is False:
                continue

            results = [
                _predicate(c["op"], actor, snapshot, c.get("value"))
                for c in rule["conditions"]
            ]
            if Truth.FALSE in results:
                continue
            if Truth.UNKNOWN in results:
                return Decision(DecisionStatus.BLOCKED_UNKNOWN, **base,
                                rule_id=rule["id"], reason="predicate_unknown")
            ready = snapshot["ready_actions"].get(rule["action"])
            if ready is None:
                return Decision(DecisionStatus.BLOCKED_UNKNOWN, **base,
                                rule_id=rule["id"], reason="action_readiness_unknown")
            if ready is False:
                continue

            return Decision(DecisionStatus.PROPOSED, **base, rule_id=rule["id"],
                            action=rule["action"], target_id=actor["id"],
                            reason="symbolic_only_not_executable")

    return Decision(DecisionStatus.NO_MATCH, **base, reason="no_eligible_rule")


def load_profiles(data: Mapping[str, Any]) -> dict[str, Mapping[str, Any]]:
    """Use with json.load; no imports from values and no dynamic expression eval."""
    if not isinstance(data, dict) or set(data) != {"schema_version", "profiles"}:
        raise ValueError("invalid profile bundle keys")
    if data["schema_version"] != "trust-policy-reference-v0":
        raise ValueError("unsupported profile schema version")
    profiles = data["profiles"]
    if not isinstance(profiles, list) or not 1 <= len(profiles) <= 32:
        raise ValueError("profile bundle must contain 1–32 profiles")
    result: dict[str, Mapping[str, Any]] = {}
    for p in profiles:
        validate_profile(p)
        if p["id"] in result:
            raise ValueError("duplicate profile id")
        result[p["id"]] = p
    return result
