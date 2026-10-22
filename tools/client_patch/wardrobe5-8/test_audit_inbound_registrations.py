"""Synthetic tests (no retail bytes). Run: python3 tools/client_patch/wardrobe5-8/test_audit_inbound_registrations.py"""
import importlib.util, pathlib, struct, unittest
spec = importlib.util.spec_from_file_location("aud", pathlib.Path(__file__).with_name("audit_inbound_registrations.py"))
aud = importlib.util.module_from_spec(spec); spec.loader.exec_module(aud)

BASE, RVA, STUB = aud.IMAGE_BASE, 0x1000, 0xF95D0

def call(at_off, target=STUB):
    return b"\xE8" + struct.pack("<i", target - (RVA + at_off + 5))

def reg(off, handler_rva, pid, handler_form="push", rep=False, target=STUB):
    """Build [push handler][rep]? [push id][rep]? call at buffer offset `off`; return bytes."""
    h = b"\x68" + (BASE + handler_rva).to_bytes(4, "little") if handler_form == "push" else b"\x6a\x00"
    i = bytes([0x6A, pid]) if pid < 0x80 else b"\x68" + pid.to_bytes(4, "little")
    pre = h + (b"\xf3\xab" if rep else b"") + i
    return pre + call(off + len(pre), target)

def blob(*parts, size=0x400):
    out = b"\x90" * 0x20
    for p in parts:
        out += p(len(out)); out += b"\x90" * 3
    return out.ljust(size, b"\x90")

class T(unittest.TestCase):
    def scan(self, *parts):
        return aud.scan_registrations(blob(*parts), RVA)
    def test_known_anchor_shape(self):  # 68 c0 97 0e 10 6a 1c e8 ... like 0xE85D0
        r = self.scan(lambda o: reg(o, 0xE97C0, 0x1C))["registrations"]
        self.assertEqual([(x["id"], x["handler_rva"]) for x in r], [(0x1C, 0xE97C0)])
    def test_wide_id_null_handler_and_rep_forms(self):
        s = self.scan(lambda o: reg(o, 0x2000, 0x11E), lambda o: reg(o, 0, 0xB5, "null", rep=True),
                      lambda o: reg(o, 0x2100, 0x12, rep=True))
        sm = aud.summarize(s)
        self.assertEqual(sm["registered_ids"], ["0x12", "0x11e"]); self.assertEqual(sm["null_registered_ids"], ["0xb5"])
        self.assertEqual(sm["ids_outside_table"], [])
    def test_out_of_table_and_duplicates_flagged(self):
        sm = aud.summarize(self.scan(lambda o: reg(o, 0x2000, 0x11F), lambda o: reg(o, 0x2100, 0x1C), lambda o: reg(o, 0x2200, 0x1C)))
        self.assertEqual(sm["ids_outside_table"], ["0x11f"]); self.assertEqual(sm["duplicate_ids"], ["0x1c"])
    def test_other_call_targets_ignored(self):
        self.assertEqual(self.scan(lambda o: reg(o, 0x2000, 0x1C, target=0x5000))["registrations"], [])
    def test_unmatched_pattern_is_unclassified_not_guessed(self):
        b = (b"\x90" * 0x20 + b"\xE8" + struct.pack("<i", STUB - (RVA + 0x20 + 5))).ljust(0x100, b"\x90")
        s = aud.scan_registrations(b, RVA)
        self.assertEqual(s["registrations"], []); self.assertEqual(s["unclassified_call_rvas"], [RVA + 0x20])
    def test_wrong_sha_refused(self):
        import tempfile, os, io, contextlib, sys, types
        p = tempfile.NamedTemporaryFile(delete=False); p.write(b"not a dll"); p.close()
        try:
            for n in ("workbench", "workbench.client"): sys.modules.setdefault(n, types.ModuleType(n))
            m = types.ModuleType("workbench.client.pol1_unpack"); m.unpack_pol1 = lambda b: 1/0
            sys.modules["workbench.client.pol1_unpack"] = m
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                self.assertEqual(aud.main(p.name), 2)
            self.assertIn("UNKNOWN_BUILD_FINGERPRINT", buf.getvalue())
        finally:
            os.unlink(p.name)

if __name__ == "__main__":
    unittest.main()
