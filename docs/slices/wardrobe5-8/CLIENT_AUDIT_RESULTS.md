# Client audit results (partial) - original December 2019 `FFXiMain.dll`

Date: 2026-10-22. Input: owner-supplied backup, 2,870,352 bytes, SHA-256 `514653a260c51eaec25d88510e51a86fb2a4abd9867f53d5f45a9ccf840f060f` (verified with `sha256sum`; decoded `.text` SHA-256 prefix `af2126c057d8` matches). Static, read-only. No code bytes are stored in the repo; the evidence file holds IDs and RVAs only. All addresses are decoded-`.text` RVAs (image base `0x10000000`).
An earlier upload (`53e91099...`) was the Stage 3 build and was not used.

Status: **Q1-Q5 answered (static). Q6 not needed. Send path: provisional GO**, subject to the runtime checks listed under "Open before implementation". Nothing has been executed against a client.

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

## Q2-Q5 - outgoing path (answered, static)
| # | Finding | Evidence | Confidence |
|---|---|---|---|
| Q2 | UDP map traffic leaves through ONE `sendto` wrapper (`0xD9EF0`, sends the global buffer at `0x1049BA54`, length at `0x1049BA50`), called only from the send routine at `0xF7C30` (call at `0xF7E04`). TCP `send` is used elsewhere (lobby/other libraries) | import table + xrefs | verified |
| Q2 | Client packets are NOT written to a socket buffer directly. Every packet is started with `slot = Begin(id, key, cookie)` at `0xF95E0` (cdecl, id is the last push), which takes a **0x110-byte slot** from a global ring at `[0x104CDA08]+0x10` via the allocator `0xDB270`. Begin refuses `id >= 0x11F`, writes `id & 0x1FF` into the slot header and returns the slot | disassembly `0xF95E0..0xF96E9`, `0xDB270..0xDB3B2` | verified |
| Q2 | 183 direct callers (177 with a constant ID, 145 distinct IDs, all < 0x11F; 6 call sites build the ID dynamically: `0x96830 0xDD991 0xE2A59 0xE6BA8 0xF59FD 0xF80C4`) | `evidence/outgoing_packets_original_2019.json` | verified / 6 sites unresolved |
| Q3 | Packet format: slot `+0` u16 header = `id | (N << 9)` where N = packet length in 4-byte words **including** the 4-byte header; slot `+2` u16 sequence (zeroed by Begin); payload from `+4`. Max total 0x104 bytes (drain rejects larger; N <= 0x41). Header is written LAST by the builder (an ID-only or size-0 slot is skipped by the drain). Example builder: `Begin(0x0C,0,0)` then `word[slot]=0x060C` (N=3, 12 bytes). Matches DSP's parser (`size byte = hdr>>8 & 0xFE`, i.e. 2N) | `0x9260F..0x92621`, drain `0xFAE4F..0xFAE74`, `map.cpp` parse loop | verified |
| Q3 | Allocator semantics: same `id` AND same `key` reuses the existing slot (coalesces); otherwise a new slot at the ring tail. When the ring is nearly full only a short list of ten priority IDs (ring `+0x18..+0x2A`) can still allocate; others get NULL | `0xDB270` | verified |
| Q3 | 101 of DSP's 105 client-packet parsers are in the client's static outgoing set (DSP-only: `0x61 0x78 0xDD 0x105`, i.e. emitted dynamically, or stale DSP entries). Method sanity check | cross-check script | consistent |
| Q4 | Allocator, Begin, drain and send contain no lock prefix and no synchronization API calls: the ring is single-thread by design (183 game-logic callers use it freely) | scan of `0xF95E0`, `0xDB270`, `0xFADE0`, `0xF7C30` | verified absence; that the 0x1C handler runs on the same thread as those callers is **inferred, not proven** |
| Q4 | A hello can be sent by calling Begin from (or right after) the 0x1C handler at `0xE97C0`, writing a payload and the header word. A full ring makes Begin return NULL; the patch must treat that as "retry next zone-in/tick", never loop | Begin/Alloc | verified (API); patch location not designed |
| Q5 | No per-packet encryption or checksum to reproduce. The whole bundle is assembled in `0xFADE0` and Blowfish-encrypted (`0xDADA0`, context `conn+0x30C0`) at send time, so a packet placed in the ring is transformed like any other | `0xF7C30..0xF7E04`, `0xDAD30`, `0xDAD80` | verified |
| Q6 | Not needed (a real send path exists), so no piggy-back on existing packets | - | n/a |

