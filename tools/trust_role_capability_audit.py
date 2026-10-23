"""Read-only, source-evidence-only Trust role capability catalog.

The catalog describes public DSP symbols and LSB behavioral requirements.
SOURCE_SEAMS_FOUND never means a Trust is ready, legal, or able to act.
No runtime bridge, FFXI IDs, networking, game imports, or action dispatch.
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping


SCHEMA = "trust-role-capability-v0"
DSP_SHA = "19f00e357b78fe17411ede523a1acd01fe865ee8"
LSB_SHA = "ed34371b7477713c9db9b9758f92df597a65e4ab"
REVISIONS = {"personal_dsp": DSP_SHA, "lsb": LSB_SHA}
BOUNDARY = "PERSONAL_DSP_IS_NOT_PRIVATE_VALHALLA"
CAP_STATES = {"symbol_found", "trust_bridge_missing", "not_reviewed"}
DOMAINS = {"observation", "party", "action", "evidence", "job", "combat"}
ROLES = {"healer", "support", "tank", "damage"}
CAP_KEYS = {
    "id", "domain", "status", "dsp_source",
    "adapter_requirement", "runtime_state",
}
BEHAVIOR_KEYS = {
    "id", "role", "name", "lsb_trust_source",
    "required_capabilities", "trust_behavior_gap", "verification_state",
}
ROOT_KEYS = {"schema_version", "source_revisions", "source_boundary",
             "capabilities", "behaviors"}
SOURCE_KEYS = {"path", "symbol"}
_IDENTIFIER = re.compile(r"^[a-z][a-z0-9_]{2,63}$")
_SYMBOL = re.compile(r"^[A-Za-z_][A-Za-z0-9_:]{2,100}$")
_LSB_PATH = re.compile(r"^scripts/actions/spells/trust/[a-z0-9_-]+\.lua$")


@dataclass(frozen=True)
class CapabilityAssessment:
    behavior_id: str
    role: str
    source_classification: str
    source_symbols_found: tuple[str, ...]
    adapter_gaps: tuple[str, ...]
    evidence_unknown: tuple[str, ...]
    runtime_verdict: str = "NOT_TESTED"
    runnable: bool = False
    dispatched: bool = False


def _id(value: Any, name: str) -> str:
    if not isinstance(value, str) or _IDENTIFIER.fullmatch(value) is None:
        raise ValueError(f"{name} must be a bounded lowercase identifier")
    return value


def _sentence(value: Any, name: str) -> str:
    if not isinstance(value, str) or not 8 <= len(value.strip()) <= 400:
        raise ValueError(f"{name} must be descriptive bounded text")
    return value


def validate_catalog(catalog: Mapping[str, Any]) -> None:
    """Fail closed on unknown schema, fabricated runtime status, or broken joins."""
    if not isinstance(catalog, dict) or set(catalog) != ROOT_KEYS:
        raise ValueError("invalid catalog fields")
    if catalog["schema_version"] != SCHEMA:
        raise ValueError("unknown catalog schema version")
    if catalog["source_revisions"] != REVISIONS:
        raise ValueError("source revisions must match inspected public snapshots")
    if catalog["source_boundary"] != BOUNDARY:
        raise ValueError("personal DSP must not be labeled deployed Valhalla")

    caps, behaviors = catalog["capabilities"], catalog["behaviors"]
    if not isinstance(caps, list) or not 1 <= len(caps) <= 128:
        raise ValueError("capability list invalid")
    if not isinstance(behaviors, list) or not 1 <= len(behaviors) <= 128:
        raise ValueError("behavior list invalid")
    by_id: dict[str, Mapping[str, Any]] = {}
    for c in caps:
        if not isinstance(c, dict) or set(c) != CAP_KEYS:
            raise ValueError("capability has unknown/missing keys")
        cap_id = _id(c["id"], "capability.id")
        if cap_id in by_id:
            raise ValueError("duplicate capability ID")
        by_id[cap_id] = c
        if c["domain"] not in DOMAINS or c["status"] not in CAP_STATES:
            raise ValueError("unknown capability classification")
        if c["runtime_state"] != "NOT_VERIFIED":
            raise ValueError("static evidence cannot claim runtime verification")
        _sentence(c["adapter_requirement"], "adapter_requirement")
        source = c["dsp_source"]
        if c["status"] == "not_reviewed":
            if source is not None:
                raise ValueError("unreviewed source cannot pretend a cited symbol")
            continue
        if not isinstance(source, dict) or set(source) != SOURCE_KEYS:
            raise ValueError("source citation needed for non-unknown capability")
        path, symbol = source["path"], source["symbol"]
        if (not isinstance(path, str) or
                not path.startswith("src/map/") or
                not (path.endswith(".cpp") or path.endswith(".h")) or
                ".." in path or len(path) > 180):
            raise ValueError("untrusted DSP source path")
        if not isinstance(symbol, str) or _SYMBOL.fullmatch(symbol) is None:
            raise ValueError("invalid source symbol")
    seen: set[str] = set()
    for b in behaviors:
        if not isinstance(b, dict) or set(b) != BEHAVIOR_KEYS:
            raise ValueError("behavior has unknown/missing keys")
        ident = _id(b["id"], "behavior.id")
        if ident in seen:
            raise ValueError("duplicate behavior ID")
        seen.add(ident)
        if b["role"] not in ROLES:
            raise ValueError("unsupported role")
        _sentence(b["name"], "behavior.name")
        _sentence(b["trust_behavior_gap"], "trust_behavior_gap")
        if b["verification_state"] != "NOT_TESTED":
            raise ValueError("cannot assert gameplay verification")
        if (not isinstance(b["lsb_trust_source"], str) or
                _LSB_PATH.fullmatch(b["lsb_trust_source"]) is None):
            raise ValueError("LSB Trust file path must be a pinned Lua source")
        required = b["required_capabilities"]
        if (not isinstance(required, list) or
                not 2 <= len(required) <= 32 or
                any(not isinstance(c, str) or c not in by_id for c in required) or
                len(set(required)) != len(required)):
            raise ValueError("invalid, duplicate, or unsourced capability dependency")


def assess_behavior(catalog: Mapping[str, Any], behavior_id: str) -> CapabilityAssessment:
    """Static source-gap report only: never a runtime readiness determination."""
    validate_catalog(catalog)
    _id(behavior_id, "behavior_id")
    behavior = next(
        (b for b in catalog["behaviors"] if b["id"] == behavior_id), None,
    )
    if behavior is None:
        raise ValueError("unknown behavior")
    caps = {c["id"]: c for c in catalog["capabilities"]}
    groups = {key: [] for key in CAP_STATES}
    for cap_id in behavior["required_capabilities"]:
        groups[caps[cap_id]["status"]].append(cap_id)
    classification = (
        "SOURCE_UNKNOWN" if groups["not_reviewed"] else
        "ADAPTER_GAPS" if groups["trust_bridge_missing"] else
        "SOURCE_SEAMS_FOUND"
    )
    return CapabilityAssessment(
        behavior_id=behavior_id, role=behavior["role"],
        source_classification=classification,
        source_symbols_found=tuple(sorted(groups["symbol_found"])),
        adapter_gaps=tuple(sorted(groups["trust_bridge_missing"])),
        evidence_unknown=tuple(sorted(groups["not_reviewed"])),
    )


def assess_all(catalog: Mapping[str, Any]) -> tuple[CapabilityAssessment, ...]:
    validate_catalog(catalog)
    return tuple(assess_behavior(catalog, b["id"])
                 for b in sorted(catalog["behaviors"], key=lambda item: item["id"]))


def load_catalog(path: str | Path) -> dict[str, Any]:
    with Path(path).open(encoding="utf-8") as fh:
        catalog = json.load(fh)
    validate_catalog(catalog)
    return catalog


if __name__ == "__main__":
    from dataclasses import asdict
    source = (Path(__file__).resolve().parent.parent / "docs/slices/trust-modernization"
              / "trust_role_capability_catalog_v0.json")
    report = [asdict(item) for item in assess_all(load_catalog(source))]
    print(json.dumps({"kind": "STATIC_SOURCE_AUDIT_ONLY",
                      "runtime_verdict": "NOT_TESTED", "behaviors": report},
                     sort_keys=True, indent=2))
