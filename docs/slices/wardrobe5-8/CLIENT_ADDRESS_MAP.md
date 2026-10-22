# Client address map - original December 2019 `FFXiMain.dll`

Everything here was read from the **verified original** (SHA-256 `514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f`, 2,870,352 bytes; POL1-decoded `.text` SHA-256 `af2126c057d86559bfad2e164f7f7fd0a26bbc89ab29ea9cbde5cea807c7d2b8`, 3,264,206 bytes). Static analysis only; nothing was executed. A local agent can re-verify any row with the tools listed in `tools/client_patch/wardrobe5-8/README.md` or by disassembling the same address in Ghidra/IDA/Capstone.

**Conventions.** Image base `0x10000000`. **RVA** = offset from the image base; the decoded `.text` starts at RVA `0x1000` (so file offset in the decoded blob = RVA - `0x1000`). `VA` = base + RVA. Globals below are written as VAs (what the code uses). Code is not rebased (no ASLR; relocations cover only `.data`/`.rdata`), so the original code embeds absolute VAs. **Do not guess**: any row marked *inferred* was not proven.

## How to get the decoded text locally (never commit it)
```
# Toolkit research branch commit used for pol1_unpack.py: a6de1db8be8c52189acb89e53d9272e91365bbae
PYTHONPATH=<toolkit>/src python3 - <<'PY'
from workbench.client.pol1_unpack import unpack_pol1
img = open(r"<path to ORIGINAL FFXiMain.dll>", "rb").read()      # check the SHA-256 first!
t = unpack_pol1(img)                                              # {'base_rva': 0x1000, 'bytes': ..., 'sha256': ...}
open("text.bin", "wb").write(t["bytes"])                          # local scratch only
PY
```

## Core objects and globals
| Name | Address | Notes |
|---|---|---|
| Manager pointer slot | VA `0x104CDA04` | points to a **static** block at VA `0x1096DB60`, `0xFB7D` dwords (0x3EDF4 bytes), zero-filled at init `0xF6BA7`. Written only at `0xF6BB3` (init) and `0xF6FE7` (clear) |
| Active store pointer slot | VA `0x104CDA08` | `= mgr[0] = mgr+4` = **the one static store** (VA `0x1096DB64`, size `0x3B080`). 15 writers: `0x3FA7 0xF6BC6 0xF6C1C 0xF6C33 0xF6D4D 0xF6FE2 0xF70D6 0xF7116 0xF7295 0xF73E1 0xF740E 0xF7694 0xF76ED 0xF8A55 0xF9B3C` (re-activate / clear; not all individually traced) |
| Store count | `mgr+0x3B088` | written once, value 1, at `0xF6C01` |
| Store = network/session object | fields | ring of outgoing packets `+0x10`; Blowfish context `+0x30C0`; item records `+0x9860` (record(c,s) = store + c*0xDEC + 0x9860 + s*0x2C, slot 0 unused); capacity u8[13] `+0x152ED`; capacity u16[13] `+0x152FA`; **change counter `+0x15314`**; enumeration cursor `+0x14D5C`; whole-store clear = 0xEC20 dwords = 0x3B080 bytes |
| Inbound handler table | `mgr+0x3E970` | **0x11F entries** (IDs 0..0x11E); dword just past it, `mgr+0x3EDEC`, is a timing interval, not a pointer |
| Send buffer struct | VA `0x1049BA50` (len), `+4` data | address returned by `0xD9EE0` |

## Networking
| Function | RVA | Behavior |
|---|---|---|
| `RegisterInbound(id, handler)` | stub `0xF95D0` (`jmp 0xF9590`), body `0xF9590` | stores handler at `mgr+0x3E970+id*4`; returns 0 for `id >= 0x11F` |
| `Begin(id, key, cookie)` | `0xF95E0` | cdecl, id is the last push. Refuses `id >= 0x11F`. Allocates a ring slot via `0xDB270`, writes `id & 0x1FF` in the header, zeroes seq. Returns slot* (payload at +4) or NULL |
| `PacketAlloc(ring, id, key, cookie)` | `0xDB270` | same `id`+`key` reuses the slot; ring full -> NULL except ten priority IDs (ring `+0x18..+0x2A`). Slot = 0x110 bytes: `+0` header u16 = `id | (N<<9)`, N = length in 4-byte words incl. header; `+2` seq; payload `+4`; key `+0x104`; ring back-pointer `+0x10C` |
| Ring init | `0xDB220` | |
| Finalize header | `0xF96F0` (`jmp 0xDB530`) | called after payload fill as `(slot, size, 0)` |
| Outgoing bundle builder (drains ring) | `0xFADE0` | slots of max 0x104 bytes; skips id 0 / size 0 |
| Send routine | `0xF7C30` | builds datagram, encrypts (`0xDADA0`), calls the `sendto` wrapper `0xD9EF0` at `0xF7E04`, increments `[conn+6]` |
| Blowfish | key init `0xDAD30`; counter `0xDAD80`; encrypt `0xDADA0` | context `store+0x30C0` |
| Inbound dispatcher | `0xF79E9` (in function starting ~`0xF7800`) | `idx = word[pkt] & 0x1FF; fn = [mgr + idx*4 + 0x3E970]; if fn: call` - **no bounds check** |
| Inbound registrations | block at `0xE85D0` and ~85 others | `evidence/inbound_registrations_original_2019.json` |
| Item packet handlers | 0x1C `0xE97C0`; 0x1E `0xE9800`; 0x1F `0xE9860`; 0x20 `0xE9940` | no bounds check on the container byte; 0x1C copies 13 u8 -> `+0x152ED` and 13 u16 -> `+0x152FA` |
| 0x116 reply handler | `0xE31E0` | forwards to callback `[0x1049F3E8]` |
| Outgoing IDs | 183 `Begin` call sites | `evidence/outgoing_packets_original_2019.json`; 6 dynamic sites: `0x96830 0xDD991 0xE2A59 0xE6BA8 0xF59FD 0xF80C4` |

