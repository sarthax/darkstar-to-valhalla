#!/usr/bin/env python3
"""Read-only audit: enumerate inbound packet-handler registrations in the original 2019 FFXiMain.dll.

Method (verified by hand-disassembly of the original, 2026-10-22):
  * every registration is a call to the stub 0xF95D0 (jmp 0xF9590) or 0xF9590 directly, cdecl(id, handler);
  * 0xF9590 stores handler at [mgr + id*4 + 0x3E970] and fails for id >= 0x11F  (table = 0x11F entries);
  * the dispatcher (0xF79E9) indexes the same table with (word & 0x1FF) and NO bounds check.
Output is scalar metadata only (IDs, RVAs). It never prints code bytes, and refuses any DLL whose SHA-256 differs.

Usage (Toolkit research branch on the Python path):
  PYTHONPATH=<toolkit>/src python3 audit_inbound_registrations.py <original FFXiMain.dll>
"""
import hashlib, json, struct, sys

EXPECTED_SHA256 = "514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f"
IMAGE_BASE = 0x10000000
REGISTER_TARGETS = (0xF95D0, 0xF9590)   # stub, real function
TABLE_ENTRIES = 0x11F


def scan_registrations(decoded: bytes, decoded_rva: int = 0x1000, targets=REGISTER_TARGETS) -> dict:
    """Find direct calls to the register function and classify how (id, handler) were pushed.

    Accepts: [push handler|push 0] [rep stosd]? [push id8|push id32] [rep stosd]? call register.
    Everything that does not match is listed in `unclassified` (never guessed).
    """
    n, regs, unclassified = len(decoded), [], []
    for o in range(10, n - 5):
        if decoded[o] != 0xE8:
            continue
        tgt = decoded_rva + o + 5 + struct.unpack_from("<i", decoded, o + 1)[0]
        if tgt not in targets:
            continue
        p = o
        if decoded[p - 2:p] == b"\xf3\xab":
            p -= 2
        if decoded[p - 2] == 0x6A:
            pid, p = decoded[p - 1], p - 2
        elif decoded[p - 5] == 0x68:
            pid, p = struct.unpack_from("<I", decoded, p - 4)[0], p - 5
        else:
            unclassified.append(decoded_rva + o); continue
        if decoded[p - 2:p] == b"\xf3\xab":
            p -= 2
        if decoded[p - 5] == 0x68:
            handler = struct.unpack_from("<I", decoded, p - 4)[0] - IMAGE_BASE
        elif decoded[p - 2:p] == b"\x6a\x00":
            handler = None   # explicit NULL: clears the entry
        else:
            unclassified.append(decoded_rva + o); continue
        regs.append({"id": pid, "handler_rva": handler, "call_rva": decoded_rva + o})
    return {"registrations": regs, "unclassified_call_rvas": unclassified}


def summarize(scan: dict) -> dict:
    regs = scan["registrations"]
    set_ids = sorted({r["id"] for r in regs if r["handler_rva"] is not None})
    cleared = sorted({r["id"] for r in regs if r["handler_rva"] is None})
    seen, dup = set(), set()
    for r in regs:
        (dup if r["id"] in seen else seen).add(r["id"])
    out_of_table = sorted(i for i in seen if i >= TABLE_ENTRIES)
    return {"table_entries": TABLE_ENTRIES, "registration_calls": len(regs),
            "unclassified_call_rvas": [hex(x) for x in scan["unclassified_call_rvas"]],
            "registered_ids": [hex(i) for i in set_ids], "null_registered_ids": [hex(i) for i in cleared],
            "duplicate_ids": [hex(i) for i in sorted(dup)], "ids_outside_table": [hex(i) for i in out_of_table],
            "unregistered_in_table": [hex(i) for i in range(TABLE_ENTRIES) if i not in seen],
            "sites": [{"id": hex(r["id"]), "handler_rva": None if r["handler_rva"] is None else hex(r["handler_rva"]),
                       "call_rva": hex(r["call_rva"])} for r in sorted(regs, key=lambda r: r["id"])]}


def main(path: str) -> int:
    from workbench.client.pol1_unpack import unpack_pol1   # Toolkit research branch
    with open(path, "rb") as fh:
        image = fh.read()
    sha = hashlib.sha256(image).hexdigest()
    if sha != EXPECTED_SHA256:
        print(json.dumps({"status": "UNKNOWN_BUILD_FINGERPRINT", "sha256": sha, "expected": EXPECTED_SHA256}))
        return 2
    text = unpack_pol1(image)
    print(json.dumps({"status": "OK", "source_sha256": sha, "decoded_sha256": text.get("sha256"),
                      "summary": summarize(scan_registrations(text["bytes"], text["base_rva"]))}, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]) if len(sys.argv) == 2 else print(__doc__) or 1)
