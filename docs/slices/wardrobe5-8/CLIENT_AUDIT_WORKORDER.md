# Client send/receive path audit - work order

Status: **NOT RUN.** The DLL uploaded on 2026-10-22 is the Stage 3 build (SHA `53e91099...`), not the original, so it was not used. Needs the original `FFXiMain.dll` (SHA-256 `514653a2...f060f`), which is not available to the cloud session. Run on the owner's machine with the Toolkit research branch checked out, or hand the output back. Read-only; no DLL is modified, installed, or committed. Output is IDs/RVAs/booleans only.
Purpose: choose packet IDs for `HANDSHAKE_DESIGN.md` and decide whether the patched client can send a custom packet at all. Known facts are cited from Toolkit's Stage 4 report; everything else is UNKNOWN until answered.

## Already known (Toolkit Stage 4)
- Inbound handlers are registered as `push handler; push id` at decoded RVA `0xE85D0` region: 0x1C -> `0xE97C0`, 0x1E -> `0xE9800`, 0x1F -> `0xE9860`, 0x20 -> `0xE9940`.
- 0x1C handler reads packet bytes `0x00..0x2D`; bytes `+0x11..+0x13` are skipped.
- 0x1E/0x1F/0x20 index legacy records directly from the packet's container byte with no visible `<13` check. Server must therefore never send them a container >= 13.

## Questions (each needs RVAs as evidence, or "UNKNOWN")
| # | Question | Why it matters | Method |
|---|---|---|---|
| Q1 | Full list of inbound IDs the client registers, and the dispatch table size/bounds | Picks `S2C_W58_ACK`; shows whether an unregistered ID is ignored or crashes | Run `tools/client_patch/wardrobe5-8/audit_inbound_registrations.py` (written, synthetically tested only). Then read the dispatch routine: what happens for an ID with no handler? |
| Q2 | Where outgoing packets are built and sent (callers of ws2_32 `send`/`sendto`; the routine that writes the `id & 0x1FF` header, length and sequence) | Without a safe send routine the patched client cannot emit a hello | Import table -> xrefs -> outgoing queue/builder |
| Q3 | Outgoing packet ID set and size table, if one exists | Picks `C2S_W58_HELLO` that the 2019 client never emits and the server can size-check | Enumerate builder call sites and ID constants; compare with DSP's `PacketParser` (165 free IDs in 0x00-0xFF) |
| Q4 | Is there a safe hook point to emit one packet after the first 0x1C is parsed, once per zone-in? Is the send thread-safe from the 0x1C handler context? | Hello timing, avoiding re-entrancy | Read the 0x1C handler caller chain and the outbound queue's locking |
| Q5 | Does the client encrypt/checksum per packet in a way a new packet must reproduce? | Hello must pass the same transform | Follow Q2 routine down to the blowfish/MD5 stage |
| Q6 | Reserved/unused bytes in existing outgoing packets (fallback only) | Fallback if Q4 fails; note unmodified clients send these bytes | Diff builder stores vs packet sizes |

## Deliverable
`docs/slices/wardrobe5-8/CLIENT_AUDIT_RESULTS.md` (to be created) with: the Q1 JSON, answers Q2-Q6 with RVAs and confidence, chosen hello/ack IDs, and a GO/NO-GO for a patched-client send path. A NO-GO on Q2/Q4 blocks the whole feature and returns to the owner.

## Rules
Do not commit retail bytes, decoded code, or the DLL. Do not run or install any patched DLL. Do not send IDs >= 13 or any new packet to a client.
