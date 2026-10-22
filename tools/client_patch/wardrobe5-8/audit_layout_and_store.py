#!/usr/bin/env python3
"""Read-only audit: PE layout, code caves and the item-store/manager pointers of the original 2019 client.

Reproduces the design facts F1-F5 of docs/slices/wardrobe5-8/CLIENT_PATCH_DESIGN.md:
  * PE headers: image base, section table, spare header bytes, DllCharacteristics, CheckSum, security dir, overlay;
  * padding runs (0xCC / 0x90 / 0x00, length >= 16) in the decoded .text = the only possible code caves;
  * every WRITE to the active-store pointer slot [0x104CDA08] and the manager pointer slot [0x104CDA04]
    (matched by exact opcode: A3 / 89 /r / C7 05, never by guessing instruction starts);
  * writes of an immediate to [reg+0x3B088] (the store count; expected: one write, value 1).
Scalar metadata only. SHA-gated like the other tools.
"""
import hashlib, json, re, struct, sys

EXPECTED_SHA256 = "514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f"
STORE_SLOT, MGR_SLOT, STORE_COUNT_DISP = 0x104CDA08, 0x104CDA04, 0x3B088
_REGS = ["eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi"]


def pe_layout(image: bytes) -> dict:
    pe = struct.unpack_from("<I", image, 0x3C)[0]
    nsec, = struct.unpack_from("<H", image, pe + 6)
    opt_size, = struct.unpack_from("<H", image, pe + 20)
    opt = pe + 24
    layout = {
        "image_base": hex(struct.unpack_from("<I", image, opt + 28)[0]),
        "entry_point_rva": hex(struct.unpack_from("<I", image, opt + 16)[0]),
        "section_alignment": hex(struct.unpack_from("<I", image, opt + 32)[0]),
        "file_alignment": hex(struct.unpack_from("<I", image, opt + 36)[0]),
        "size_of_image": hex(struct.unpack_from("<I", image, opt + 56)[0]),
        "size_of_headers": hex(struct.unpack_from("<I", image, opt + 60)[0]),
        "checksum": hex(struct.unpack_from("<I", image, opt + 64)[0]),
        "dll_characteristics": hex(struct.unpack_from("<H", image, opt + 70)[0]),
        "security_dir_rva": hex(struct.unpack_from("<I", image, opt + 96 + 4 * 8)[0]),
        "reloc_dir": [hex(struct.unpack_from("<II", image, opt + 96 + 5 * 8)[i]) for i in (0, 1)],
        "sections": [],
    }
    sec = opt + opt_size
    first_raw, last_end = None, 0
    for i in range(nsec):
        base = sec + 40 * i
        name = image[base:base + 8].rstrip(b"\0").decode("latin1")
        vsize, va, rawsize, rawptr = struct.unpack_from("<IIII", image, base + 8)
        flags, = struct.unpack_from("<I", image, base + 36)
        layout["sections"].append({"name": name, "va": hex(va), "vsize": hex(vsize), "raw_ptr": hex(rawptr),
                                   "raw_size": hex(rawsize), "flags": hex(flags)})
        if rawptr:
            first_raw = rawptr if first_raw is None else min(first_raw, rawptr)
        last_end = max(last_end, rawptr + rawsize)
    table_end = sec + 40 * nsec
    layout["section_table_end"] = hex(table_end)
    layout["spare_header_bytes"] = (first_raw - table_end) if first_raw else None
    layout["overlay_bytes"] = len(image) - last_end
    return layout


def padding_runs(decoded: bytes, decoded_rva: int = 0x1000, min_len: int = 16) -> list:
    runs = []
    for byte, kind in ((0xCC, "int3"), (0x90, "nop"), (0x00, "zero")):
        for m in re.finditer(bytes([byte]) + b"{%d,}" % min_len, decoded):
            runs.append({"rva": decoded_rva + m.start(), "length": m.end() - m.start(), "kind": kind})
    return sorted(runs, key=lambda r: -r["length"])


def slot_writes(decoded: bytes, va: int, decoded_rva: int = 0x1000) -> list:
    """Writes to the global at `va` by exact opcode: A3 (eax), 89 /r with disp32, C7 05 imm32."""
    out = []
    for m in re.finditer(re.escape(va.to_bytes(4, "little")), decoded):
        o = m.start()
        if o >= 1 and decoded[o - 1] == 0xA3:
            out.append((decoded_rva + o - 1, "mov [slot],eax"))
        if o >= 2 and decoded[o - 2] == 0x89 and decoded[o - 1] in (0x05, 0x0D, 0x15, 0x1D, 0x25, 0x2D, 0x35, 0x3D):
            out.append((decoded_rva + o - 2, "mov [slot]," + _REGS[(decoded[o - 1] - 5) // 8]))
        if o >= 2 and decoded[o - 2] == 0xC7 and decoded[o - 1] == 0x05:
            out.append((decoded_rva + o - 2, "mov [slot],imm32"))
    return sorted(out)


def disp_immediate_writes(decoded: bytes, disp: int, decoded_rva: int = 0x1000) -> list:
    """`C7 /0` stores of an imm32 to [reg+disp32]: returns (rva, value)."""
    out = []
    for m in re.finditer(re.escape(disp.to_bytes(4, "little")), decoded):
        o = m.start()
        if o >= 2 and decoded[o - 2] == 0xC7 and (decoded[o - 1] & 0xF8) == 0x80 and decoded[o - 1] != 0x84 and o + 8 <= len(decoded):
            out.append((decoded_rva + o - 2, struct.unpack_from("<I", decoded, o + 4)[0]))
    return out


def summarize(layout: dict, decoded: bytes, decoded_rva: int = 0x1000) -> dict:
    runs = padding_runs(decoded, decoded_rva)
    text_end = decoded_rva + len(decoded)
    return {
        "pe": layout,
        "text": {"decoded_size": hex(len(decoded)), "end_rva": hex(text_end),
                 "tail_slack_to_page": hex((-text_end) % 0x1000),
                 "padding_runs_ge16": len(runs), "padding_total_bytes": sum(r["length"] for r in runs),
                 "largest_runs": [{"rva": hex(r["rva"]), "length": r["length"], "kind": r["kind"]} for r in runs[:10]]},
        "store_pointer_slot_0x104cda08_writes": [{"rva": hex(a), "form": f} for a, f in slot_writes(decoded, STORE_SLOT, decoded_rva)],
        "manager_pointer_slot_0x104cda04_writes": [{"rva": hex(a), "form": f} for a, f in slot_writes(decoded, MGR_SLOT, decoded_rva)],
        "store_count_0x3b088_immediate_writes": [{"rva": hex(a), "value": v} for a, v in disp_immediate_writes(decoded, STORE_COUNT_DISP, decoded_rva)],
    }


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
                      "summary": summarize(pe_layout(image), text["bytes"], text["base_rva"])}, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]) if len(sys.argv) == 2 else print(__doc__) or 1)
