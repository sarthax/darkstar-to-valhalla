"""Offline contract tests for symbolic Trust gambit reference. No DSP needed."""
import copy
import json
import unittest
from pathlib import Path

from trust_policy_reference import (
    DecisionStatus, evaluate, load_profiles, validate_profile, validate_snapshot,
)

FIXTURES = (Path(__file__).resolve().parent.parent /
    "docs/slices/trust-modernization/trust_personality_examples_v0.json")
PROFILES = load_profiles(json.loads(FIXTURES.read_text(encoding="utf-8")))


def actor(identifier, roles, hp=100, mp=80, effects=None, zone="fixture-zone",
          observed=990, alive=True):
    return {
        "id": identifier, "zone": zone, "observed_ms": observed, "alive": alive,
        "roles": roles, "hp_pct": hp, "mp_pct": mp, "effects": effects,
    }


def facts():
    return {
        "now_ms": 1000, "max_age_ms": 250, "zone": "fixture-zone",
        "active": True, "party_complete": True, "self_id": "self",
        "owner_id": "owner",
        "party": [
            actor("self", ["healer"], hp=100, effects=["regen"]),
            actor("owner", ["melee"], hp=92, effects=["regen"]),
            actor("tank", ["tank"], hp=96, effects=["sentinel"]),
            actor("caster", ["caster"], hp=94, effects=["refresh"]),
        ],
        "enemy": {**actor("enemy", [], hp=100, effects=[]), "casting": False},
        "ready_actions": {
            "cure": True, "regen": True, "flash": True, "sentinel": True,
            "provoke": True, "haste": True, "refresh": True,
        },
    }


def run(profile, snapshot=None):
    return evaluate(PROFILES[profile], facts() if snapshot is None else snapshot)


