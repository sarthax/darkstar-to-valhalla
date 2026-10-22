# Source / revision manifest - wardrobe5-8 V1
Updated 2026-10-22 (cloud session handoff). "Verified" = checked by a command in that session; nothing here has been tested on the owner's server, DB or client.

## Source
| Item | Value | Verified |
|---|---|---|
| DSP `main` at branch cut | `86d4467d446569c741d76d296e640c3b844ad844` (PR #54 merge) | yes (git) |
| Feature branch | `feature/wardrobe5-8-v1` on `valhalla` (`github.com/sarthax/darkstar-to-valhalla`); tip = `git log -1` | yes |
| PR #51 | branch `fix/inventory-sort-invalid-container-20261018` (draft, open) merged into the feature at `d7b8c690` | yes |
| Toolkit research branch used | `research/2019-wardrobe-backport-gates-20261021` @ `a6de1db8be8c52189acb89e53d9272e91365bbae` (2026-10-21); source of `workbench/client/pol1_unpack.py`. Toolkit docs quote older head `71184c0e992e2aecaf606e730fc277834cefc82c`. **No POL1 repack tool on this branch** | yes |
| Toolkit `main` clone | `db8b06abab7cd5f7b0908109184453b30ae3b112` | yes |

## Client files (hashes only - no binaries in git)
| File | Size | SHA-256 | Status |
|---|---|---|---|
| **Original** December 2019 `FFXiMain.dll` | 2,870,352 | `514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f` | owner-supplied backup, hashed in the cloud session; all `evidence/` was generated from it |
| Original, POL1-decoded `.text` | 3,264,206 | `af2126c057d86559bfad2e164f7f7fd0a26bbc89ab29ea9cbde5cea807c7d2b8` | tools check this prefix (`af2126c057d8`) |
| Stage 2 no-op repack (Toolkit) | 2,870,352 | `27636cc595280ad46a401cf2d0159a651b80c39d912f5748784944604a923d2c` | not seen in the cloud session |
| Stage 3 one-instruction repack (Toolkit) | 2,870,352 | `53e91099d0d773ccde227c53ad57986126d969751514b05e96d39210b6dc699c` | **was uploaded once as "original"**; not used for analysis |
| Currently installed client DLL | ? | UNKNOWN | **local agent must hash** |
| Other staged DLLs | ? | UNKNOWN | **local agent must hash** |
| Patched output (V1) | - | none exists | - |

## Server / database
| Item | Value |
|---|---|
| Deployed map-server revision / build hash | UNKNOWN - local agent |
| MariaDB version, engine, schema revision | UNKNOWN - local agent. Migration tested only on MariaDB 10.11 (sandbox) with the repo's own `sql/char_*.sql` MyISAM definitions |
| Build tested | **none (full build never run)**. Syntax-only (`g++ 13 -std=c++17 -fsyntax-only`) of: `charentity.cpp`, `charutils.cpp`, `packet_system.cpp`, `lua_baseentity.cpp`, `item_state.cpp`, `packets/*.cpp` touched. `map.cpp`: 3 pre-existing Winsock errors on Linux, identical on unmodified `main` |

## Tests that exist and passed in the cloud session (`bash tests/wardrobe5-8/run_all.sh`)
`container_ids_test.cpp`, `inventory_guard_test.cpp` (links real `inventory_modify.cpp` + `char_equip.cpp`), `handshake_test.cpp` (links real `w58_ack.cpp`), five `test_audit_*.py` suites (synthetic bytes only), `tools/sqlcheck.py` on `up.sql`. Migration round-trip (fresh up, up again, down, down again, up) on a scratch DB with synthetic rows. Lua: `luac5.1 -p` on the two edited scripts.

## Evidence files
`evidence/inbound_registrations_original_2019.json`, `outgoing_packets_original_2019.json`, `patch_surface_original_2019.json`, `ui_containers_original_2019.json`, `layout_and_store_original_2019.json` - generated from the original DLL by the matching tools in `tools/client_patch/wardrobe5-8/`.