## Item store access
| Function | RVA | Callers |
|---|---|---|
| `Record(container, slot)` | `0xE87B0` | 45 |
| `CapU8(container)` | `0xE8C60` | 36 |
| `CapU16(container)` | `0xE8C80` | 3 |
| `RecordToContainer(rec*)` (loop `< 13`, returns 13 if none) | `0xE8810` | 8 |
| Store activation + clear (`rep stosd` at `0xF711E`) | `0xF70F0` | |
| Store teardown (sets active pointer 0 at `0xF70D6`) | `0xF7050` | |
Full inline-site inventory: `evidence/patch_surface_original_2019.json`.

## Equipment sets (`es0.dat`..`es4.dat`) and style lock
| Item | Address | Notes |
|---|---|---|
| File name builder | `0x1A0920` | `sprintf("%s%d%s","es",n,".dat")`, n = set index / 20; strings VA `0x1036EFA4`, `0x1036EFAC`, `0x1036EEF0` |
| Loader / manager | `0x1A0970`, manager method `0x1A08B0`, pointer lookup `0x1A0EA0` (index `< 0x64`) | 100 sets, 80-byte records (name[16] + 16 x 4-byte entries) |
| Entry layout | | byte0 = `(container << 2) \| flag` (1 equip, 2 remove), byte1 = slot, bytes 2-3 = item ID |
| Apply set | `0x19FF80` -> `0xE2800` (0x51 sender, cap 16) | per entry `0x19FDA0` |
| Container filter | `0x19FB70` | accepts only {0, 8, 10, 11, 12} |
| Slot/item match | `0x19FBA0` (only after the filter); capacity search `0x19FC00` (from `0x1A0170`) | |
| Re-resolve item | `0x19FCA0`, begins `cmp container,0xD; jge fail` | |
| Other bound | `0x19F47B` (`cmp al,0xD; jae`) | |
| Find item by ID in containers 0..12 (skips 3) | `0x1A0170` | counter-bounded loop |
| Save entry (0x52 sender) | `0xE2760` | |
| Lock style from set | `0x1A02B0` -> `0xE2870` (0x53 type 3); other 0x53 sender `0xE2900` | copies bytes only, no container indexing |
| Unequip all | `0xE2950` | |

## Container UI objects and menus
| Item | Address | Notes |
|---|---|---|
| Object class | `new(0x13BC)`, ctor `0x212640` (no args) | 81 sub-entries x 24 bytes at `+0x6C`; `[this+0]` = container ID |
| Create block | `0x15F10C` (13 stanzas, stride 0x25) | |
| Teardown block | `0x16021A` (stride 0x20) | |
| `Init(this, container, file, arg3)` | `0x2126A0`; 13 calls `0xF7C2..0xF8DE`, plus `0x213328`, `0x213335` | maps UI global k -> container: 0-8 identity, global 9 -> 10, 10 -> 11, 11 -> 12, 12 -> 9 |
| UI globals | VA `0x10621FBC + 4k`, k = 0..12 | used by name, no indexed array |
| Save / shutdown / load | `0x2122F0` / `0x212730` / `0x212480` | files `is.dat is_2.dat bs.dat cl.dat ti.dat mb.dat sb.dat sk.dat ca.dat wr.dat wr_2.dat wr_3.dat wr_4.dat b2.dat` |
| Refresh | `0x2128D0` | uses `Record([this+0], slot)` for 81 slots; re-runs when `[this+0x14] != [store+0x15314]` |
| Update helper | `0x212A00` | |
| Free | `0x3077A0`; `operator new` `0x3077AB` | |
| Menu entry remove | `0x1159A0(menu, 5, entryId)` | called when `CapU8([uiObject+0]) == 0`; 15 gates, builders near `0x1306E6`, `0x140224`, `0x140512`, `0x14088B`, `0x1484DD`; `evidence/ui_containers_original_2019.json` |
| Slash commands | 24-byte records at `.data` RVA `0x34B1B0` (`/wardrobe`..`/wardrobe4` = IDs 111-114) | separate 12-byte handler table at RVA `0x34C098`; `/bank2` = ID 115, mode 9 |
| Mode selector | `0x1D4E70`, bound check at `0x1D4E8A`, 11-entry jump table `0x1D4F64` (modes 2-12) | from Toolkit Stage 4, not re-verified here |

## PE facts (`evidence/layout_and_store_original_2019.json`)
Image base `0x10000000`, no ASLR (`DllCharacteristics = 0`), `CheckSum = 0`, no Authenticode, 7 sections (`.text` raw size 0 - unpacked from `POL1` at load), 184 spare header bytes, 80-byte overlay, 10 padding runs >= 16 bytes (246 bytes total, max 32), 306 bytes of tail slack in `.text`'s last page.

## Not yet identified (do not assume)
Old-build menu DAT contents (are entries 13-16 defined?); the 11 whole-store 0x3B080 copies (EVB file transfers); the 0x19FAD4 entry source; any code beyond the cited ranges.
