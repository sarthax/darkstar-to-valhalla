# Planar Rift params[0]/params[1] correlation (2026-10-06)
Source: all Rift 0x034 events in `Playthrough Captures/voidwatch_captures` (Raguza 2021 set, 8 params).
NOTE: the older "p1/p2" naming in CAPTURE-ANALYSIS-ZACH2GOOD.md = params[0]/params[1] here (0-indexed). params[6]=cruor, params[7]=abyssite KI id.

## Client script (Ordelle's csid 6000, explore_event.py) — params[0] is a bit field [V]
bits read: 0,1,2,3,4, 5-7 (3-bit), 8-10 (3-bit), 11. Voidstone KI 1539 and Void Cluster KI 1805 are referenced in the branches; bit1 then bit2 gate the
"Voidwatch operation could be initiated if only you had..." (7522) vs "voidstone resonates..." path. Decompile of the branch tree is garbled (bad_addr_*), meanings of individual bits NOT decoded.

## [C] Observed (params[0], params[1]) by abyssite KI held (params[7])
| params[0] | params[1] | abyssite KI ids seen |
|---|---|---|
| 6 | 0 | 370, 371, 372 (indigo I-III) |
| 14 | 16 | 366, 367, 368 (crimson I-III), 373 (indigo IV) |
| 14 | 18 | 369 (crimson IV), 374-377 (jade I-IV) |
| 2062 | 18 or 1073741842 | 2060 (hyacinth) |
Wiggo 2018-20 set (older layout) sends params[0]=2126, params[1]=-1065873409 etc. with p3=1302,p4=170: client-era differs; do not mix.
Observation only: p0 bit3 (value 8) present for crimson/jade/indigo IV but not indigo I-III; p0 bit11 (2048) for hyacinth; p1 bit4 (16) all but indigo I-III; p1 bit1 (2) jade/crimson IV/hyacinth. 1073741842 = 2^30 + 18.
Meaning is NOT proven (could be per-path KIs the player holds, e.g. periapts, rather than a function of the abyssite).

## Implication
MVP can send the captured (p0,p1) pair keyed by abyssite KI id (above table) as a flagged replay of retail values; the exact derivation stays an open unknown. Wire the Rift only for abyssites covered by the table (crimson I-IV is covered).
