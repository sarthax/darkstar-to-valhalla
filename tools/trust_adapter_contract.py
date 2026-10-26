"""Offline synthetic source-to-policy-v0 projection for Trust adapter research.

This module does NOT integrate with DSP, Valhalla, LSB, XiHeadless, or action
execution. Non-synthetic callers are blocked even when they claim full evidence.
"""
from __future__ import annotations

from copy import deepcopy
from dataclasses import dataclass
from typing import Any, Mapping


VERSION = "trust-adapter-source-v0"
POLICY_KEYS = frozenset({
    "now_ms", "max_age_ms", "zone", "active", "party_complete",
    "self_id", "owner_id", "party", "enemy", "ready_actions",
})
SOURCE_KEYS = POLICY_KEYS | frozenset({
    "schema_version", "source_kind", "source_revision",
    "trust_ids", "ordinary_pet_id",
})
ACTOR_KEYS = frozenset({
    "id", "zone", "observed_ms", "alive", "roles",
    "hp_pct", "mp_pct", "effects",
})
ACTIONS = frozenset({
    "cure", "regen", "provoke", "flash", "sentinel", "haste", "refresh",
})
ROLES = frozenset({"tank", "melee", "caster", "healer", "support"})
SOURCE_KINDS = frozenset({
    "synthetic_fixture", "personal_dsp", "private_valhalla",
})


@dataclass(frozen=True)
class Projection:
    """A non-executing projection, or an explicitly blocked source contract."""
    status: str
    source_kind: str
    source_revision: str
    reason: str
    policy_snapshot: dict[str, Any] | None = None


def _name(value: Any, field: str) -> str:
    if not isinstance(value, str) or not value or len(value) > 128:
        raise ValueError(f"{field}: nonempty bounded identifier required")
    return value


def _number(value: Any, field: str, minimum: int = 0) -> int:
    if type(value) is not int or value < minimum:
        raise ValueError(f"{field}: integer >= {minimum} required")
    return value


def _truth(value: Any, field: str) -> None:
    if value is not None and type(value) is not bool:
        raise ValueError(f"{field}: bool or null required")


def _pct(value: Any, field: str) -> None:
    if value is not None and (type(value) not in (int, float)
                              or not 0 <= value <= 100):
        raise ValueError(f"{field}: null or 0..100 required")


def _actor(value: Any, field: str, now_ms: int, *, enemy: bool = False) -> None:
    keys = ACTOR_KEYS | ({"casting"} if enemy else set())
    if not isinstance(value, dict) or set(value) != keys:
        raise ValueError(f"{field}: actor fields invalid")
    _name(value["id"], f"{field}.id")
    _name(value["zone"], f"{field}.zone")
    observed = _number(value["observed_ms"], f"{field}.observed_ms")
    if observed > now_ms:
        raise ValueError(f"{field}: future observation")
    _truth(value["alive"], f"{field}.alive")
    _pct(value["hp_pct"], f"{field}.hp_pct")
    _pct(value["mp_pct"], f"{field}.mp_pct")
    roles = value["roles"]
    if roles is not None:
        if (not isinstance(roles, list) or len(roles) > 8
                or any(r not in ROLES for r in roles)
                or len(roles) != len(set(roles))):
            raise ValueError(f"{field}.roles: invalid or duplicate")
    effects = value["effects"]
    if effects is not None:
        if (not isinstance(effects, list) or len(effects) > 256
                or any(not isinstance(e, str) or not e for e in effects)
                or len(effects) != len(set(effects))):
            raise ValueError(f"{field}.effects: invalid or duplicate")
    if enemy:
        _truth(value["casting"], f"{field}.casting")


def validate_source(source: Mapping[str, Any]) -> None:
    if not isinstance(source, dict) or set(source) != SOURCE_KEYS:
        raise ValueError("unknown or missing source contract fields")
    if source["schema_version"] != VERSION:
        raise ValueError("unsupported source contract version")
    if source["source_kind"] not in SOURCE_KINDS:
        raise ValueError("source_kind unsupported")
    _name(source["source_revision"], "source_revision")
    now = _number(source["now_ms"], "now_ms")
    _number(source["max_age_ms"], "max_age_ms", 1)
    _name(source["zone"], "zone")
    _name(source["owner_id"], "owner_id")
    _name(source["self_id"], "self_id")
    _truth(source["active"], "active")
    _truth(source["party_complete"], "party_complete")
    if not isinstance(source["party"], list) or len(source["party"]) > 6:
        raise ValueError("party requires 0–6 members, independent of normal pet")
    for i, a in enumerate(source["party"]):
        _actor(a, f"party[{i}]", now)
    party_ids = [a["id"] for a in source["party"]]
    if len(party_ids) != len(set(party_ids)):
        raise ValueError("duplicate party actor identities")
    if source["owner_id"] not in party_ids:
        raise ValueError("trust owner missing from party")
    trusts = source["trust_ids"]
    if (not isinstance(trusts, list) or len(trusts) > 5
            or any(not isinstance(t, str) or not t for t in trusts)
            or len(trusts) != len(set(trusts))):
        raise ValueError("trust list must have <= 5 unique named actors")
    if source["self_id"] not in trusts:
        raise ValueError("self must name one of the trust actors")
    if source["owner_id"] in trusts or not set(trusts).issubset(party_ids):
        raise ValueError("trust identity does not match distinct party Trust")
    pet = source["ordinary_pet_id"]
    if pet is not None:
        _name(pet, "ordinary_pet_id")
        if pet in party_ids or pet in trusts or pet == source["owner_id"]:
            raise ValueError("ordinary pet must not consume Trust/party identity")
    if source["enemy"] is not None:
        _actor(source["enemy"], "enemy", now, enemy=True)
        if source["enemy"]["id"] in party_ids or source["enemy"]["id"] == pet:
            raise ValueError("enemy identity collides with ally or pet")
    readiness = source["ready_actions"]
    if not isinstance(readiness, dict) or not set(readiness).issubset(ACTIONS):
        raise ValueError("only named symbolic readiness facts permitted")
    for key, v in readiness.items():
        _truth(v, f"ready_actions.{key}")


def project(source: Mapping[str, Any]) -> Projection:
    """Project synthetic evidence only; NON-SYNTHETIC is NEVER authorized.

    Projected facts are independent deep copies. True/false/unknown claims here
    come from a synthetic fixture, not server-validated evidence.
    """
    validate_source(source)
    kind, revision = source["source_kind"], source["source_revision"]
    if kind != "synthetic_fixture":
        return Projection(
            status="BLOCKED", source_kind=kind, source_revision=revision,
            reason="live_actor_and_evidence_adapter_not_implemented",
        )

    # Keep ONLY fields that the draft policy-v0 schema already recognizes.
    projected = deepcopy({k: source[k] for k in POLICY_KEYS})
    now, age, zone = source["now_ms"], source["max_age_ms"], source["zone"]
    for actor in projected["party"] + ([projected["enemy"]] if projected["enemy"] else []):
        if actor["zone"] != zone or now - actor["observed_ms"] > age:
            # If one member is stale or out of zone, we CANNOT assert a
            # complete roster for lowest-HP or recipient role selection.
            if actor is not projected["enemy"]:
                projected["party_complete"] = None
            actor["alive"] = None
            actor["hp_pct"] = None
            actor["mp_pct"] = None
            actor["effects"] = None
            actor["roles"] = None
            if actor is projected["enemy"]:
                actor["casting"] = None

    return Projection(
        status="SYNTHETIC_ONLY", source_kind=kind,
        source_revision=revision, reason="no_gameplay_authority",
        policy_snapshot=projected,
    )
