"""Synthetic tests (no retail bytes). Run: python3 tools/client_patch/wardrobe5-8/test_audit_layout_and_store.py"""
import importlib.util, pathlib, struct, unittest
spec = importlib.util.spec_from_file_location("aud", pathlib.Path(__file__).with_name("audit_layout_and_store.py"))
aud = importlib.util.module_from_spec(spec); spec.loader.exec_module(aud)

def tiny_pe():
    img = bytearray(0x800)
    struct.pack_into("<I", img, 0x3C, 0x80)
    pe = 0x80
    struct.pack_into("<H", img, pe + 6, 2); struct.pack_into("<H", img, pe + 20, 0xE0)
    opt = pe + 24
    struct.pack_into("<I", img, opt + 28, 0x10000000); struct.pack_into("<I", img, opt + 16, 0x1234)
    struct.pack_into("<I", img, opt + 32, 0x1000); struct.pack_into("<I", img, opt + 36, 0x200)
    struct.pack_into("<I", img, opt + 56, 0x3000); struct.pack_into("<I", img, opt + 60, 0x400)
    struct.pack_into("<H", img, opt + 70, 0)
    sec = opt + 0xE0
    for i, (name, va, vs, rp, rs) in enumerate((("a", 0x1000, 0x10, 0x400, 0x200), ("b", 0x2000, 0x10, 0x600, 0x100))):
        b = sec + 40 * i
        img[b:b + 8] = name.encode().ljust(8, b"\0"); struct.pack_into("<IIII", img, b + 8, vs, va, rs, rp)
    return bytes(img[:0x700]) + b"X" * 16   # 16 overlay bytes after last section end (0x700)

class T(unittest.TestCase):
    def test_pe_layout(self):
        l = aud.pe_layout(tiny_pe())
        self.assertEqual(l["image_base"], "0x10000000"); self.assertEqual(l["dll_characteristics"], "0x0")
        self.assertEqual(len(l["sections"]), 2); self.assertEqual(l["overlay_bytes"], 16)
        self.assertEqual(l["spare_header_bytes"], 0x400 - (0x80 + 24 + 0xE0 + 80))
    def test_padding_runs(self):
        d = b"\x55" * 8 + b"\xCC" * 20 + b"\x55" * 4 + b"\x90" * 40 + b"\x00" * 5
        r = aud.padding_runs(d, 0x1000)
        self.assertEqual([(x["length"], x["kind"]) for x in r], [(40, "nop"), (20, "int3")])
    def test_slot_writes_by_opcode(self):
        va = aud.STORE_SLOT; a = va.to_bytes(4, "little")
        d = b"\xA3" + a + b"\x90" + b"\x89\x35" + a + b"\x90" + b"\xC7\x05" + a + b"\x00\x00\x00\x00" + b"\x8B\x0D" + a  # last = a READ
        w = aud.slot_writes(d.ljust(0x40, b"\x90"), va, 0x1000)
        self.assertEqual([f for _, f in w], ["mov [slot],eax", "mov [slot],esi", "mov [slot],imm32"])
    def test_disp_immediate_writes(self):
        d = b"\xC7\x82" + (0x3B088).to_bytes(4, "little") + (1).to_bytes(4, "little") + b"\x8B\x89" + (0x3B088).to_bytes(4, "little")
        self.assertEqual(aud.disp_immediate_writes(d.ljust(0x40, b"\x90"), 0x3B088, 0x1000), [(0x1000, 1)])
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
