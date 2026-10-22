"""Synthetic tests (no retail bytes). Run: python3 -m unittest tools/client_patch/wardrobe5-8/test_audit_inbound_registrations.py"""
import importlib.util, pathlib, unittest
spec = importlib.util.spec_from_file_location("aud", pathlib.Path(__file__).with_name("audit_inbound_registrations.py"))
aud = importlib.util.module_from_spec(spec); spec.loader.exec_module(aud)

BASE, RVA = aud.IMAGE_BASE, 0x1000

def reg(handler_rva, pid, call=True):
    h = (BASE + handler_rva).to_bytes(4, "little")
    ident = bytes([0x6A, pid]) if pid < 0x80 else b"\x68" + pid.to_bytes(4, "little")
    return b"\x68" + h + ident + (b"\xE8\x00\x00\x00\x00" if call else b"\x90" * 5)

class T(unittest.TestCase):
    def test_known_anchor(self):  # same shape as the verified 0xE85D0 site: 68 c0 97 0e 10 6a 1c
        blob = b"\x90" * 16 + reg(0xE97C0, 0x1C)
        r = aud.scan_registrations(blob.ljust(0xF0000, b"\x90"), RVA)
        self.assertEqual([(x["id"], x["handler_rva"]) for x in r], [(0x1C, 0xE97C0)])
    def test_wide_id_and_weak_hit(self):
        blob = (reg(0x2000, 0x1E0) + reg(0x2100, 0x20, call=False)).ljust(0x3000, b"\x90")
        s = aud.summarize(aud.scan_registrations(blob, RVA))
        self.assertEqual(s["registered_ids"], ["0x1e0"]); self.assertEqual(s["registrations"], 2); self.assertEqual(s["strong"], 1)
    def test_handler_outside_text_ignored(self):
        blob = (b"\x68" + (BASE + 0x900000).to_bytes(4, "little") + b"\x6a\x1c" + b"\xE8" * 5).ljust(0x100, b"\x90")
        self.assertEqual(aud.scan_registrations(blob, RVA), [])
    def test_duplicates_flagged(self):
        blob = (reg(0x2000, 0x1C) + reg(0x2100, 0x1C)).ljust(0x3000, b"\x90")
        self.assertEqual(aud.summarize(aud.scan_registrations(blob, RVA))["duplicate_ids"], ["0x1c"])
    def test_wrong_sha_refused(self):
        import tempfile, os
        p = tempfile.NamedTemporaryFile(delete=False); p.write(b"not a dll"); p.close()
        try:
            import io, contextlib, sys, types
            sys.modules.setdefault("workbench", types.ModuleType("workbench"))
            sys.modules.setdefault("workbench.client", types.ModuleType("workbench.client"))
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
