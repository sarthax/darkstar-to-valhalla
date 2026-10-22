"""Synthetic tests (no retail bytes). Run: python3 tools/client_patch/wardrobe5-8/test_audit_ui_containers.py"""
import importlib.util, pathlib, struct, unittest
spec = importlib.util.spec_from_file_location("aud", pathlib.Path(__file__).with_name("audit_ui_containers.py"))
aud = importlib.util.module_from_spec(spec); spec.loader.exec_module(aud)
RVA = 0x1000

def push(v):
    return bytes([0x6A, v]) if v < 0x80 else b"\x68" + v.to_bytes(4, "little")

def call_to(off, target):
    return b"\xE8" + struct.pack("<i", target - (RVA + off + 5))

class T(unittest.TestCase):
    def test_init_calls(self):
        b = b"\x90" * 16
        b += push(0) + push(0x10345134) + push(1); b += call_to(len(b), aud.INIT_RVA)
        b += push(0) + push(0x103450fc) + push(0xA); b += call_to(len(b), aud.INIT_RVA)
        b += call_to(len(b), 0x5000)
        r = aud.scan_init_calls(b.ljust(0x100, b"\x90"), RVA)
        self.assertEqual([(x["container"], x["name_va"], x["arg3"]) for x in r], [(1, 0x10345134, 0), (0xA, 0x103450fc, 0)])
    def test_menu_gates(self):
        b = b"\x90" * 8 + b"\x6a\x07" + call_to(10, aud.CAP_U8_RVA)
        tail = b"\x84\xc0\x75\x0a" + push(0xB) + push(5)
        b += tail; b += call_to(len(b), aud.MENU_REMOVE_RVA)
        g = aud.scan_menu_gates(b.ljust(0x100, b"\x90"), RVA)
        self.assertEqual([x["entry_id"] for x in g], [0xB])
    def test_non_matching_calls_ignored(self):
        b = (b"\x90" * 8 + call_to(8, aud.CAP_U8_RVA) + b"\x90" * 40).ljust(0x100, b"\x90")
        self.assertEqual(aud.scan_menu_gates(b, RVA), [])
    def test_read_cstring_from_synthetic_pe(self):
        pe = bytearray(0x400); struct.pack_into("<I", pe, 0x3C, 0x80)
        struct.pack_into("<H", pe, 0x80 + 6, 1); struct.pack_into("<H", pe, 0x80 + 20, 0xE0)
        sec = 0x80 + 24 + 0xE0
        struct.pack_into("<IIII", pe, sec + 8, 0x100, 0x1000, 0x100, 0x200)
        pe[0x200:0x20A] = b"wr_5.dat\0\0"
        self.assertEqual(aud.read_cstring(bytes(pe), aud.IMAGE_BASE + 0x1000), "wr_5.dat")
        self.assertIsNone(aud.read_cstring(bytes(pe), aud.IMAGE_BASE + 0x9000))
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
