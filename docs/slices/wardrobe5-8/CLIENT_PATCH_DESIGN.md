# Client patch design - Milestone C (December 2019 `FFXiMain.dll`)

Status: **DESIGN, 2026-10-22. Nothing is implemented, no patched binary exists, nothing was executed.** All "facts" come from static analysis of the verified original (SHA-256 `514653a2...f060f`); evidence files are in `evidence/`. Proposals are marked **PROPOSED**. No retail or patched binaries are ever committed.

## 1. Facts that shape the design (measured)
| # | Fact | Evidence | Confidence |
|---|---|---|---|
| F1 | **No usable code caves.** The decoded `.text` is packed: no padding run >= 64 bytes (largest 32), 246 bytes of runs >= 16 in total; the only slack is 0x132 (306) bytes after the end of `.text` to the page boundary | scan of decoded text | verified |
| F2 | **Room for a new section.** Section table ends at file offset 0x348, first raw data at 0x400: 184 spare header bytes = up to 4 more 40-byte section headers. `SizeOfHeaders` 0x1000, `FileAlignment` 0x200, `SectionAlignment` 0x1000 | PE headers | verified |
| F3 | **Fixed base, no signature.** `DllCharacteristics = 0` (no ASLR), preferred base `0x10000000`, `CheckSum = 0`, no Authenticode directory. 80 overlay bytes after the last section must be preserved. `.text` has raw size 0: its code is unpacked from the `POL1` section at load (already proven editable by Toolkit Stages 1-3) | PE headers | verified |
| F4 | **One static store.** The item store is embedded in a static 0x3EDF4-byte "manager" block (VA `0x1096DB60`, zero-filled at init `0xF6BA7`); `[0x104CDA04]` = manager, `[0x104CDA08]` = active store = `mgr[0]` = `mgr+4`. The store count at `mgr+0x3B088` is written **once, as 1** (`0xF6C01`) and never elsewhere, so `mgr[index]` only ever yields store 0. The 15 writers of the active pointer (`0x3FA7`, `0xF6BC6`, `0xF6C1C`, `0xF6C33`, `0xF6D4D`, `0xF6FE2`, `0xF70D6`, `0xF7116`, `0xF7295`, `0xF73E1`, `0xF740E`, `0xF7694`, `0xF76ED`, `0xF8A55`, `0xF9B3C`) therefore re-activate that one store or clear the pointer. (Each of the later writers was not individually traced.) | disassembly | verified; writers not all traced |
| F5 | **The "store" is the whole network/session object**: ring of outgoing packets at `+0x10`, Blowfish context at `+0x30C0`, item records at `+0x9860`, capacity tables at `+0x152ED` (13 x u8) and `+0x152FA` (13 x u16), enumeration cursor at `+0x14D5C`. Activation (`0xF70F0`) zero-fills 0xEC20 dwords = 0x3B080 bytes | disassembly | verified |
| F6 | **Item access is concentrated.** Record accessor `0xE87B0(container, slot)` has 45 callers; capacity getters `0xE8C60` (u8) 36 and `0xE8C80` (u16) 3; record-pointer-to-container `0xE8810` (loop `< 13`, returns 13 if none) 8. Remaining inline touches of the layout: `+0x9860` x21, `+0x988C` x17, `+0x152ED` x3, `+0x152FA` x2, cursor `+0x14D5C` x6, stride 0xDEC x4, whole-store 0x3B080 x11 | `evidence/patch_surface_original_2019.json` | verified |
| F7 | Inbound handler table: 0x11F entries, unchecked dispatcher. Outgoing: `Begin()` (`0xF95E0`) allocates ring slots, refuses id >= 0x11F; the ring is single-threaded. `[mgr+0x3EDEC]` (the dword just past the inbound table) is a timing interval, so an out-of-table ID would call garbage | `CLIENT_AUDIT_RESULTS.md` | verified |
| F8 | Equipment sets (`es0-4.dat`) are filtered to containers {0,8,10,11,12} and `< 13` at `0x19FB70`, `0x19FCA0`, `0x19F47B`, `0x1A0170`; style lock reuses them and needs no patch of its own | `CLIENT_AUDIT_RESULTS.md` | verified |

