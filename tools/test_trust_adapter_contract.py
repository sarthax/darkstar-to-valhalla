"""Standalone fail-closed synthetic Trust source-contract tests."""
import copy
import unittest

from trust_adapter_contract import (
    POLICY_KEYS, Projection, project, validate_source,
)


def actor(name, *, zone="fixture-zone", seen=995, hp=100,
          effects=None, roles=None, alive=True):
    return {
        "id": name, "zone": zone, "observed_ms": seen,
        "alive": alive, "roles": roles if roles is not None else [],
        "hp_pct": hp, "mp_pct": 100, "effects": effects,
    }


def fixture():
    return {
        "schema_version": "trust-adapter-source-v0",
        "source_kind": "synthetic_fixture",
        "source_revision": "fixture-rev-1",
        "now_ms": 1000,
        "max_age_ms": 150,
        "zone": "fixture-zone",
        "owner_id": "owner",
        "self_id": "trust-healer",
        "active": True,
        "party_complete": True,
        "trust_ids": ["trust-healer", "trust-buffer"],
        "ordinary_pet_id": "normal-pet",
        "party": [
            actor("owner", hp=70, effects=["regen"], roles=["melee"]),
            actor("trust-healer", hp=90, effects=[], roles=["healer"]),
            actor("trust-buffer", hp=100, effects=[], roles=["support"]),
        ],
        "enemy": {**actor("enemy", roles=[], effects=[]), "casting": False},
        "ready_actions": {"cure": True, "haste": None, "flash": False},
    }


