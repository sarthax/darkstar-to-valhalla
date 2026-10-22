# tools/client_patch/wardrobe5-8 - read-only audit tools

Metadata-only audits of the **verified original** December 2019 `FFXiMain.dll`. None of them modifies a file, prints code bytes, or applies a patch. They exist so every client fact used by `docs/slices/wardrobe5-8/` can be re-checked by anyone with the original DLL.

## Requirements
* Python 3.9+. No third-party packages.
* The Toolkit module `workbench.client.pol1_unpack` (decodes the POL1-packed `.text`). Use Toolkit research branch commit **`a6de1db8be8c52189acb89e53d9272e91365bbae`** (`research/2019-wardrobe-backport-gates-20261021`), then run with `PYTHONPATH=<toolkit>/src`. (Do not use `python -I`; it ignores `PYTHONPATH`.)
* The original DLL: 2,870,352 bytes, SHA-256 `514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f`. Every tool prints `{"status":"UNKNOWN_BUILD_FINGERPRINT",...}` and exits 2 for any other file (including the Stage 1-3 experiment DLLs).

## Tools
| Tool | Answers | Evidence it reproduces |
|---|---|---|
| `audit_layout_and_store.py` | PE layout (sections, spare header bytes, flags, overlay), code caves, writers of the active-store/manager pointers, store count | `evidence/layout_and_store_original_2019.json` |
| `audit_inbound_registrations.py` | which inbound packet IDs the client registers (table is 0x11F entries) | `evidence/inbound_registrations_original_2019.json` |
| `audit_outgoing_packets.py` | which outgoing IDs the client emits through `Begin()` (183 sites, 6 dynamic) | `evidence/outgoing_packets_original_2019.json` |
| `audit_patch_surface.py` | counts/RVAs of every code site touching the item-store layout and its accessors | `evidence/patch_surface_original_2019.json` |
| `audit_ui_containers.py` | 13 UI container objects (container -> file) and 15 menu capacity gates | `evidence/ui_containers_original_2019.json` |

Usage (same for all):
```
PYTHONPATH=<toolkit>/src python3 tools/client_patch/wardrobe5-8/<tool>.py <path to original FFXiMain.dll> > /tmp/out.json
diff <(python3 -m json.tool /tmp/out.json) <(python3 -m json.tool docs/slices/wardrobe5-8/evidence/<file>.json)
```
The two JSON files must be identical. A difference means the DLL, the Toolkit module or the tool changed - investigate before trusting any downstream document.

## Tests
`test_audit_*.py` use only synthetic bytes (no retail data) and run anywhere: `python3 tools/client_patch/wardrobe5-8/test_audit_<name>.py`, or all offline tests with `bash tests/wardrobe5-8/run_all.sh`.

## What these tools do NOT cover
The disassembly-based findings (network send path, `Begin()`/ring format, equip-set module, style lock, UI refresh) are documented with addresses in `docs/slices/wardrobe5-8/CLIENT_AUDIT_RESULTS.md` and `CLIENT_ADDRESS_MAP.md`. They were read with Capstone in a scratch session; re-verify them in your disassembler of choice. There is **no patch-application tool yet** (Milestone C0) and no POL1 repack tool in this repo.

## Rules
Never commit the DLL, the decoded `.text`, or any patched binary. Keep scratch output outside the repo.