## 2. Architecture decisions (PROPOSED)
**D1 - Code and data live in new PE sections, not caves (F1, F2).** Add two sections: `.w58c` (code, R-X, file-backed) and `.w58d` (data, RW, no raw data, zero-filled by the loader). Uses 80 of the 184 spare header bytes. Update `NumberOfSections`, `SizeOfImage`; keep the overlay. No checksum/signature to maintain (F3).
**D2 - One static sidecar (F4).** `.w58d` holds a single sidecar: 4 containers x (81 slots x 44 bytes) = 14,256 bytes, plus a small header (4 x u8 sizes, 4 x u16 capacities, state flags). No allocator, no lifetime management, because the store itself is a singleton in static memory. Record for container `c >= 13`: `sidecar + (c-13)*0xDEC + slot*0x2C`, the same stride as the original so shared code works unchanged. The sidecar is **cleared wherever the store is cleared** (hook the activation at `0xF711E` and the pointer-clear sites) so it cannot outlive a zone/reset.
**D3 - Route through the three accessors first (F6).** Patch `0xE87B0`, `0xE8C60`, `0xE8C80` and `0xE8810` once: container `< 13` follows the original path byte-for-byte; `13..16` goes to the sidecar; anything else returns the same "not found" values the originals already return for a null store. That covers the 45 + 36 + 3 + 8 call sites. Only the inline sites (F6) then need individual treatment.
**D4 - Patch mechanics.** Declarative patch definition (source-controlled, no binary): per site `{rva, expected_bytes, kind: jmp-trampoline|replace, new_code_ref}`. The tool (a) refuses any input whose SHA-256 differs, (b) checks every site's expected bytes, (c) applies to the decoded text, appends the sections, (d) repacks POL1 with the Toolkit repack tool, (e) emits output hashes + a site report. Trampolines are 5-byte `jmp rel32` at instruction boundaries with displaced instructions re-executed in `.w58c`. New code uses only `rel32` calls into the original and the same absolute global addresses the original uses (it already assumes the fixed base, F3); it begins with an image-base check and disables itself if the base is not `0x10000000`.
**D5 - Handshake in new code (F7).** Register the ack handler (`0xF95D0(0x103, handler)`) lazily right before the first hello of a zone-in (table exists by then). Send the hello with `Begin(0x103,0,0)`; write payload then header word `0x0B03` (id `0x103`, 5 words); treat a NULL slot as "retry on the next trigger", never loop. Trigger: a trampoline at the end of the 0x1C handler (`0xE97C0`) once per zone-in. The ack handler sets `state.extended=1`, copies the four sizes/capacities, and clears nothing else. State clears at store activation (D2). A client talking to a server that never acks stays exactly legacy.
**D6 - Item packets.** In the 0x1E/0x1F/0x20 handlers (`0xE9800`, `0xE9860`, `0xE9940`) replace the inline `container*0xDEC + 0x9860` arithmetic with a call to the routed record function and add the bound `container < 17` (this also closes the missing `< 13` check the original lacks). 0x1C stays untouched (the ack carries Wardrobe 5-8 capacities, see HANDSHAKE_DESIGN.md).
**D7 - Equipment-set module.** Extend the four filters in F8 to `{0,8,10,11,12,13..16}` / `< 17` (`0x19FB70`, `0x19FCA0`, `0x19F47B`, `0x1A0170` loop bound, keeping the skip of container 3) so sets naming Wardrobe 5-8 resolve instead of being silently dropped; the record/capacity accesses inside `0x19FBA0`, `0x19FC00`, `0x19FCA0` follow D3.
**D8 - UI (largest and least known).** Known blockers from Toolkit Stage 4: 13 UI container objects (globals `0x10621FBC..0x10621FEC`, update helper `0x212A00`, teardown `0x212670`, free `0x3077A0`), 3 UI `container < 13` guards (`0x1E7FAC`, `0x1E830B`, `0x1E847E`) with capacity getters at `0x1E7FDE...`, an 11-entry mode jump table at `0x1D4F64` for modes 2-12 (mode 9 is `/bank2`), and 4 slash-command records at `0x34B1B0` (24-byte records, no free space after them) with a separate 12-byte handler table. **Open and PROPOSED as separate sub-milestones:**
 - C3a *Item lists in existing screens* (equipment pick list, move menus): extend the UI guards, create 4 more container UI objects with the existing constructor (to be verified: is it parameterized by container ID?) and add them to the update/teardown lists.
 - C3b *Wardrobe 5-8 windows and `/wardrobe5-8`*: relocate the command table and handler table into `.w58c`, add modes 13-16 (new mode objects + getters), relocate the jump table and widen its bound check. Highest risk; owner decision needed on whether V1 ships without it (items usable via equipment screens and sets, no dedicated windows).
**D9 - Not touched in V1:** the 11 whole-store 0x3B080 copies (F6; purpose unknown, EVB file transfers). The sidecar is not saved by them; if one restores a store snapshot the sidecar must be invalidated (open item, below).

