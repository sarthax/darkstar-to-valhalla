# Client audit results (partial) - original December 2019 `FFXiMain.dll`

Date: 2026-10-22. Input: owner-supplied backup, 2,870,352 bytes, SHA-256 `514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f` (verified with `sha256sum`; decoded `.text` SHA-256 prefix `af2126c057d8` matches). Static, read-only. No code bytes are stored in the repo; the evidence file holds IDs and RVAs only. All addresses are decoded-`.text` RVAs (image base `0x10000000`).
An earlier upload (`53e91099...`) was the Stage 3 build and was not used.

Status: **Q1 answered. Q2-Q6 (outgoing path) NOT STARTED.** No GO/NO-GO for the patched-client send path yet.

## Q1 - inbound handler table (answered)
| Fact | Evidence | Confidence |
|---|---|---|
| Registration is `call 0xF95D0(id, handler)`; `0xF95D0` is `jmp 0xF9590` | disassembly at `0xE85D0..` (`push handler; push id; call; cmp al,1`) | verified |
| `0xF9590`: if manager `[0x104CDA04]` non-null and `id < 0x11F`, store `handler` at `mgr + id*4 + 0x3E970`, return 1; else return 0 | disassembly | verified |
| Table has **0x11F (287) entries**, IDs 0-0x11E | the `cmp eax,0x11f; jl` above | verified |
| Dispatcher at `0xF79E9`: `idx = word[packet] & 0x1FF; fn = [mgr + idx*4 + 0x3E970]; if fn: call fn(...) else: log path (`push 0xA; call 0xF7B90`)`. **No bounds check** against 0x11F | disassembly `0xF79D5..0xF7A04` | verified |
| Only two code references to `+0x3E970` exist: the store (`0xF95AC`) and the dispatcher read (`0xF79E9`) | byte search over `.text` | verified |
| 84 registration calls classified (83 IDs with a handler, `0xB6` NULL-cleared); 2 calls left unclassified: `0xDDDA6` (false hit inside other bytes) and `0x110075` (`push eax` form; by hand reads as clearing `0xB5`) | `evidence/inbound_registrations_original_2019.json` | verified / flagged |
| Item handlers: 0x1C->`0xE97C0`, 0x1E->`0xE9800`, 0x1F->`0xE9860`, 0x20->`0xE9940` | JSON, matches Toolkit Stage 4 | verified |
| 204 IDs in 0-0x11E have no handler (NULL entry -> ignored via the log path) | JSON `unregistered_in_table` | verified for direct-call registrations; a registration via some other mechanism (table-driven, pointer call) was not searched for |

### Consequence (hard server rule)
**The server must never send the 2019 client a packet ID >= 0x11F.** Such an ID reads memory past the 0x11F-entry table and calls it if non-zero. Implemented as an egress drop (`ClientInboundIdSafe`, `packets/inventory_guard.h`, applied in `CCharEntity::pushPacket`) with an offline test. DSP's highest server packet ID today is `0xFA`, so nothing existing is affected. What lies past the table (mgr `+0x3EDEC`) was not examined; do not rely on it being zero.

### Provisional IDs
- **`S2C_W58_ACK`: `0x100` (provisional).** In the table (< 0x11F), no handler in the original, unused by every DSP server packet (max `0xFA`), inside a free run `0xFB-0x104`. The patched client would register its own handler there; an unpatched client ignores it. Keep a second choice (`0x101`) if a conflict appears.
- **`C2S_W58_HELLO`: undecided.** Depends on the client's outgoing builder (Q2/Q3). DSP's `PacketParser` is sized 512 and has 165 unregistered IDs, so the server side is not the constraint.

## Q2-Q6 - outgoing path (not started)
Needed before any server handshake code: where the client builds and sends packets, the outgoing ID set/size rules, a safe emit point after the first 0x1C, thread context, and packet encryption/checksum. See `CLIENT_AUDIT_WORKORDER.md`. If this proves unsafe, the feature stops and returns to the owner.

## Method notes / limits
Disassembly by Capstone (x86-32) on POL1-decoded `.text`, hand-read around each site. Static only: no execution, no proof that every path behaves as read. The scanner (`tools/client_patch/wardrobe5-8/audit_inbound_registrations.py`) is SHA-gated and covered by synthetic tests; a first heuristic version over-reported (shared callback hits) and was replaced by the exact call-target version.
