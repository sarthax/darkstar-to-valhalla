# Mog House 2F + Remodel + Mog Patio — DSP port handoff

Ported from Topaz/LSB into DSP (`D:\Claude\dsp-master`). User-tested in-game 2026-10-06: 2F unlock, floor change,
remodel and Patio all work. **No per-city-zone edits are needed** — every Mog House runs the single shared
`scripts/zones/Residential_Area/Zone.lua`.

## Contents
| File | Applies to | Notes |
|---|---|---|
| `patches/01-engine-cpp.patch` | `src/map/...` (charentity.h, charutils.cpp, lua_baseentity.cpp, zone_in.cpp, packet_system.cpp) | `git apply`; if drifted, apply by hand using the bit map below |
| `patches/02-sql.patch` | `sql/char_stats.sql`, `sql/item_usable.sql` | Also run the live-DB statements below |
| `patches/03-lua-globals.patch` | `scripts/globals/keyitems.lua`, `settings.lua` | KI 3051 and `ENABLE_MOG_HOUSE_2F` |
| `patches/04-lua-residential-area-zone.patch` | `scripts/zones/Residential_Area/Zone.lua` | **Merge by hand** if your file differs: only the table and the unlock block |
| `new-files/scripts/globals/items/patio_design_plan_document.lua` | copy as-is | Item 6499 grants KI 3051 |
| `reference-Residential_Area-Zone.lua` | reference | Full working Zone.lua from our tree |

## Live DB (editing sql/*.sql alone has no effect)
```sql
ALTER TABLE `char_stats` MODIFY `mhflag` smallint(5) unsigned NOT NULL DEFAULT '0';
INSERT INTO `item_usable` VALUES (6499,'patio_design_plan_document',1,1,117,0,0,0,0,0);
```
Rebuild the map server (C++ changed) and restart it; the DB `mhflag` of a character is overwritten on save if they are logged in.

## `mhflag` bit map (now uint16)
| Bit | Meaning |
|---|---|
| 0x01 / 0x02 / 0x04 / 0x08 / 0x10 | exit-quest flags: San d'Oria / Bastok / Windurst / Jeuno / Aht Urhgan |
| 0x20 | 2F unlocked |
| 0x40 | currently on 2F |
| 0x80, 0x100 | 2F style: 0 San d'Oria, 1 Bastok, 2 Windurst, 3 Patio |

Unlock fires when `(mhflag & 0x07) == 0x07` and `(mhflag & 0x60) == 0` on zoning into the MH in a home-nation city.
Quest setters (read-only verified): Kuu_Mohzolhi (1), Valah_Molkot (2), Ojha_Rhawash (4), Zona_Shodhun (8), Ahkk_Jharcham (16).

## Packet findings
- 0x00A (zone-in): MH model id at +0xAA (u16). 1F = own nation (Windurst `0x0123`); 2F = `0x0267 + style`. +0xA8 = `0x02` on 2F enables the full exit menu.
- 0x05E exit zoneline id `1903324538`: byte 0x16 = town, byte 0x17 = zone. **125 = go to 2F, 126 = go to 1F.** If the server refuses a request it
  MUST still reply (`CMessageSystemPacket(0,0,2)` + `CCSPositionPacket`) or the client hangs on a black screen.
- 0x0CB Kind 5 = Remodel. Param2 615/616/617/618 = San d'Oria/Bastok/Windurst/Patio. Reply is standard message 293. Patio needs KI 3051.
- The "2F requested without it being unlocked" / "remodeling 2F without it unlocked" warnings are intentional cheat-prevention checks, not bugs.

## 2F unlock cutscene ids (the one piece that is client/zone-DAT specific)
Each is the event in that zone's MH Moogle entity containing "…enjoy your new floor, kupo!" (FFXI-EventsDump). Windurst Walls (547) also matches
capture 2021-03-01. They also match LSB's list exactly. **Valhalla must confirm their client matches** (test one zone, e.g. Windurst Walls = 547).

| Zone | Zone id | Event id |
|---|---|---|
| Southern San d'Oria | 230 | 3535 |
| Northern San d'Oria | 231 | 904 |
| Port San d'Oria | 232 | 820 |
| Bastok Mines | 234 | 610 |
| Bastok Markets | 235 | 604 |
| Port Bastok | 236 | 456 |
| Windurst Waters | 238 | 1086 |
| Windurst Walls | 239 | 547 |
| Port Windurst | 240 | 903 |
| Windurst Woods | 241 | 885 |

If the cutscene hangs or is wrong on their client, set `cs = nil` for that entry: the unlock still works silently.

## Test steps
1. Stop server, apply patches, rebuild, run the SQL, start server.
2. Set test char `mhflag = 7` (DB, while logged out), log in, zone into a home-nation MH → unlock CS plays, `mhflag` gains 0x20 + style bits.
3. Use the exit menu → 2F. Remodel NPC menu → each style. Use item 6499 → KI 3051 → Patio remodel becomes available.

## Known gaps / unverified
- Where players obtain item 6499 (Patio design plan document) on Valhalla — no source known; GM-given for now.
- The three nation flag quests (Growing Flowers, A Lady's Heart, Flower Child) were not played through; flags were set by DB.
- Remodel while standing on 2F (rezone path) untested. Safe 2 is not gated on the 0x20 unlock.
- Not committed in dsp-master.

See `TEST_PLAN.md` for the live test checklist.
