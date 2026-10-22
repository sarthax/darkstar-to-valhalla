#!/usr/bin/env python3
"""Read-only audit: enumerate inbound packet-handler registrations in the original 2019 FFXiMain.dll.

Why: HANDSHAKE_DESIGN.md needs a server->client ack packet ID the unmodified client either ignores or
never receives, and a clear picture of the client's inbound ID space. Output is scalar metadata only
(packet IDs and RVAs). It never writes or prints code bytes, and refuses any DLL whose SHA-256 differs.

Usage (Windows or Linux; Toolkit research branch checked out):
  PYTHONPATH=<toolkit>/src python3 audit_inbound_registrations.py <original FFXiMain.dll>
"""
import hashlib, json, re, sys

EXPECTED_SHA256 = "514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f"
IMAGE_BASE = 0x10000000          # from the verified anchor: push 0x100E97C0 == RVA 0xE97C0
# 68 <handler imm32> 6A <id imm8>      push handler ; push id
# 68 <handler imm32> 68 <id imm32>     push handler ; push id (id >= 0x80)
PATTERN = re.compile(rb"\x68(....)(?:\x6a(.)|\x68(....))", re.S)


def scan_registrations(decoded: bytes, decoded_rva: int = 0x1000, image_base: int = IMAGE_BASE) -> list:
    """Return [{id, handler_rva, site_rva, followed_by_call}] for push-handler/push-id sequences.

    A hit counts only if the handler VA lands inside decoded .text. `followed_by_call` flags an E8 call
    within the next 8 bytes; hits without it are weaker evidence and reported, not hidden.
    """
    out = []
    for m in PATTERN.finditer(decoded):
        handler_rva = int.from_bytes(m.group(1), "little") - image_base
        if not (decoded_rva <= handler_rva < decoded_rva + len(decoded)):
            continue
        pid = m.group(2)[0] if m.group(2) is not None else int.from_bytes(m.group(3), "little")
        if pid > 0x1FF:
            continue
        tail = decoded[m.end():m.end() + 8]
        out.append({"id": pid, "handler_rva": handler_rva, "site_rva": decoded_rva + m.start(),
                    "followed_by_call": 0xE8 in tail})
    return out


def summarize(regs: list) -> dict:
    strong = [r for r in regs if r["followed_by_call"]]
    ids = sorted({r["id"] for r in strong})
    dup = sorted({i for i in ids if sum(1 for r in strong if r["id"] == i) > 1})
    return {"registrations": len(regs), "strong": len(strong), "registered_ids": [hex(i) for i in ids],
            "duplicate_ids": [hex(i) for i in dup],
            "unregistered_ids_0x00_0xff": [hex(i) for i in range(0x100) if i not in ids],
            "sites": [{"id": hex(r["id"]), "handler_rva": hex(r["handler_rva"]), "site_rva": hex(r["site_rva"]),
                       "call": r["followed_by_call"]} for r in sorted(regs, key=lambda r: (r["id"], r["site_rva"]))]}


def main(path: str) -> int:
    from workbench.client.pol1_unpack import unpack_pol1   # Toolkit research branch
    with open(path, "rb") as fh:
        image = fh.read()
    sha = hashlib.sha256(image).hexdigest()
    if sha != EXPECTED_SHA256:
        print(json.dumps({"status": "UNKNOWN_BUILD_FINGERPRINT", "sha256": sha, "expected": EXPECTED_SHA256}))
        return 2
    text = unpack_pol1(image)
    regs = scan_registrations(text["bytes"], text["base_rva"])
    print(json.dumps({"status": "OK", "source_sha256": sha, "decoded_sha256": text.get("sha256"),
                      "summary": summarize(regs)}, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]) if len(sys.argv) == 2 else print(__doc__) or 1)