class TrustReferencePolicyTests(unittest.TestCase):
    def test_valid_profiles_and_no_executable_methods(self):
        self.assertEqual(len(PROFILES), 3)
        for profile in PROFILES.values():
            validate_profile(profile)
            self.assertEqual(profile["version"], 1)
        # A Decision contains data only; no callable runtime action method.
        from trust_policy_reference import Decision
        for name in ("execute", "dispatch", "send", "start_bot"):
            self.assertFalse(hasattr(Decision, name))

    def test_emergency_healer_prefers_lowest_hp_over_regen(self):
        f = facts()
        f["party"][1]["hp_pct"] = 14
        f["party"][3]["hp_pct"] = 20
        d = run("healer_triage_v0", f)
        self.assertEqual((d.status, d.action, d.target_id, d.rule_id),
                         (DecisionStatus.PROPOSED, "cure", "owner", "emergency_cure"))

    def test_routine_healer_chooses_evidence_based_threshold(self):
        f = facts()
        f["party"][2]["hp_pct"] = 70
        d = run("healer_triage_v0", f)
        self.assertEqual((d.action, d.rule_id, d.target_id),
                         ("cure", "regular_cure", "tank"))

    def test_no_cure_when_everybody_healthy_owner_regen_missing(self):
        f = facts()
        f["party"][1]["effects"] = []
        d = run("healer_triage_v0", f)
        self.assertEqual((d.action, d.rule_id, d.target_id),
                         ("regen", "owner_regen", "owner"))

    def test_all_healthy_regen_present_no_match(self):
        d = run("healer_triage_v0")
        self.assertEqual(d.status, DecisionStatus.NO_MATCH)
        self.assertIsNone(d.action)

    def test_unknown_hp_blocks_fallback_to_nonurgent_buff(self):
        f = facts()
        f["party"][2]["hp_pct"] = None
        f["party"][1]["effects"] = []
        d = run("healer_triage_v0", f)
        self.assertEqual(d.status, DecisionStatus.BLOCKED_UNKNOWN)
        self.assertEqual(d.rule_id, "emergency_cure")
        self.assertIsNone(d.action)

    def test_stale_party_member_blocks_lowest_hp_ranking(self):
        f = facts()
        f["party"][2]["observed_ms"] = 100
        d = run("healer_triage_v0", f)
        self.assertEqual(d.status, DecisionStatus.BLOCKED_UNKNOWN)
        self.assertEqual(d.reason, "target_selection_unknown")

    def test_unknown_roster_blocks_party_rule_not_treated_as_no_party(self):
        f = facts()
        f["party_complete"] = None
        d = run("support_upkeep_v0", f)
        self.assertEqual(d.status, DecisionStatus.BLOCKED_UNKNOWN)
        self.assertIsNone(d.target_id)

    def test_out_of_zone_member_is_not_targeted(self):
        f = facts()
        f["party"][1]["zone"] = "other-zone"
        f["party"][1]["hp_pct"] = 1
        f["party"][2]["hp_pct"] = 18
        d = run("healer_triage_v0", f)
        self.assertEqual(d.status, DecisionStatus.PROPOSED)
        self.assertEqual(d.target_id, "tank")

    def test_disallowed_actions_and_executable_rule_fields_rejected(self):
        f = copy.deepcopy(PROFILES["healer_triage_v0"])
        f["rules"][0]["action"] = "cast_anything()"
        with self.assertRaises(ValueError):
            validate_profile(f)
        f = copy.deepcopy(PROFILES["healer_triage_v0"])
        f["rules"][0]["exec"] = "os.system('x')"
        with self.assertRaises(ValueError):
            validate_profile(f)

    def test_duplicate_priorities_and_rule_ids_rejected(self):
        for field in ("priority", "id"):
            p = copy.deepcopy(PROFILES["healer_triage_v0"])
            p["rules"][1][field] = p["rules"][0][field]
            with self.subTest(field=field), self.assertRaises(ValueError):
                validate_profile(p)

    def test_invalid_thresholds_and_unknown_predicates_rejected(self):
        for value in (-1, 101, None, "25"):
            p = copy.deepcopy(PROFILES["healer_triage_v0"])
            p["rules"][0]["conditions"][0]["value"] = value
            with self.subTest(value=value), self.assertRaises(ValueError):
                validate_profile(p)
        p = copy.deepcopy(PROFILES["healer_triage_v0"])
        p["rules"][0]["conditions"][0]["op"] = "eval"
        with self.assertRaises(ValueError):
            validate_profile(p)

    def test_tank_reacts_to_observed_cast_before_provoke(self):
        f = facts()
        f["enemy"]["casting"] = True
        d = run("defensive_tank_v0", f)
        self.assertEqual((d.status, d.action, d.rule_id, d.target_id),
                         (DecisionStatus.PROPOSED, "flash", "interrupt_spell", "enemy"))

    def test_tank_falls_back_to_defense_when_flash_unavailable(self):
        f = facts()
        f["enemy"]["casting"] = True
        f["ready_actions"]["flash"] = False
        f["party"][0]["effects"] = []
        d = run("defensive_tank_v0", f)
        self.assertEqual((d.action, d.rule_id), ("sentinel", "defensive_stance"))

    def test_tank_provoke_when_enemy_not_casting(self):
        d = run("defensive_tank_v0")
        self.assertEqual((d.action, d.rule_id), ("provoke", "establish_enmity"))

    def test_enemy_casting_unknown_blocks_unsafe_provoke_fallback(self):
        f = facts()
        f["enemy"]["casting"] = None
        d = run("defensive_tank_v0", f)
        self.assertEqual(d.status, DecisionStatus.BLOCKED_UNKNOWN)
        self.assertEqual(d.rule_id, "interrupt_spell")

    def test_enemy_stale_or_missing_causes_unknown_not_safe_target(self):
        f = facts()
        f["enemy"]["observed_ms"] = 700
        self.assertEqual(run("defensive_tank_v0", f).status,
                         DecisionStatus.BLOCKED_UNKNOWN)
        f["enemy"] = None
        self.assertEqual(run("defensive_tank_v0", f).status,
                         DecisionStatus.BLOCKED_UNKNOWN)

    def test_support_maintains_haste_on_unbuffed_melee(self):
        d = run("support_upkeep_v0")
        self.assertEqual((d.action, d.target_id, d.rule_id),
                         ("haste", "owner", "haste_frontline"))

    def test_support_refreshes_caster_when_haste_already_present(self):
        f = facts()
        f["party"][1]["effects"] = ["haste"]
        f["party"][3]["effects"] = []
        d = run("support_upkeep_v0", f)
        self.assertEqual((d.action, d.target_id), ("refresh", "caster"))

    def test_support_triages_emergency_before_haste(self):
        f = facts()
        f["party"][3]["hp_pct"] = 20
        d = run("support_upkeep_v0", f)
        self.assertEqual((d.action, d.target_id), ("cure", "caster"))

    def test_unknown_buff_snapshot_never_means_buff_absent(self):
        f = facts()
        f["party"][1]["effects"] = None
        d = run("support_upkeep_v0", f)
        self.assertEqual((d.status, d.rule_id),
                         (DecisionStatus.BLOCKED_UNKNOWN, "haste_frontline"))

    def test_readiness_unknown_blocks_lower_priority_fallback(self):
        f = facts()
        f["ready_actions"]["haste"] = None
        d = run("support_upkeep_v0", f)
        self.assertEqual((d.status, d.reason),
                         (DecisionStatus.BLOCKED_UNKNOWN, "action_readiness_unknown"))

    def test_cancellation_and_unknown_actor_activity(self):
        f = facts()
        f["active"] = False
        self.assertEqual(run("support_upkeep_v0", f).status,
                         DecisionStatus.INHIBITED)
        f["active"] = None
        self.assertEqual(run("support_upkeep_v0", f).status,
                         DecisionStatus.BLOCKED_UNKNOWN)

    def test_unknown_ally_role_blocks_role_target_selectors(self):
        f = facts()
        f["party"][2]["roles"] = None
        d = run("support_upkeep_v0", f)
        self.assertEqual((d.status, d.rule_id),
                         (DecisionStatus.BLOCKED_UNKNOWN, "haste_frontline"))

    def test_deterministic_tie_break_on_hp_and_role(self):
        f = facts()
        f["party"][1]["hp_pct"] = 20
        f["party"][3]["hp_pct"] = 20
        self.assertEqual(run("healer_triage_v0", f).target_id, "caster")
        g = facts()
        g["party"].append(actor("another-melee", ["melee"], effects=[]))
        self.assertEqual(run("support_upkeep_v0", g).target_id, "another-melee")

    def test_readiness_false_skips_rule_and_all_unknown_false_distinct(self):
        f = facts()
        f["ready_actions"]["haste"] = False
        f["party"][3]["effects"] = []
        d = run("support_upkeep_v0", f)
        self.assertEqual((d.action, d.target_id), ("refresh", "caster"))

    def test_malformed_actor_ids_effects_and_timestamps_fail_closed(self):
        sample = facts()
        for mutation in (
            lambda s: s["party"].append(copy.deepcopy(s["party"][0])),
            lambda s: s["party"][0].update({"effects": "missing"}),
            lambda s: s["party"][0].update({"hp_pct": 150}),
            lambda s: s.update({"now_ms": -1}),
            lambda s: s["enemy"].update({"casting": "maybe"}),
            lambda s: s["ready_actions"].update({"arbitrary_code": True}),
            lambda s: s["party"][0].update({"roles": ["melee", "melee"]}),
        ):
            f = copy.deepcopy(sample)
            mutation(f)
            with self.subTest(snapshot=f), self.assertRaises(ValueError):
                validate_snapshot(f)

    def test_no_mutation_and_repeatable_decisions(self):
        original = facts()
        frozen = copy.deepcopy(original)
        d1 = run("support_upkeep_v0", original)
        d2 = run("support_upkeep_v0", original)
        self.assertEqual(d1, d2)
        self.assertEqual(original, frozen)
        self.assertEqual(d1.reason, "symbolic_only_not_executable")

    def test_profile_bundle_rejects_schema_drifts(self):
        raw = json.loads(FIXTURES.read_text(encoding="utf-8"))
        raw["schema_version"] = "unverified-next"
        with self.assertRaises(ValueError):
            load_profiles(raw)
        raw = json.loads(FIXTURES.read_text(encoding="utf-8"))
        raw["profiles"].append(copy.deepcopy(raw["profiles"][0]))
        with self.assertRaises(ValueError):
            load_profiles(raw)


if __name__ == "__main__":
    unittest.main()
