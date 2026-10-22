#!/usr/bin/env python3
"""Read-only audit: enumerate the outgoing (client->server) packet IDs of the original 2019 FFXiMain.dll.

Verified by hand-disassembly of the original (2026-10-22):
  * every client packet is started with  slot = Begin(id, key, cookie)  at RVA 0xF95E0 (cdecl, id is the LAST push);
  * Begin refuses id >= 0x11F, takes a 0x110-byte slot from the global ring at [0x104CDA08]+0x10 via 0xDB270,
    stores (id & 0x1FF) in the slot header word and returns the slot (payload from +4);
  * the caller then writes the real header word  id | (size_in_4byte_words << 9)  (size includes the 4-byte header).
Output is scalar metadata only (IDs, RVAs). SHA-gated; same usage as audit_inbound_registrations.py.
"""
import hashlib, json, struct, sys

EXPECTED_SHA256 = "514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f"
BEGIN_RVA = 0xF95E0
TABLE_LIMIT = 0x11F


def scan_begin_calls(decoded: bytes, decoded_rva: int = 0x1000, begin_rva: int = BEGIN_RVA) -> dict:
    """Direct `call Begin` sites; id = immediately preceding push imm8/imm32, else the site is `dynamic`."""
    const, dynamic = [], []
    for o in range(10, len(decoded) - 5):
        if decoded[o] != 0xE8:
            continue
        if decoded_rva + o + 5 + struct.unpack_from("<i", decoded, o + 1)[0] != begin_rva:
            continue
        site = decoded_rva + o
        if decoded[o - 2] == 0x6A:
            const.append({"id": decoded[o - 1], "call_rva": site})
        elif decoded[o - 5] == 0x68:
            const.append({"id": struct.unpack_from("<I", decoded, o - 4)[0], "call_rva": site})
        else:
            dynamic.append(site)
    return {"const": const, "dynamic_call_rvas": dynamic}


def summarize(scan: dict) -> dict:
    ids = sorted({c["id"] for c in scan["const"]})
    return {"call_sites": len(scan["const"]) + len(scan["dynamic_call_rvas"]), "constant_id_sites": len(scan["const"]),
            "dynamic_call_rvas": [hex(x) for x in scan["dynamic_call_rvas"]],
            "outgoing_ids": [hex(i) for i in ids], "ids_at_or_above_table_limit": [hex(i) for i in ids if i >= TABLE_LIMIT],
            "sites": [{"id": hex(c["id"]), "call_rva": hex(c["call_rva"])} for c in sorted(scan["const"], key=lambda c: (c["id"], c["call_rva"]))]}


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
                      "summary": summarize(scan_begin_calls(text["bytes"], text["base_rva"]))}, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]) if len(sys.argv) == 2 else print(__doc__) or 1)
