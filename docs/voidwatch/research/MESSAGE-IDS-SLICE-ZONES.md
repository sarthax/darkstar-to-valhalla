# Slice-zone message ids + Rift/Pyxis entity ids (fresh pull 2026-10-06)
Pulls: `research/zone_pulls/z101|z193|z104|z190` (mission_toolkit, same session).

## Message ids (verified by text in each zone's dialog.yml)
| Zone | "fiend materializes" | "Final Spectral Alignment" | "attack devastates the fiend" |
|---|---|---|---|
| Ru'Aun 130 | 10799 | 10876 | 10890 |
| East Ronfaure 101 (Sarimanok) | 11090 | 11167 | 11181 |
| Ordelle's Caves 193 (Krabimanjaro) | 7527 | 7604 | 7618 |
| Jugner Forest 104 (Belphoebe) | 12161 | 12238 | 12252 |
| King Ranperre's Tomb 190 (Hahava) | 7395 | 7472 | 7486 |

Spacing is identical in all 5 zones (+77, +91 from "materializes"), so the Ru'Aun block table in
MESSAGE-IDS-RUAUN.md applies as base-relative offsets: zone_id = Ruaun_id - 10799 + zone_materializes.
[V] for the three anchors per zone; the other offsets are [inferred] until spot-checked per zone.
Note East Ronfaure and Jugner also have an unrelated "A monster materializes out of nowhere!" (11041/12073) - do not confuse.

## Rift/Pyxis entity ids: client pull vs live DSP npc_list
| Zone | Client Rift ids / Pyxis ids | DSP npc_list Rift / Pyxis | Match |
|---|---|---|---|
| 101 | 17191577-79 / 80-82 | 17191575-77 / 78-80 | NO (-2) |
| 193 | 17568198-200 / 01-03 | same | yes |
| 104 | 17203939-41 / 42-44 | 17203948-50 / 51-53 | NO (+9) |
| 190 | 17555961-63 / 64-66 | same | yes |

**Finding:** DSP's Rift/Pyxis npc ids in East Ronfaure and Jugner Forest differ from the client's events dat, so
Rift clicks there would not hit the csid 6000+ events. Same offset class as the known id drift. Before building
Sarimanok/Belphoebe, re-key those 12 npc rows (or confirm DSP's client era differs). Ordelle's and Ranperre's are clean.
Also the draft spawn SQL's Planar Rift positions must use whichever npc rows end up correct.

## Ordelle's Caves 193 participant/clearance block (zone base = Ru'Aun - 3272) [V]
7503 too far; 7504 engaged elsewhere; 7505 unconscious; 7506 requirements not met; 7507 "gains clearance... One <voidstone> expended";
7508 clearance, voidstone not expended (spoils subject to limits); 7509 unused voidstone carried over; 7510/7511 ventured too far/status revoked;
7512 returned; 7513-7515 time remaining; 7516 time up; 7517 monster fades; 7520 energy; 7521 resonates; 7522 need KIs; 7523 no reaction;
7524 Rift menu (Nothing / Initiate / View alignment / Examine atmacite / Read up); 7525 Use <KI>? Yes/No; 7526 lacking KI; 7527 materializes.
=> Retail rules visible in text: clearance is PER PLAYER (range/engaged/KO/requirements), voidstone shared by party, players without their own voidstone get limited spoils.
