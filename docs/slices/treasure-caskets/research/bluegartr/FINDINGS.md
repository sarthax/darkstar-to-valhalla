# BlueGartr casket thread: findings digest

Source: https://www.bluegartr.com/threads/104536-Dungeon-Treasure-Casket-Findings (May-Oct 2011, 21 pages, 412 posts).
Files: `posts.json` (raw, `{pg,id,user,date,t}`), `casket_thread.md` (readable). Tag [B]: player reports, not verified data.
Scraped 2026-10-12 through Chrome. No loot data was changed by this digest.

## 1. Zone special items: thread vs `casket_loot.lua`

Every special item reported in the thread is already in our `regionalItems`, so nothing is missing:
Grapevine Cape (Ranguemont), Melaco Mittens (Bostaunieux), Bond Cape (Toraimarai), Prouesse Ring (Zeruhn), Chocobo Torque (King Ranperre's), Field Rope (Dangruf), Numen Staff (Inner Horutoto), Fisher's Torque (Outer Horutoto), Ossa Grip (Eldieme), Field Torque (Gusgen), Cocoon Band (Crawlers' Nest), Fisher's Rope (Maze of Shakhrami), Metasoma Katars (Garlaige), Dagda's Shield (Fei'Yin), Liminus Earring (Gustav), Smithy's Torque (Ifrit's Cauldron), Wizzan Grip (Kuftal), Furtive Grip (Labyrinth of Onzozo), Brachyura Earring (Korroloka), Terminus Earring (Ru'Avitau), Dragonkin Earring (Boyahda), Potestas Bomblet (Upper Delkfutt's), Rancor/Rancorous Mantle (Den of Rancor), Boneworker's Torque (Uggalepih), Tanner's Torque (Quicksand, tentative), Alchemist's Torque (Ve'Lugannon, tentative), Giant's Earring (Lower Delkfutt's).

Open points in the thread:
- Middle Delkfutt's Tower: Rebel Earring only a guess by posters (post 404/406); we added it in v8 on BG-Wiki's say-so.
- Chocobo Rope (Ordelle's Caves): thread had it only as a prediction. Ours: `11767`, matches wiki.
- Post 324-326: JP wiki lists Brachyura Earring (Protect/Shell potency, MP+20), Fateh Grip (Onzozo) and Dragonkin Earring. The Onzozo item conflicts: JP wiki says Fateh Grip, posters and our table say Furtive Grip (post 355). Don't know which is right; our table keeps Furtive Grip.
- Gusgen got Barrage Turbine in the OP. That is an attachment, not the special item.

## 2. Ordinary brown-chest pool (player samples)
All sampled items resolve in `item_basic.sql` and already appear in `casket_loot.lua`: Wivre Hairpin, Coeurl Mantle, Muscle Belt, Jeweled Collar, Tarutaru Sash, Ritter Shield, Antlion Quiver, War Beret/Gloves/Brais, Errant Hat/Cuffs/Slops, Verdun, Heat Capacitor, Power Cooler, Barrage Turbine, Percolator, Vivi-Valve.
The attachment ids already in our pools are the low range `3307-3313`. That answers the earlier BG-Wiki "Any Zone" question: the high ids (`8456+`) are unused here.
Not checked: Dragon Ring, cells, ores, logs and medicines (names are generic), and whether `14301` (Errant Slops) is in only one zone's pool by design.

## 3. Mechanics reported [B]
| Claim | Source posts | Our implementation |
|---|---|---|
| 16 casket instances per zone (from DATs) | 94 | 16 slots per zone: matches |
| Zone box cap about 18, uncollected boxes block new ones | 93, 97, 143 | Slot limit only; no further cap |
| Minimum respawn time per box, longer than mob respawn (15 min idle gives 4-6 boxes, else 1-2) | 183, 349 | Don't know; we have no per-slot cooldown |
| New-zone mobs respawn in 16 min rather than 5 | 390 | Not touched |
| Brown (gold-trim) = locked and permanent items; blue = unlocked temp items; all brown are locked | 123-127 | Matches |
| 5 or 6 guesses, no difference in reward quality | 399-401 | Not modelled (client-side) |
| Base chest rate about 2%, with Casket level 1 about 5% (about 1/15 kills), about 1/80 brown | 172 | `CASKET_DROP_RATE` 10%: not verified |
| Higher chest rate from VT/T than TW/EP mobs ("30% vs 10%") | 221-225 | No mob-level scaling |
| Low-level mobs (Ding Bat, crab) drop brown chests with special items | 44, 64, 144, 200 | Any mob level: matches |
| Mob level does not change the item pool (disputed; medicine tier might scale) | 157, 160, 185, 353 | No level tiers except `itemsHi/itemsLow` |
| Casket Discovery prowess caps at level 5, HP/Attack at 11, Killer at 2 | 311-312 | Prowess 777 wired; table not checked |
| Kupowers (Mystery Boxes) appear to apply in GoV dungeons but not clearly | 128-130, 172-173 | Applied via Kupower statuses |
| Casket rate halved after Signet wore off | 203 | Not modelled |
| Party members both getting a prowess needs staggered kills | 90, 96 | GoV code outside this slice |
| Special items may be only from 5 or 6 guess chests | 357 | Don't know |

## 4. Conflicts and unknowns to decide (none changed)
1. **Drop rate**: `CASKET_DROP_RATE` of 10% looks generous against the thread's reports (about 2% base). Could be a deliberate server choice; confirm with the user.
2. **Respawn cooldown** (post 183/349): a possible server rule, not confirmed by data.
3. **Onzozo special item** Furtive Grip vs Fateh Grip: a check of the client DAT item names would settle it (dat-extractor).
4. Rebel Earring for Middle Delkfutt's remains a guess.

## 5. Not useful for our work
Skill-up ring/earring test results (post 85, 155, 240-255), prowess effect sizes (post 132, 217, 313-319), GoV page XP numbers (169, 282, 323, 356) are unrelated to caskets here. Prowess values may help the GoV slice: Casket 5 / TH 3 / Attack speed 4 / Cure 5 / WS 5 / Killer 2 / HP+Att 11 / Protect-Shell earring +2 per tier (Protect) and +x/256 (Shell).
