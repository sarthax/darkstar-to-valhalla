"""GitHub Actions-only contract tests for a static Trust capability catalog."""
from __future__ import annotations

import copy
import json
import subprocess
import sys
import unittest
from pathlib import Path

from trust_role_capability_audit import (
    CapabilityAssessment, assess_all, assess_behavior, load_catalog, validate_catalog,
)

CATALOG_PATH = (Path(__file__).resolve().parent.parent
                / "docs/slices/trust-modernization/trust_role_capability_catalog_v0.json")
CATALOG = load_catalog(CATALOG_PATH)


def clone():
    return copy.deepcopy(CATALOG)


class TrustRoleCapabilitiesTests(unittest.TestCase):
    def test_inventory_count_and_pinned_source(self):
        self.assertEqual(len(CATALOG["capabilities"]), 26)
        self.assertEqual(len(CATALOG["behaviors"]), 12)
        self.assertEqual(CATALOG["source_boundary"],
                         "PERSONAL_DSP_IS_NOT_PRIVATE_VALHALLA")
        self.assertEqual(
            CATALOG["source_revisions"]["personal_dsp"],
            "19f00e357b78fe17411ede523a1acd01fe865ee8",
        )
        validate_catalog(CATALOG)

    def test_role_groups_have_healer_support_tank_damage_examples(self):
        self.assertEqual({b["role"] for b in CATALOG["behaviors"]},
                         {"healer", "support", "tank", "damage"})

    def test_every_cited_source_is_a_public_personal_dsp_engine_path(self):
        for c in CATALOG["capabilities"]:
            if c["status"] == "not_reviewed":
                self.assertIsNone(c["dsp_source"])
            else:
                self.assertTrue(c["dsp_source"]["path"].startswith("src/map/"))
                self.assertTrue(c["dsp_source"]["symbol"])

    def test_source_seams_never_claim_runtime_or_dispatch(self):
        for row in assess_all(CATALOG):
            self.assertIsInstance(row, CapabilityAssessment)
            self.assertEqual(row.runtime_verdict, "NOT_TESTED")
            self.assertFalse(row.runnable)
            self.assertFalse(row.dispatched)
            self.assertNotEqual(row.source_classification, "RUNTIME_VERIFIED")
            self.assertNotEqual(row.source_classification, "READY")

    def test_corsair_roll_and_double_up_are_source_unknown(self):
        for behavior in ("cor_roll_maintenance", "cor_double_up_policy"):
            a = assess_behavior(CATALOG, behavior)
            self.assertEqual(a.source_classification, "SOURCE_UNKNOWN")
            self.assertIn("cor_roll_result", a.evidence_unknown)

    def test_bard_song_has_symbol_and_missing_adapter(self):
        a = assess_behavior(CATALOG, "brd_song_maintenance")
        self.assertIn("bard_effect_stack", a.source_symbols_found)
        self.assertIn("trust_roster", a.adapter_gaps)
        self.assertEqual(a.source_classification, "ADAPTER_GAPS")

    def test_geobubbles_need_specialized_trust_bridge(self):
        a = assess_behavior(CATALOG, "geo_indi_support")
        self.assertIn("geo_luopan", a.source_symbols_found)
        self.assertIn("geo_indi_selection", a.adapter_gaps)
        self.assertIn("trust_pet_coexistence", a.adapter_gaps)

    def test_skillchain_opener_and_closer_cannot_use_unverified_windows(self):
        for name in ("skillchain_opener", "skillchain_closer"):
            a = assess_behavior(CATALOG, name)
            self.assertIn("skillchain_target_window", a.evidence_unknown)
            self.assertIn("trust_ws_dispatch", a.adapter_gaps)
            self.assertEqual(a.runtime_verdict, "NOT_TESTED")

    def test_magic_burst_requires_confirmed_target_and_element(self):
        a = assess_behavior(CATALOG, "magic_burst")
        self.assertIn("magic_burst_element", a.evidence_unknown)
        self.assertIn("skillchain_target_window", a.evidence_unknown)

    def test_healer_triage_needs_trust_party_and_landed_outcome(self):
        a = assess_behavior(CATALOG, "healer_triage")
        self.assertEqual(a.source_classification, "ADAPTER_GAPS")
        self.assertIn("friendly_target_legality", a.adapter_gaps)
        self.assertIn("cast_outcome", a.adapter_gaps)

    def test_healer_cleanse_has_source_status_helpers_but_not_landed_result(self):
        a = assess_behavior(CATALOG, "healer_cleanse")
        self.assertIn("status_removal", a.source_symbols_found)
        self.assertIn("cast_outcome", a.adapter_gaps)

    def test_tank_interrupt_requires_windup_observation(self):
        a = assess_behavior(CATALOG, "tank_interrupt")
        self.assertIn("enemy_cast_readback", a.adapter_gaps)
        self.assertIn("policy_action_arbiter", a.adapter_gaps)

    def test_tank_enmity_is_unreviewed_despite_dispatch_symbol(self):
        a = assess_behavior(CATALOG, "tank_enmity")
        self.assertIn("enmity_owner", a.evidence_unknown)
        self.assertIn("ability_dispatch", a.source_symbols_found)

    def test_all_results_are_deterministically_sorted(self):
        first = assess_all(CATALOG)
        self.assertEqual(first, assess_all(CATALOG))
        self.assertEqual([a.behavior_id for a in first],
                         sorted(a.behavior_id for a in first))
        for a in first:
            self.assertEqual(a.source_symbols_found, tuple(sorted(a.source_symbols_found)))
            self.assertEqual(a.adapter_gaps, tuple(sorted(a.adapter_gaps)))
            self.assertEqual(a.evidence_unknown, tuple(sorted(a.evidence_unknown)))

    def test_no_input_mutation(self):
        c = clone()
        before = copy.deepcopy(c)
        assess_all(c)
        self.assertEqual(c, before)

    def test_unknown_behavior_rejected(self):
        with self.assertRaises(ValueError):
            assess_behavior(CATALOG, "invented_cast")

    def test_duplicate_capability_rejected(self):
        c = clone()
        c["capabilities"].append(copy.deepcopy(c["capabilities"][0]))
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_duplicate_behavior_rejected(self):
        c = clone()
        c["behaviors"].append(copy.deepcopy(c["behaviors"][0]))
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_missing_required_capability_or_duplicate_reference_rejected(self):
        for required in (["not_real", "actor_health"], ["actor_health", "actor_health"]):
            c = clone()
            c["behaviors"][0]["required_capabilities"] = required
            with self.subTest(required=required), self.assertRaises(ValueError):
                validate_catalog(c)

    def test_no_runtime_verified_override(self):
        c = clone()
        c["capabilities"][0]["runtime_state"] = "VERIFIED"
        with self.assertRaises(ValueError):
            validate_catalog(c)
        c = clone()
        c["behaviors"][0]["verification_state"] = "PASSED_LIVE"
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_private_server_cannot_be_advertised_as_reviewed_source(self):
        c = clone()
        c["source_boundary"] = "PRIVATE_VALHALLA_SOURCE_AUDITED"
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_source_sha_must_be_original_snapshot(self):
        c = clone()
        c["source_revisions"]["lsb"] = "0000000000000000000000000000000000000000"
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_unreviewed_source_cannot_cite_a_fake_symbol(self):
        c = clone()
        unresolved = next(a for a in c["capabilities"] if a["status"] == "not_reviewed")
        unresolved["dsp_source"] = {
            "path": "src/map/entities/trust_fake.cpp",
            "symbol": "RunMyTrust",
        }
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_source_found_requires_a_citation(self):
        c = clone()
        c["capabilities"][0]["dsp_source"] = None
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_cannot_embed_executable_expression(self):
        c = clone()
        c["behaviors"][0]["python_eval"] = "__import__('os').system('x')"
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_invalid_source_paths_rejected(self):
        for path in ("../private-valhalla/actor.lua",
                     "src/map/../../etc/passwd", "plugins/engine.py"):
            c = clone()
            c["capabilities"][0]["dsp_source"]["path"] = path
            with self.subTest(path=path), self.assertRaises(ValueError):
                validate_catalog(c)

    def test_invalid_lsb_trust_path_rejected(self):
        c = clone()
        c["behaviors"][0]["lsb_trust_source"] = "../../conf/password"
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_unrecognized_role_and_classification_rejected(self):
        c = clone()
        c["behaviors"][0]["role"] = "admin"
        with self.assertRaises(ValueError):
            validate_catalog(c)
        c = clone()
        c["capabilities"][0]["status"] = "runtime_complete"
        with self.assertRaises(ValueError):
            validate_catalog(c)

    def test_requirements_with_just_cited_symbols_remain_source_only(self):
        c = clone()
        original = next(x for x in c["behaviors"] if x["id"] == "healer_triage")
        original["required_capabilities"] = ["actor_health", "status_query"]
        a = assess_behavior(c, "healer_triage")
        self.assertEqual(a.source_classification, "SOURCE_SEAMS_FOUND")
        self.assertFalse(a.runnable)
        self.assertFalse(a.dispatched)
        self.assertEqual(a.runtime_verdict, "NOT_TESTED")


if __name__ == "__main__":
    unittest.main()
