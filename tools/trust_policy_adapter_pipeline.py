"""GitHub-only, non-executing Trust source→policy reference pipeline.

Both input and any PROPOSED output are simulated data, never permission to
control a live entity. No network, file I/O, game commands or background loop.
"""
from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from typing import Any, Mapping

from trust_adapter_contract import project
from trust_policy_reference import DecisionStatus, evaluate, load_profiles


@dataclass(frozen=True)
class Replay:
    """An auditable *simulation*, never a gameplay execution receipt."""
    status: str
    source_kind: str
    source_revision: str
    profile_id: str
    profile_version: int | None
    reason: str
    source_digest: str
    rule_id: str | None = None
    proposed_action: str | None = None
    proposed_target: str | None = None
    dispatch_performed: bool = False
    effect_observed: bool = False
    gameplay_verdict: str = "NOT_TESTED"


def _digest(input_data: Mapping[str, Any], bundle: Mapping[str, Any]) -> str:
    # A stable *debugging fingerprint* of caller-supplied data, NOT
    # authentication, source attestation or evidence of real gameplay.
    encoded = json.dumps(
        {"synthetic_source": input_data, "profiles": bundle},
        sort_keys=True, separators=(",", ":"), allow_nan=False,
    ).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def replay(source: Mapping[str, Any], bundle: Mapping[str, Any],
           profile_id: str) -> Replay:
    """Combine two independently reviewed reference modules without actions.

    A caller-controlled fixture is valid ONLY as an offline simulation.
    No result of this function authorizes external action dispatch.
    """
    if not isinstance(profile_id, str) or not profile_id or len(profile_id) > 128:
        raise ValueError("profile_id must be a bounded identifier")
    profiles = load_profiles(bundle)
    if profile_id not in profiles:
        raise ValueError("unknown personality profile")
    profile = profiles[profile_id]
    projection = project(source)
    digest = _digest(source, bundle)
    meta = dict(
        source_kind=projection.source_kind,
        source_revision=projection.source_revision,
        profile_id=profile_id, profile_version=profile["version"],
        source_digest=digest,
    )
    if projection.status != "SYNTHETIC_ONLY":
        return Replay(
            status="SOURCE_BLOCKED", reason=projection.reason, **meta,
        )

    # Evaluation returns proposed data; it does NOT call an execution API.
    choice = evaluate(profile, projection.policy_snapshot)
    status = {
        DecisionStatus.PROPOSED: "SYNTHETIC_PROPOSAL",
        DecisionStatus.BLOCKED_UNKNOWN: "BLOCKED_UNKNOWN",
        DecisionStatus.INHIBITED: "INHIBITED",
        DecisionStatus.NO_MATCH: "NO_MATCH",
    }[choice.status]
    return Replay(
        status=status,
        reason=choice.reason,
        rule_id=choice.rule_id,
        proposed_action=choice.action if choice.status is DecisionStatus.PROPOSED else None,
        proposed_target=choice.target_id if choice.status is DecisionStatus.PROPOSED else None,
        **meta,
    )
