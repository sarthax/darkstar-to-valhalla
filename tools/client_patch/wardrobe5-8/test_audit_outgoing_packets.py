"""Synthetic tests (no retail bytes). Run: python3 tools/client_patch/wardrobe5-8/test_audit_outgoing_packets.py"""
import importlib.util, pathlib, struct, unittest
spec = importlib.util.spec_from_file_location("aud", pathlib.Path(__file__).with_name("audit_outgoing_packets.py"))
aud = importlib.util.module_from_spec(spec); spec.loader.exec_module(aud)
RVA = 0x1000

def site(off, pid, target=aud.BEGIN_RVA, lead=b"\x6a\x00\x6a\x00"):
    push = bytes([0x6A, pid]) if pid < 0x80 else b"\x68" + pid.to_bytes(4, "little")
    pre = lead + push
    return pre + b"\xE8" + struct.pack("<i", target - (RVA + off + len(pre) + 5))

def blob(*ids, **kw):
    out = b"\x90" * 0x20
    for pid in ids:
        out += site(len(out), pid, **kw) + b"\x90" * 3
    return out.ljust(0x400, b"\x90")

class T(unittest.TestCase):
    def test_const_ids(self):
        s = aud.summarize(aud.scan_begin_calls(blob(0x0C, 0x15, 0x11E, 0x0C), RVA))
        self.assertEqual(s["outgoing_ids"], ["0xc", "0x15", "0x11e"]); self.assertEqual(s["constant_id_sites"], 4)
        self.assertEqual(s["ids_at_or_above_table_limit"], [])
    def test_flags_id_at_limit(self):
        self.assertEqual(aud.summarize(aud.scan_begin_calls(blob(0x11F), RVA))["ids_at_or_above_table_limit"], ["0x11f"])
    def test_other_targets_ignored(self):
        self.assertEqual(aud.scan_begin_calls(blob(0x0C, target=0x5000), RVA)["const"], [])
    def test_dynamic_site_listed_not_guessed(self):
        b = (b"\x90" * 0x20 + b"\x50" + b"\xE8" + struct.pack("<i", aud.BEGIN_RVA - (RVA + 0x21 + 5))).ljust(0x100, b"\x90")
        s = aud.scan_begin_calls(b, RVA)
        self.assertEqual(s["const"], []); self.assertEqual(s["dynamic_call_rvas"], [RVA + 0x21])
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
