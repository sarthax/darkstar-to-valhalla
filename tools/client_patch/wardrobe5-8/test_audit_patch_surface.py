"""Synthetic tests (no retail bytes). Run: python3 tools/client_patch/wardrobe5-8/test_audit_patch_surface.py"""
import importlib.util, pathlib, struct, unittest
spec = importlib.util.spec_from_file_location("aud", pathlib.Path(__file__).with_name("audit_patch_surface.py"))
aud = importlib.util.module_from_spec(spec); spec.loader.exec_module(aud)
RVA = 0x1000

def call(off, target):
    return b"\xE8" + struct.pack("<i", target - (RVA + off + 5))

class T(unittest.TestCase):
    def test_immediates_found(self):
        b = (b"\x90" * 8 + b"\x8d\xb1" + (0x152ED).to_bytes(4, "little") + b"\x90" * 4 + (0x9860).to_bytes(4, "little")).ljust(0x80, b"\x90")
        r = aud.scan(b, RVA)
        self.assertEqual(len(r["cap_u8_0x152ed"]), 1); self.assertEqual(r["cap_u8_0x152ed"][0], RVA + 10)
        self.assertEqual(len(r["record_base_0x9860"]), 1); self.assertEqual(r["cap_u16_0x152fa"], [])
    def test_accessor_calls(self):
        b = b"\x90" * 4
        b += call(len(b), 0xE87B0); b += call(len(b), 0xE87B0); b += call(len(b), 0xE8C60); b += call(len(b), 0x5000)
        r = aud.scan(b.ljust(0x80, b"\x90"), RVA)
        self.assertEqual(len(r["record_accessor_0xe87b0"]), 2); self.assertEqual(len(r["cap_u8_getter_0xe8c60"]), 1)
        self.assertEqual(r["cap_u16_getter_0xe8c80"], [])
    def test_summary_shape(self):
        s = aud.summarize({"x": [0x1234]})
        self.assertEqual(s, {"x": {"count": 1, "rvas": ["0x1234"]}})
    def test_wrong_sha_refused(self):
        import tempfile, os, io, contextlib, sys, types
        p = tempfile.NamedTemporaryFile(delete=False); p.write(b"x"); p.close()
        try:
            for n in ("workbench", "workbench.client"): sys.modules.setdefault(n, types.ModuleType(n))
            m = types.ModuleType("workbench.client.pol1_unpack"); m.unpack_pol1 = lambda b: 1/0
            sys.modules["workbench.client.pol1_unpack"] = m
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                self.assertEqual(aud.main(p.name), 2)
        finally:
            os.unlink(p.name)

if __name__ == "__main__":
    unittest.main()