## 3. Patch-site inventory (counts from the tool; classification of inline sites is C1 work)
| Class | Sites | Handling |
|---|---|---|
| Shared accessors | `0xE87B0`, `0xE8C60`, `0xE8C80`, `0xE8810` (4 functions, 92 call sites) | D3: patch the function once |
| Packet handlers 0x1C/0x1E/0x1F/0x20 | `0xE97C0..0xE9970` (inline `+0x152ED/+0x152FA/+0x9860`) | D6 (0x1C left alone) |
| Equip-set module | `0x19FB70`, `0x19FBA0`, `0x19FC00`, `0x19FCA0`, `0x19F47B`, `0x1A0170` | D7 |
| Container UI | `0x1E7FDA`, `0x1E833F`, `0x1E8494`, `0x2131AE`, `0x21325C`, UI object lists | D8 |
| Layout inside the original accessors | `0xE6AF1/0xE6AF9`, `0xE8782..0xE887D` (cursor), `0xE8B31..0xE8C23`, `0xE8EC1`, `0xE8F64`, `0xE921B`, `0xE92F0` | C1 classification |
| Other inline `+0x9860`/`+0x988C` | `0x6920`, `0x948C4`, `0x16975A` and the rest in `evidence/patch_surface_original_2019.json` | C1 classification |
| Whole-store copies | 11 sites (`0x3FA2` ... `0x4819`) | D9 / audit |
| Stride `0xDEC` | `0x40221`, `0x456C7`, `0x4C570`, `0xE8840` | C1 classification |

## 4. Milestones and gates
| ID | Deliverable | Test gate |
|---|---|---|
| C0 | Patch-definition format + tool skeleton; PE section appender; SHA/byte-precondition checks; deterministic output | Synthetic-binary unit tests (no retail bytes) in CI |
| C1 | Classify every inline site (table above) with a proposed edit each | Review only |
| C2 | Sidecar + accessor routing (D2, D3) + packet handlers (D6) + set filters (D7) + hello/ack (D5) | **Emulation harness** (below) differential tests |
| C3a/C3b | UI work (D8) | Owner decision on scope; emulation of UI helpers where feasible |
| C4 | Local isolated-copy client trial | **Owner approval**; original DLL restored and hash-checked afterward |

**Emulation harness (PROPOSED test method).** Load the real decoded text locally (never committed) into an x86 emulator (e.g. Unicorn), build a synthetic store, apply the patch, and run the actual patched functions: (1) differential test: for containers 0-12 and random slots, patched `0xE87B0/0xE8C60/0xE8C80/0xE8810` return exactly what the originals return; (2) container 13-16 round-trips through the sidecar; (3) feed byte-exact 0x1E/0x1F/0x20 and ack packets produced by the DSP server's own builders into the patched handlers and compare the resulting records; (4) out-of-range containers never write outside the sidecar. This runs without a game process and without the server. It needs the retail DLL, so it is a local gate, not CI.

## 5. Risks and unknowns (honest list)
1. **POL1 repack size.** Stage 2/3 repacks kept the file size; many more changed bytes may compress worse. If the stream outgrows `POL1`'s raw size the section and every following raw offset must grow. Check in C0 with the Toolkit repack tool.
2. **Section-add acceptance.** Stages 1-3 prove header and code edits boot; a *new section* is untested. Mitigation if refused: fall back to a smaller design using the 306-byte tail + trampolines into a heap block allocated at first hello (needs a safe allocator call).
3. **Unclassified inline sites** (F6) may hide container-specific logic (snapshots, UI, trade). C1 is a hard gate before any code is written.
4. **UI object construction** (D8) is unmapped; the largest schedule risk. The 13 UI objects might not be parameterized by container ID.
5. **Whole-store copies** (D9): if any restores a store from disk the sidecar goes stale.
6. **Same-thread assumption** for sending from the 0x1C handler is inferred, not proven (CLIENT_AUDIT_RESULTS.md).
7. **`0xF95D0` registration after init**: registering a handler later than the original table build is untested; fallback is to hook the table build (`0xE85D0` run).
8. **Anti-tamper / launcher checks** for the PlayOnline launcher are unknown; Stages 1-3 passed with edited bytes, a new section is new.

## 6. Decisions requested from the owner
1. Approve the **new-section** approach (D1) and the **single static sidecar** (D2).
2. UI scope for V1: C3a only (items usable from the equipment screens and sets, no dedicated windows) or also C3b (windows + `/wardrobe5-8`)?
3. Approve adding Unicorn (x86 emulator) as a **local-only dev dependency** for the harness.