### Packet IDs (provisional, revised)
Constraints now known: the hello must be `< 0x11F` (client Begin) and the ack must be `< 0x11F` (client inbound table). Candidate = not emitted by the client (constant sites), not parsed by DSP, not registered inbound by the client, not sent by DSP. Free in every sense: `0xE3 0xE5 0xE6 0xED 0xEE 0xEF 0xF3 0xF7 0xF8 0xF9 0x103 0x10E 0x11E`.
**Proposal: `W58_HELLO` (client->server) = `W58_ACK` (server->client) = `0x103`**, backup `0x10E`. Caveat: the 6 dynamic call sites could emit other IDs, so "client never emits 0x103" is conditional until those are resolved.
Hello wire format (20 bytes, N=5, header word `0x0A03`): `+4 magic 'W58H' u32`, `+8 proto u16 = 1`, `+10 flags u16`, `+12 patchset[8]`. DSP side: `PacketSize[0x103] = 0x0A`.

### Open before implementation (none require touching a live system)
1. Resolve the 6 dynamic Begin call sites (could they emit 0x103?).
2. Code space: where to place the hello builder/sidecar code (code cave, section growth). POL1 repacking keeps size so far; unknown whether it can grow. This is a client-patch design question (Milestone C).
3. Confirm by emulation/trace (not on a live client) that calling Begin from the 0x1C handler context is safe.
4. Runtime check on a disposable client only after owner approval.

## Method notes / limits
Disassembly by Capstone (x86-32) on POL1-decoded `.text`, hand-read around each site. Static only: no execution, no proof that every path behaves as read. The scanner (`tools/client_patch/wardrobe5-8/audit_inbound_registrations.py`) is SHA-gated and covered by synthetic tests; a first heuristic version over-reported (shared callback hits) and was replaced by the exact call-target version.

## Equipment sets (macros) - where they live and what the ORIGINAL client does with them (2026-10-22, static)
Same input as above (verified original DLL). All addresses are decoded-`.text` RVAs / `.data` VAs.

| Fact | Evidence | Confidence |
|---|---|---|
| Sets are stored **client-side** as `es0.dat` .. `es4.dat`: file name = `sprintf("%s%d%s", "es", n, ".dat")` (strings at VA `0x1036EFA4`, `0x1036EFAC`, `0x1036EEF0`; builder `0x1A0920`) | disassembly | verified |
| 100 sets (index < `0x64`), 20 per file (index / 20 selects the file), **80-byte records** = 16-byte name (default `Set%03d`) + 16 entries x 4 bytes; loader `0x1A0970`, manager method `0x1A08B0`, pointer lookup `0x1A0EA0` | disassembly | verified |
| Entry layout (4 bytes): byte0 = `(container << 2) \| flag` (flag 1 = equip, 2 = remove), byte1 = inventory slot, bytes 2-3 = item ID. Container therefore has 6 bits | `0x19FDA0`, `0x1A0051`, 0x52 sender `0xE2760` | verified |
| Files are read/written through the client's user-file subsystem (`0x1B1940`, `0x1B1AC0`, `0x1B1BC0`), which uses the `USER` / `%s\%x` per-character folder strings. The exact directory was **not** traced | strings + call pattern | inferred |
| Server never stores sets; 0x052 is a validation echo (`0x116`), and the client forwards the reply to a registered callback (`0xE31E0`) | handler + DSP code | verified |
| Applying a set (`0x19FF80` -> 0x51 sender `0xE2800`, cap 16 entries) copies the stored slot and container into the packet only after the entry passes `0x19FDA0`, whose per-entry rules are: container must satisfy `0x19FB70` (**only {0, 8, 10, 11, 12}**), then `0x19FBA0` must find the item ID at (container, slot); otherwise it re-resolves the item with `0x19FCA0`, which begins `cmp container, 0xD; jge -> fail`. A container 13-16 entry therefore fails both checks and is dropped | disassembly | verified |
| Other consumers of set containers: `0x19F47B` has its own `container < 13` guard; `0x1A0170` (find item by ID) loops containers 0-12 with a counter, skipping 3, never from file data; `0x19FAD4` takes container from entries the client built (source not traced); `0x19FC00` is only called from `0x1A0170` | disassembly | verified except `0x19FAD4` source |

### Consequences
1. **Swapping the original DLL back with `es*.dat` saved by a patched client is expected to be safe for applying sets**: entries naming Wardrobes 5-8 are silently dropped (the slot just stays empty). Not proven for every UI path (display/edit of a set; `0x19FAD4` source), so keep the precaution: back up `es*.dat` before the first patched-client run and restore them on rollback.
2. **The patched client must extend the set module or sets using Wardrobes 5-8 will silently fail to equip.** Patch sites (all in the original, to be redirected to the Milestone C sidecar): `0x19FB70` (allowed-container list), `0x19FCA0` (`cmp 0xD`), `0x19F47B` (`cmp 0xD`), `0x1A0170` (loop bound `0xD`, extend to 17 and keep skipping 3), plus the record-array/capacity accesses in `0x19FBA0`, `0x19FC00`, `0x19FCA0` (`+0x988C`, `0xE8C60`). The 6-bit container field already holds 13-16.
3. The 0x053 style-lock set path is separate and its client-side storage format is **not yet found** (server ignores the container byte there). Open item.
