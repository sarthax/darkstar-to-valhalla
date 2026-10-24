# Mog House 2F fix and test write-up (for Valhalla dev)

Branch: `feature/mog-house-2f-patio` (commits `7b63dbeba2`, `2fb0d61200`). Tested in game 2026-10-22 by the owner on a Bastok-native character.

## Problems reported
1. With the 2F prerequisites unset, a player could go to 2F but had no way to leave it.
2. With 2F locked, choosing "Change floors" at the Mog House door left the door with no exit menu at all.
3. Question: can "Change floors" be hidden or greyed while 2F is locked?

## Root causes
- **No exit on 2F:** the zone-in packet's exit set (`0x00A` +0xAE) comes from `GetMogHouseFlag`, which reads the exit-quest bits (0x01 SDO, 0x02 BAS, 0x04 WIN, 0x08 Jeuno, 0x10 Aht Urhgan) of `char_stats.mhflag`. A character on 2F with those bits clear (e.g. GM-set 0x20|0x40) got 0 = no exits.
- **Dead door:** the client closes its exit menu as soon as a floor is chosen and waits for a rezone. The old refusal path sent a message plus position packet, which left it with no menu. A refused floor request must instead rezone.

## Fixes
- `src/map/packets/zone_in.cpp`: while on 2F (bit 0x40) the exit bits are treated as set, so the menu is never empty.
- `src/map/packet_system.cpp` `SmallPacket0x05E`: a floor request while 2F is locked (bit 0x20 clear) now sets `loc.destination = current zone` and zeroes the position, so the client rezones into the same 1F with a working door menu. mhflag is unchanged.
- `zone_in.cpp`: +0xA8 now follows retail captures (see below).

## Packet findings (from retail captures, not guesses)
| `0x00A` field | Meaning |
|---|---|
| +0x80 | 1 = Mog House |
| +0xA8 | 0x00 fresh char; 0x30 once an exit quest is done; 0x38 when all three are done; \|0x02 on 2F |
| +0xAA/AB | model: home 0x0121/22/23 (SDO/BAS/WIN), non-home 0x0101/02/20, 2F = 0x0267 + style |
| +0xAE | exit set: 1 SDO, 2 BAS, 3 WIN, 4 Jeuno, 5 Aht Urhgan |

- `0x05E` zoneLine 1903324538 is the Mog House exit line: zone byte 125 = up to 2F, 126 = down to 1F.
- Retail captures used: "SandOria - Growing Flowers + Mog House 2F - Mog Safe 2 Access" and "Misc - New Character Moghouse Cutscenes".

## Result on the grey option
"Change floors" is greyed by the client in a **non-home-nation** Mog House (the model is 0x0101 etc.). In the home house it stays enabled even when 2F is locked; no +0xA8 value (0x00/0x01/0x02/0x30/0x38) changed that, and we have no retail locked-home capture. We accept enabled-but-refused (returns to 1F). Open item: capture a retail character with the three quests incomplete in their home Mog House.

## Test matrix (all manual, owner in game)
| mhflag | Observed |
|---|---|
| 0 | stock menu, no CS |
| 2 | full Bastok exit set works |
| 3 | SDO greyed; Bastok enabled -> refused to 1F; Windurst stock |
| 5 | Bastok stock; WIN and SDO greyed |
| 6 | Bastok enabled -> refused; WIN greyed; SDO stock |
| 7 | CS only in home city; 2F travel and exits on both floors work |

Gotchas: stop the map server before editing `mhflag` (it overwrites on save); the unlock fires only when zoning into a home-nation Mog House with `(mhflag & 7) == 7` and 0x20 clear.

## Reproduction
Scenario draft: `data/testing/domain_drafts/mog_house_2f.json` (cases MH2F-01..10) in the Mission Toolkit; coverage doc `docs/workbench/SCENARIO_COVERAGE_mog_house_2f.md`. Not yet executable by a runner.