class TrustAdapterReferenceTests(unittest.TestCase):
    def test_reference_version_and_compatible_policy_keys(self):
        s = fixture()
        r = project(s)
        self.assertEqual(r.status, "SYNTHETIC_ONLY")
        self.assertEqual(r.reason, "no_gameplay_authority")
        self.assertEqual(set(r.policy_snapshot), set(POLICY_KEYS))
        self.assertEqual(r.policy_snapshot["self_id"], "trust-healer")
        self.assertEqual(r.source_revision, "fixture-rev-1")

    def test_rejects_live_private_valhalla_even_if_input_asserts_full_readiness(self):
        s = fixture()
        s["source_kind"] = "private_valhalla"
        r = project(s)
        self.assertEqual(r.status, "BLOCKED")
        self.assertIsNone(r.policy_snapshot)
        self.assertEqual(r.reason, "live_actor_and_evidence_adapter_not_implemented")

    def test_rejects_personal_dsp_source_as_completed_adapter(self):
        s = fixture()
        s["source_kind"] = "personal_dsp"
        self.assertEqual(project(s).status, "BLOCKED")

    def test_rejects_other_sources_instead_of_fabricating_compatibility(self):
        s = fixture()
        s["source_kind"] = "LandSandBoat_runtime"
        with self.assertRaises(ValueError):
            project(s)

    def test_missing_or_extra_fields_rejected(self):
        for mutation in (
            lambda s: s.pop("source_revision"),
            lambda s: s.update({"code": "exec('x')"}),
            lambda s: s.update({"schema_version": "arbitrary-v9"}),
        ):
            s = fixture()
            mutation(s)
            with self.subTest(value=s), self.assertRaises(ValueError):
                project(s)

    def test_cannot_have_more_than_five_trusts(self):
        s = fixture()
        s["trust_ids"] = ["t1", "t2", "t3", "t4", "t5", "t6"]
        with self.assertRaises(ValueError):
            project(s)

    def test_multiple_trusts_need_distinct_owner_and_party_actor_ids(self):
        for update in (
            lambda s: s["trust_ids"].append("trust-healer"),
            lambda s: s["trust_ids"].append("owner"),
            lambda s: s["party"].append(copy.deepcopy(s["party"][1])),
            lambda s: s.update({"self_id": "owner"}),
            lambda s: s.update({"owner_id": "missing-owner"}),
            lambda s: s.update({"trust_ids": ["trust-healer", "absent"]}),
        ):
            s = fixture()
            update(s)
            with self.subTest(value=s), self.assertRaises(ValueError):
                project(s)

    def test_ordinary_pet_is_never_a_trust_party_member(self):
        for pet in ("owner", "trust-healer", "trust-buffer", "enemy"):
            s = fixture()
            s["ordinary_pet_id"] = pet
            with self.subTest(pet=pet), self.assertRaises(ValueError):
                project(s)

    def test_legitimate_ordinary_pet_coexists_outside_party(self):
        s = fixture()
        self.assertEqual(project(s).status, "SYNTHETIC_ONLY")
        s["ordinary_pet_id"] = None
        self.assertEqual(project(s).status, "SYNTHETIC_ONLY")

    def test_six_party_members_max_including_normal_pcs_and_trusts(self):
        s = fixture()
        s["party"] += [
            actor("pc2"), actor("pc3"), actor("pc4"), actor("pc5"),
        ]
        with self.assertRaises(ValueError):
            project(s)

    def test_same_zone_fresh_statuses_not_mutated(self):
        s = fixture()
        r = project(s)
        self.assertIs(r.policy_snapshot["party_complete"], True)
        self.assertEqual(r.policy_snapshot["party"][0]["effects"], ["regen"])
        self.assertEqual(r.policy_snapshot["party"][1]["effects"], [])
        self.assertIsNone(r.policy_snapshot["ready_actions"]["haste"])

    def test_stale_party_actor_clears_derived_facts_and_completeness(self):
        s = fixture()
        s["party"][1]["observed_ms"] = 100
        r = project(s).policy_snapshot
        self.assertIsNone(r["party_complete"])
        self.assertIsNone(r["party"][1]["hp_pct"])
        self.assertIsNone(r["party"][1]["effects"])
        self.assertIsNone(r["party"][1]["alive"])
        self.assertIsNone(r["party"][1]["roles"])

    def test_wrong_zone_party_actor_clears_facts_not_silently_dropped(self):
        s = fixture()
        s["party"][1]["zone"] = "different"
        r = project(s).policy_snapshot
        self.assertEqual(len(r["party"]), 3)
        self.assertIsNone(r["party_complete"])
        self.assertIsNone(r["party"][1]["effects"])

    def test_stale_enemy_blocks_cast_fact_without_erasing_party(self):
        s = fixture()
        s["enemy"]["observed_ms"] = 1
        r = project(s).policy_snapshot
        self.assertIsNone(r["enemy"]["casting"])
        self.assertIsNone(r["enemy"]["alive"])
        self.assertIs(r["party_complete"], True)

    def test_wrong_zone_enemy_produces_unknown_not_no_enemy(self):
        s = fixture()
        s["enemy"]["zone"] = "other"
        r = project(s).policy_snapshot
        self.assertEqual(r["enemy"]["id"], "enemy")
        self.assertIsNone(r["enemy"]["casting"])

    def test_null_effects_never_convert_to_empty_effects(self):
        s = fixture()
        s["party"][0]["effects"] = None
        r = project(s).policy_snapshot
        self.assertIsNone(r["party"][0]["effects"])
        self.assertEqual(r["party"][1]["effects"], [])

    def test_incomplete_party_truth_preserved(self):
        s = fixture()
        s["party_complete"] = None
        self.assertIsNone(project(s).policy_snapshot["party_complete"])
        s["party_complete"] = False
        self.assertIs(project(s).policy_snapshot["party_complete"], False)

    def test_future_observation_not_accepted(self):
        s = fixture()
        s["party"][0]["observed_ms"] = 1001
        with self.assertRaises(ValueError):
            project(s)

    def test_bad_time_or_numeric_values_rejected(self):
        for key, value in (("now_ms", -1), ("max_age_ms", 0),
                           ("max_age_ms", True), ("now_ms", "1000")):
            s = fixture()
            s[key] = value
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                project(s)

    def test_bad_health_or_status_values_rejected(self):
        for field, bad in (
            ("hp_pct", -1), ("mp_pct", 120), ("hp_pct", True),
            ("effects", "unknown"), ("effects", ["regen", "regen"]),
        ):
            s = fixture()
            s["party"][0][field] = bad
            with self.subTest(field=field), self.assertRaises(ValueError):
                project(s)

    def test_invalid_role_readiness_and_enemy_shapes_fail(self):
        tests = (
            lambda s: s["party"][0].update({"roles": ["caster", "caster"]}),
            lambda s: s["party"][0].update({"roles": "tank"}),
            lambda s: s["ready_actions"].update({"unverified_cast": True}),
            lambda s: s["ready_actions"].update({"flash": "ready"}),
            lambda s: s["enemy"].pop("casting"),
            lambda s: s["enemy"].update({"casting": "yes"}),
            lambda s: s["enemy"].update({"id": "trust-healer"}),
        )
        for change in tests:
            s = fixture()
            change(s)
            with self.subTest(snapshot=s), self.assertRaises(ValueError):
                project(s)

    def test_no_mutation_and_deterministic_independent_copies(self):
        s = fixture()
        before = copy.deepcopy(s)
        a = project(s)
        b = project(s)
        self.assertEqual(a, b)
        self.assertEqual(s, before)
        a.policy_snapshot["party"][0]["hp_pct"] = 0
        self.assertEqual(s["party"][0]["hp_pct"], 70)
        self.assertEqual(b.policy_snapshot["party"][0]["hp_pct"], 70)

    def test_no_network_or_game_dispatch_surface(self):
        self.assertFalse(any(hasattr(Projection, n) for n in
                             ("execute", "dispatch", "cast", "start", "send")))
        self.assertTrue(callable(validate_source))


if __name__ == "__main__":
    unittest.main()
