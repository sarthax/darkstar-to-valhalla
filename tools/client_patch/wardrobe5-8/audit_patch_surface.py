#!/usr/bin/env python3
"""Read-only audit: inventory of code that touches the 2019 client's item-store layout.

Counts and lists RVAs (scalars only, no code bytes) of
  * immediates for the store layout: record base +0x9860 / slot-1 +0x988C, capacity tables +0x152ED / +0x152FA,
    enumeration cursor +0x14D5C, container stride 0xDEC, store size 0x3B080;
  * direct calls to the shared accessors: record 0xE87B0, capacity u8 0xE8C60, capacity u16 0xE8C80,
    record-pointer -> container loop 0xE8810.
SHA-gated like the other tools. Used by docs/slices/wardrobe5-8/CLIENT_PATCH_DESIGN.md.
"""
import hashlib, json, re, struct, sys

EXPECTED_SHA256 = "514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f"
IMMEDIATES = {"record_base_0x9860": 0x9860, "record_slot1_0x988c": 0x988C, "cap_u8_0x152ed": 0x152ED,
              "cap_u16_0x152fa": 0x152FA, "cursor_0x14d5c": 0x14D5C, "container_stride_0xdec": 0xDEC,
              "store_size_0x3b080": 0x3B080}
ACCESSORS = {"record_accessor_0xe87b0": 0xE87B0, "cap_u8_getter_0xe8c60": 0xE8C60,
             "cap_u16_getter_0xe8c80": 0xE8C80, "record_to_container_0xe8810": 0xE8810}


def scan(decoded: bytes, decoded_rva: int = 0x1000) -> dict:
    out = {}
    for name, v in IMMEDIATES.items():
        out[name] = [decoded_rva + m.start() for m in re.finditer(re.escape(v.to_bytes(4, "little")), decoded)]
    for name, fn in ACCESSORS.items():
        out[name] = [decoded_rva + o for o in range(len(decoded) - 4)
                     if decoded[o] == 0xE8 and decoded_rva + o + 5 + struct.unpack_from("<i", decoded, o + 1)[0] == fn]
    return out


def summarize(scan_result: dict) -> dict:
    return {k: {"count": len(v), "rvas": [hex(x) for x in v]} for k, v in scan_result.items()}


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
                      "summary": summarize(scan(text["bytes"], text["base_rva"]))}, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]) if len(sys.argv) == 2 else print(__doc__) or 1)
