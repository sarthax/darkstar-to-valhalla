# Atmacite Refiner: capture decode (2026-10-09)

Sources: Raguza "VW - Refine {Crimson,Indigo,Jade} Stratum Abyssite II/III/IV" (2021.03.27/28, caplog + eventview) [C];
Wiggo "Hahava Enrich Atmacite" (2020-02-02, PacketViewer 0x034/0x05B/0x05C/0x02A, Windurst Waters zone 238) [C];
Windurst Waters dialog.yml pulled this session with mission_toolkit.py (text for the message ids below) [D].
Tags: [C] capture, [D] DAT, [U] unknown.

## 1. Refiner event start params (csid 962 / 8 / 1023), stratum-only characters [C]

| param | meaning |
|---|---|
| p0 | nation << 18, plus bit1 always, bit2 when any stratum stone is held |
| p1 | 16 when a stone is held; bit1 (+2) seen in 4 of 12 captures, cause unknown [U] |
| p4 | cruor (exact, matches the character's balance) |
| p5 | 0x800000 + one bit per HELD stratum stone, bit = path*4 + tier-1 (Crimson 0-3, Indigo 4-7, Jade 8-11) |
| p6 | 2 bits per path (Crimson 0-1, Indigo 2-3, Jade 4-5): 11 = held stone ready, odd tier; 01 = ready, even tier; 00 = not held or not ready |
| p7 | 7 |

Evidence for p5 being "held", not "tier complete": a Jade-I refine read 0x188 = Crimson IV (bit 3) + Indigo IV (bit 7) + Jade I (bit 8).
Evidence for p6 ready bit: Indigo II->III capture, second event packet (holding II, kills not done): p5 = 0x20, p6 = 0, and the client plays "isn't exhibiting any signs of growth". The same stone, ready, gave p6 = 4.
All 11 "ready" packets across the nine captures match the formula; the held-and-not-ready packet is the single p6 = 0 case.

Refine confirm: Option 1, auto=0 [C] (already implemented).

## 2. Menu text [D]

Zone 238 dialog ids (raw, without the 0x8000 flag):
- 15704 top menu: Nothing / Have stratum abyssite examined / Request teleportation / Analyze atmacite / Ask about atmacite / Ask about atmacite enrichment.
- 15705 atmacite menu: Nothing / Infused x3 (shows KI + level) / Purge atmacite / Infuse atmacite / Enrich atmacite.
- 15706 infuse list (cruor shown), 15707 "Infusing X (lv.N) requires N cruor", 15708 "Infuse X?", 15709 not enough cruor,
  15710 [Infuse/Purge] list, 15711 "Purge X?", 15712 infused message (KI, level, cruor), 15713 could not be infused,
  15714 purged, 15715 purge + infuse swap (cruor shown), 15716 no atmacite capable of enrichment, 15717 enrich list,
  15718/15719 enrich preview and cost, 15720 "Enrich X?", 15721 enriched message, 15722 max level, 15723 level failed to rise, 15724 could not be purged, 15725 bonus preview, 15726 "Replace X?".

## 3. Atmacite option encoding [C]

- Atmacite index `slot = atmacite KI id - 1805` in the CLIENT key item numbering (1807 -> 2, 1810 -> 5, 1835 -> 30, 1841 -> 36). Four atmacites seen; mapping to DSP key item ids is not verified.
- Enrich one level: Option `(slot << 16) | 5`, auto=1. Server answers with an Update plus special message 15721 with params `(cost, atmacite KI, new level, ...)`. The client then re-sends Option `(slot << 16) | 2` (auto=1) to refresh the list.
- Infuse: Option `((0x80 | slot) << 16) | 6`, auto=0 (seen: 0x850006 for KI 1810). Server answered with special message 15712, params `(KI, level 1, cost 100)`. So infusing a level-1 atmacite costs 100 cruor [C].
- List refresh Update (reply to `...|2`): p0..p4 are 8 nibbles each, nibble = atmacite level, index = KI id - 1806 (p0 nibble 0 = KI 1806). 1 = level 1 or empty. p5 = 0x11111111, p6/p7 = 7.
- Enrich result Update: p0 = unknown packed value (varies per step, not a checksum we can name), p1 = the atmacite KI id (0x70f = 1807), p2 = new level, p3 = list word containing the new nibble, p4 = remaining cruor.
- Purge option: NOT in any capture. Do not guess it.

## 4. Enrich cost per level [C]

Cost to reach each level (cruor), post-"Rhapsody in Mauve" (wiki: 1/20 of listed cost, and 1841's series sums to exactly 78,750 = 1,575,000/20):

| KI (client) | L2 | L3 | L4 | L5 | L6-L10 | L11 | L12 | L13 | L14 | L15 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1841 | 750 | 1500 | 2250 | 3000 | 3750,4500,5250,6000,6750 | 7500 | 8250 | 9000 | 9750 | 10500 |
| 1810 | 500 | 1000 | 1500 | 2000 | 2500 x5 | 3000 | 3500 | 4000 | 4500 | 5000 |
| 1807 | | | | | | | | | 4500 | 5000 |
| 1835 | L8 10000, L9 10000, L10 12500, L11 12500, L12 15000, L13 15000, L14 17500, L15 17500 (L2-L7 not captured, L7 cost 7500) | | | | | | | | | |

Cost classes are therefore per atmacite. Pre-"Rhapsody" values are x20. The character in the capture had the "Rhapsody in Mauve" reduction active; whether it is a quest flag or a server rule is not known [U].

## 5. What this lets us build / what it does not

Buildable from evidence: p5/p6 gating (done in `voidwatch_officer.lua`), enrich flow (option encoding, message 15721, costs for known classes), infuse flow for level 1 (option, message 15712, 100 cruor).
Not buildable yet: purge, Periapt of emergence slot handling, infuse cost at levels above 1, atmacite KI client ids vs DSP ids, unlocking of warp menu entries by p5/p6, p1 bit 1 and p0 high bits when atmacites are infused (Wiggo p0 = 0x10d9f7e, p2 = 120, p3 = 0x78302; layout differs from stratum-only characters).
