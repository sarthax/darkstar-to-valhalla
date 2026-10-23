"""Focused GitHub Actions synthetic adapter→policy integration tests."""
from __future__ import annotations

import copy
import json
import unittest
from dataclasses import asdict
from pathlib import Path

from trust_policy_adapter_pipeline import Replay, replay

FIXTURE_PATH = (Path(__file__).resolve().parent.parent
                / "docs/slices/trust-modernization/trust_personality_examples_v0.json")
BUNDLE = json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))


def actor(name, roles, hp=100, effects=None, observed_ms=990,
          zone="synthetic-zone", alive=True):
    return {
        "id": name, "zone": zone, "observed_ms": observed_ms, "alive": alive,
        "roles": roles, "hp_pct": hp, "mp_pct": 90,
        "effects": [] if effects is None else effects,
    }


def source():
    return {
        "schema_version": "trust-adapter-source-v0",
        "source_kind": "synthetic_fixture",
        "source_revision": "no-server-synthetic-v1",
        "now_ms": 1000, "max_age_ms": 200, "zone": "synthetic-zone",
        "active": True, "party_complete": True,
        "owner_id": "owner", "self_id": "actor",
        "trust_ids": ["actor", "buffer", "caster"],
        "ordinary_pet_id": "pet-outside-party",
        "party": [
            actor("owner", ["melee"], effects=["regen"]),
            actor("actor", ["tank", "healer"], effects=["regen"]),
            actor("buffer", ["support"], effects=[]),
            actor("caster", ["caster"], effects=["refresh"]),
        ],
        "enemy": {**actor("enemy", [], effects=[]), "casting": False},
        "ready_actions": {
            "cure": True, "regen": True, "provoke": True,
            "flash": True, "sentinel": True,
            "haste": True, "refresh": True,
        },
    }


