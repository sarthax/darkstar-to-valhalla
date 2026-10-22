#!/usr/bin/env python3
"""Read-only audit of the 2019 client's container UI objects and menu gates (scalars only, SHA-gated).

Verified by hand-disassembly of the original (2026-10-22):
  * 13 UI objects are built as  new(0x13BC) -> ctor 0x212640(this)  (no arguments) and then each is initialised by
    Init = 0x2126A0(this, containerId, fileName, arg3):  [this+0] = containerId; fileName is a per-container user file
    (is.dat, bs.dat, ... wr_4.dat, b2.dat) loaded by 0x212480 (a missing file leaves zeroed defaults);
  * menu builders gate entries by capacity:  cap = 0xE8C60([uiObject+0]);  if (cap == 0) 0x1159A0(menu, 5, entryId).
Output: container -> file name table and the (call site, entry id) list.
"""
import hashlib, json, struct, sys

EXPECTED_SHA256 = "514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f"
INIT_RVA, CAP_U8_RVA, MENU_REMOVE_RVA = 0x2126A0, 0xE8C60, 0x1159A0
IMAGE_BASE = 0x10000000


def _push_imm(code: bytes, end: int):
    """Decode the push that ENDS at `end` (exclusive): returns (value, start) or None."""
    if end >= 2 and code[end - 2] == 0x6A:
        return code[end - 1], end - 2
    if end >= 5 and code[end - 5] == 0x68:
        return struct.unpack_from("<I", code, end - 4)[0], end - 5
    return None


def scan_init_calls(decoded: bytes, decoded_rva: int = 0x1000, init_rva: int = INIT_RVA) -> list:
    """`push arg3; push arg2; push arg1; call Init` -> {container, name_va, arg3, call_rva}."""
    out = []
    for o in range(15, len(decoded) - 5):
        if decoded[o] != 0xE8 or decoded_rva + o + 5 + struct.unpack_from("<i", decoded, o + 1)[0] != init_rva:
            continue
        a1 = _push_imm(decoded, o)
        a2 = _push_imm(decoded, a1[1]) if a1 else None
        a3 = _push_imm(decoded, a2[1]) if a2 else None
        if a1 and a2 and a3:
            out.append({"container": a1[0], "name_va": a2[0], "arg3": a3[0], "call_rva": decoded_rva + o})
    return out


def scan_menu_gates(decoded: bytes, decoded_rva: int = 0x1000) -> list:
    """After each capacity-getter call, the first `push entry; push 5; call menu_remove` within 40 bytes."""
    out = []
    for o in range(len(decoded) - 5):
        if decoded[o] != 0xE8 or decoded_rva + o + 5 + struct.unpack_from("<i", decoded, o + 1)[0] != CAP_U8_RVA:
            continue
        window = decoded[o + 5:o + 5 + 40]
        for j in range(len(window) - 4):
            if window[j] == 0xE8 and decoded_rva + o + 5 + j + 5 + struct.unpack_from("<i", window, j + 1)[0] == MENU_REMOVE_RVA:
                p2 = _push_imm(window, j)            # push 5
                p1 = _push_imm(window, p2[1]) if p2 else None   # push entryId
                if p2 and p2[0] == 5 and p1:
                    out.append({"cap_call_rva": decoded_rva + o, "entry_id": p1[0]})
                break
    return out


def read_cstring(image: bytes, va: int, limit: int = 64):
    """C string at image VA via the PE section table (None if unmapped)."""
    pe = struct.unpack_from("<I", image, 0x3C)[0]
    nsec = struct.unpack_from("<H", image, pe + 6)[0]
    opt = struct.unpack_from("<H", image, pe + 20)[0]
    sec = pe + 24 + opt
    rva = va - IMAGE_BASE
    for i in range(nsec):
        vsize, vaddr, rawsize, rawptr = struct.unpack_from("<IIII", image, sec + i * 40 + 8)
        if vaddr <= rva < vaddr + max(vsize, rawsize) and rva - vaddr < rawsize:
            start = rawptr + rva - vaddr
            end = image.find(b"\0", start, start + limit)
            return image[start:end if end >= 0 else start + limit].decode("latin1")
    return None


def main(path: str) -> int:
    from workbench.client.pol1_unpack import unpack_pol1   # Toolkit research branch
    with open(path, "rb") as fh:
        image = fh.read()
    sha = hashlib.sha256(image).hexdigest()
    if sha != EXPECTED_SHA256:
        print(json.dumps({"status": "UNKNOWN_BUILD_FINGERPRINT", "sha256": sha, "expected": EXPECTED_SHA256}))
        return 2
    text = unpack_pol1(image)
    inits = scan_init_calls(text["bytes"], text["base_rva"])
    for r in inits:
        r["file"] = read_cstring(image, r["name_va"]) if r["name_va"] else None
    gates = scan_menu_gates(text["bytes"], text["base_rva"])
    print(json.dumps({"status": "OK", "source_sha256": sha, "decoded_sha256": text.get("sha256"),
                      "ui_object_init_calls": [{"container": r["container"], "file": r["file"], "call_rva": hex(r["call_rva"])} for r in inits],
                      "menu_gates": [{"cap_call_rva": hex(g["cap_call_rva"]), "entry_id": g["entry_id"]} for g in gates]}, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]) if len(sys.argv) == 2 else print(__doc__) or 1)