class TrustPipelineTests(unittest.TestCase):
    def check_never_executed(self, d):
        self.assertIsInstance(d, Replay)
        self.assertFalse(d.dispatch_performed)
        self.assertFalse(d.effect_observed)
        self.assertEqual(d.gameplay_verdict, "NOT_TESTED")
        self.assertEqual(len(d.source_digest), 64)
        self.assertEqual(d.source_revision, "no-server-synthetic-v1")

    def test_emergency_healer_e2e(self):
        s = source()
        s["party"][0]["hp_pct"] = 18
        d = replay(s, BUNDLE, "healer_triage_v0")
        self.assertEqual((d.status, d.proposed_action, d.proposed_target,
                          d.rule_id),
                         ("SYNTHETIC_PROPOSAL", "cure", "owner", "emergency_cure"))
        self.check_never_executed(d)

    def test_regular_healer_e2e(self):
        s = source()
        s["party"][0]["hp_pct"] = 65
        d = replay(s, BUNDLE, "healer_triage_v0")
        self.assertEqual((d.proposed_action, d.rule_id),
                         ("cure", "regular_cure"))
        self.check_never_executed(d)

    def test_healer_no_match_if_all_cure_and_regen_requirements_met(self):
        d = replay(source(), BUNDLE, "healer_triage_v0")
        self.assertEqual(d.status, "NO_MATCH")
        self.assertIsNone(d.proposed_action)
        self.check_never_executed(d)

    def test_healer_proposes_regen_for_owner_if_absent(self):
        s = source()
        s["party"][0]["effects"] = []
        d = replay(s, BUNDLE, "healer_triage_v0")
        self.assertEqual((d.proposed_action, d.proposed_target),
                         ("regen", "owner"))
        self.check_never_executed(d)

    def test_tank_reactive_flash_when_enemy_carries_observed_cast(self):
        s = source()
        s["enemy"]["casting"] = True
        d = replay(s, BUNDLE, "defensive_tank_v0")
        self.assertEqual((d.status, d.proposed_action, d.rule_id),
                         ("SYNTHETIC_PROPOSAL", "flash", "interrupt_spell"))
        self.check_never_executed(d)

    def test_tank_uses_defense_when_flash_not_ready(self):
        s = source()
        s["enemy"]["casting"] = True
        s["ready_actions"]["flash"] = False
        s["party"][1]["effects"] = []
        d = replay(s, BUNDLE, "defensive_tank_v0")
        self.assertEqual((d.proposed_action, d.proposed_target),
                         ("sentinel", "actor"))
        self.check_never_executed(d)

    def test_tank_falls_back_to_provoke_on_noncasting_enemy(self):
        d = replay(source(), BUNDLE, "defensive_tank_v0")
        self.assertEqual(d.proposed_action, "provoke")
        self.check_never_executed(d)

    def test_support_haste_priority(self):
        d = replay(source(), BUNDLE, "support_upkeep_v0")
        self.assertEqual((d.proposed_action, d.proposed_target),
                         ("haste", "owner"))
        self.check_never_executed(d)

    def test_support_refresh_role_target_after_haste_exists(self):
        s = source()
        s["party"][0]["effects"].append("haste")
        s["party"][3]["effects"] = []
        d = replay(s, BUNDLE, "support_upkeep_v0")
        self.assertEqual((d.proposed_action, d.proposed_target),
                         ("refresh", "caster"))
        self.check_never_executed(d)

    def test_support_cure_over_buff_on_emergency(self):
        s = source()
        s["party"][3]["hp_pct"] = 20
        d = replay(s, BUNDLE, "support_upkeep_v0")
        self.assertEqual((d.proposed_action, d.proposed_target),
                         ("cure", "caster"))
        self.check_never_executed(d)

    def test_explicitly_missing_buff_snapshot_blocks_maintenance(self):
        s = source()
        s["party"][0]["effects"] = None
        d = replay(s, BUNDLE, "support_upkeep_v0")
        self.assertEqual(d.status, "BLOCKED_UNKNOWN")
        self.assertIsNone(d.proposed_action)
        self.check_never_executed(d)

    def test_stale_party_actor_blocks_emergency_ranking(self):
        s = source()
        s["party"][1]["observed_ms"] = 100
        d = replay(s, BUNDLE, "healer_triage_v0")
        self.assertEqual((d.status, d.reason),
                         ("BLOCKED_UNKNOWN", "target_selection_unknown"))
        self.check_never_executed(d)

    def test_cross_zone_party_actor_blocks_role_maintenance(self):
        s = source()
        s["party"][3]["zone"] = "another-zone"
        d = replay(s, BUNDLE, "support_upkeep_v0")
        self.assertEqual(d.status, "BLOCKED_UNKNOWN")
        self.check_never_executed(d)

    def test_stale_enemy_does_not_authorize_interrupt(self):
        s = source()
        s["enemy"]["casting"] = True
        s["enemy"]["observed_ms"] = 10
        d = replay(s, BUNDLE, "defensive_tank_v0")
        self.assertEqual(d.status, "BLOCKED_UNKNOWN")
        self.check_never_executed(d)

    def test_missing_enemy_does_not_authorize_offense(self):
        s = source()
        s["enemy"] = None
        d = replay(s, BUNDLE, "defensive_tank_v0")
        self.assertEqual(d.status, "BLOCKED_UNKNOWN")
        self.check_never_executed(d)

    def test_action_readiness_unknown_blocks(self):
        s = source()
        s["ready_actions"].pop("haste")
        d = replay(s, BUNDLE, "support_upkeep_v0")
        self.assertEqual((d.status, d.reason),
                         ("BLOCKED_UNKNOWN", "action_readiness_unknown"))
        self.check_never_executed(d)

    def test_inactive_and_unknown_activity_never_proposes(self):
        for state, expected in ((False, "INHIBITED"), (None, "BLOCKED_UNKNOWN")):
            s = source()
            s["active"] = state
            d = replay(s, BUNDLE, "support_upkeep_v0")
            with self.subTest(state=state):
                self.assertEqual(d.status, expected)
                self.assertIsNone(d.proposed_action)
                self.check_never_executed(d)

    def test_private_valhalla_is_always_blocked(self):
        s = source()
        s["source_kind"] = "private_valhalla"
        d = replay(s, BUNDLE, "support_upkeep_v0")
        self.assertEqual((d.status, d.reason),
                         ("SOURCE_BLOCKED", "live_actor_and_evidence_adapter_not_implemented"))
        self.assertIsNone(d.proposed_target)
        self.check_never_executed(d)

    def test_personal_dsp_is_always_blocked(self):
        s = source()
        s["source_kind"] = "personal_dsp"
        d = replay(s, BUNDLE, "healer_triage_v0")
        self.assertEqual(d.status, "SOURCE_BLOCKED")
        self.check_never_executed(d)

    def test_normal_pet_not_confused_with_a_trust_or_party_member(self):
        for pet in ("owner", "actor", "caster"):
            s = source()
            s["ordinary_pet_id"] = pet
            with self.subTest(pet=pet), self.assertRaises(ValueError):
                replay(s, BUNDLE, "support_upkeep_v0")

    def test_duplicate_trust_or_missing_owner_rejected(self):
        for mutate in (
            lambda s: s["trust_ids"].append("actor"),
            lambda s: s["party"].pop(0),
            lambda s: s.update({"owner_id": "absent"}),
        ):
            s = source()
            mutate(s)
            with self.assertRaises(ValueError):
                replay(s, BUNDLE, "healer_triage_v0")

    def test_unverified_action_and_profile_rejected(self):
        s = source()
        s["ready_actions"]["execute"] = True
        with self.assertRaises(ValueError):
            replay(s, BUNDLE, "support_upkeep_v0")
        with self.assertRaises(ValueError):
            replay(source(), BUNDLE, "invented-profile")

    def test_input_immutability_and_reproducible_digest(self):
        s = source()
        before = copy.deepcopy(s)
        first = replay(s, BUNDLE, "support_upkeep_v0")
        second = replay(s, BUNDLE, "support_upkeep_v0")
        self.assertEqual(first, second)
        self.assertEqual(s, before)
        self.assertFalse(first.dispatch_performed)
        self.assertFalse(first.effect_observed)

    def test_digest_differs_if_synthetic_evidence_changes(self):
        s = source()
        a = replay(s, BUNDLE, "support_upkeep_v0")
        s["party"][0]["hp_pct"] = 40
        b = replay(s, BUNDLE, "support_upkeep_v0")
        self.assertNotEqual(a.source_digest, b.source_digest)
        self.check_never_executed(b)

    def test_debug_digest_not_authentication_or_verdict(self):
        d = replay(source(), BUNDLE, "support_upkeep_v0")
        r = asdict(d)
        self.assertNotIn("validated_runtime_source", r)
        self.assertNotIn("accepted_by_server", r)
        self.assertEqual(r["gameplay_verdict"], "NOT_TESTED")
        self.assertFalse(r["dispatch_performed"])
        self.assertFalse(r["effect_observed"])

    def test_invalid_boolean_schema_and_future_clock_rejected(self):
        for update in (
            lambda s: s.update({"active": "yes"}),
            lambda s: s.update({"schema_version": "nope"}),
            lambda s: s["enemy"].update({"observed_ms": 1001}),
            lambda s: s.update({"now_ms": -1}),
            lambda s: s.update({"extra_dispatch_command": "ws"}),
        ):
            s = source()
            update(s)
            with self.assertRaises(ValueError):
                replay(s, BUNDLE, "support_upkeep_v0")


if __name__ == "__main__":
    unittest.main()
