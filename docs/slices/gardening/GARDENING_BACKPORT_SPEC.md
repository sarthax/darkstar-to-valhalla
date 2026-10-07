# Mog House Flowerpot Gardening — Topaz → DSP Backport Spec

Scope: in-Mog-House pot gardening (not the Mog Garden zone). Gap-audit lead L-025.
Source of truth: Topaz `C:\topaz` (working) cross-checked against the LSB snapshot
`D:\Claude\DSP-LSB-Gap-Audit\evidence\lsb_snapshot\server-base\`. Target: `D:\Claude\dsp-master\src\map`.

## 1. What DSP is missing (verified by file search)
- No `CItemFlowerpot` class, no `gardenutils`, no `gardening_results` table.
- No furniture-interact packet (Topaz `CFurnitureInteractPacket`).
- No handlers for client packets 0x0FC (plant/feed), 0x0FD (examine), 0x0FE (harvest), 0x0FF (stop). DSP has 0x0FA/0x0FB (furniture place/remove) only.
- No GARDENING message ids, no `GARDENING_WILT_BONUS` mod (Moghancement hook).
- Present and reusable: `CItemFurniture` (`items/item_furnishing.*`), itemutils furnishing instantiation, inventory/message packets, `vana_time.h` (`getMoonPhase`, `getVanaTime`, `VTIME_DAY`, `VTIME_WEEK`).

## 2. Port list (file-by-file)
| Topaz source | DSP target | Notes |
|---|---|---|
| `items/item_flowerpot.h/.cpp` | same path | Item state in 24-byte `m_extra` (stage, plant, timestamps, feeds, strength, examined/dried flags). Copy as-is; adapt to DSP's `CItem` ctor/`m_extra` access. |
| `utils/gardenutils.h/.cpp` | same path | Use the **LSB** `CalculateResults` (see §3), not Topaz's aura block. `Initialize()` loads `gardening_results`. |
| `packet_system.cpp` 0x0FC–0x0FE (~5765–5990) | DSP `packet_system.cpp`, register next to 0x0FA/0x0FB (~5762) | 0x0FF not yet read — read before porting. |
| `packets/furniture_interact.*` | new | **Layout must be verified** (§4) before writing. |
| `charentity.cpp` L550 `UpdateGardening(this,true)` + L2068 Moghancement → `GARDENING_WILT_BONUS` | DSP charentity / modifiers | Add the mod only if DSP has the Moghancement system; otherwise default 0. |
| `map.cpp` config keys + `gardenutils::Initialize()` (L224) | DSP map.cpp / map.conf | Four strength-calculation config switches. |
| `utils/itemutils.cpp` | DSP itemutils | Instantiate flowerpot class for pot item ids (216–221 range per Topaz `item_furnishing.sql`). |
| `sql/gardening_results.sql` (2444 rows), flowerpot rows in `item_furnishing.sql` | DSP sql/ | User must run the import; SQL edits have no live effect. |

## 3. Known Topaz bug — do NOT copy
Topaz's `CalculateResults` aura block loops `elements[0..7]` for `dominantAura` and uses
`auras[PFurniture->getElement()] += getAura()` (0-based mismatch with the 1-based element enum).
LSB uses `auras[getElement()-1]` and `dominantAura = std::max(auras[elementID], dominantAura)`, with `break`s in the switch.
Port the LSB version. Result key: `uid = (seed<<8)+(e1<<4)+e2`, weighted pick; plant strength random 0–31,
`strength += (100-strength)*(plantStrength/32)`.

## 4. Verification results (2026-10-02)
- **0x0FC (plant/feed)**: layout `u16 pot item @04, u16 seed/crystal item @06, u8 pot slot @08, u8 item slot @09, u8 pot container @0A, u8 item container @0B`. Confirmed by LSB `GP_CLI_COMMAND_MYROOM_PLANT_ADD` (cites atom0s XiPackets) and matches Topaz. Windower `fields.lua` calls 0A-0B "_junk" (`00 00` observed) — that is a Windower labelling gap, the bytes are the container ids (Mog Safe = 1, Safe2 = 2 in Topaz's check).
- **0x0FD (examine) / 0x0FE (harvest/uproot)**: `u16 item @04, u8 slot @06, u8 container @07`. Windower agrees on 04/06; its "_junk"/"value of 1 observed" at 07 is the container (1 = Mog Safe). Consistent with Topaz.
- **0x0FF (dry plant)**: not in Windower. Topaz uses the same 04/06/07 layout. Only Topaz evidence; LSB has `0x0ff_myroom_plant_stop`, check its struct before porting. Topaz handler also derefs `PItem` without a null check — add one.
- **Furniture-interact packet (server 0x0FA)**: Topaz: type 0xFA, size 0x16, `u32 itemID @04`, `u8 slot @0C`, `u8 container @0D`; 0E-0F unknown. Compare with Windower `fields.incoming[0x0FA]` (line 3759) before writing.
- **Messages**: Topaz and LSB independently use standard-message ids 132 (sown), 133 (dried), 134 (harvest), 136 (crystal used) -> client message table, not server-specific. Basic-message ids 256/257/258 (seed sown / crystal none / crystal used) are Topaz-only; confirm against DSP's message_basic.
- **DSP trap**: DSP's `CMessageStandardPacket` is an old form with no `(itemID, messageID)` or `(item, qty, msg)` constructor; those must be added (item/quantity params at the standard 0x09 packet offsets) or the port will not compile. Verify the param layout against Topaz's `message_standard.cpp` rather than guessing.
- Still unverified: pot item ids on DSP's item DB; DSP message_basic ids.

## 5. `gardening_results` vs FFXIclopedia (done 2026-10-02)
Seed ids in the SQL: 1 Fruit, 2 Herb, 3 Grain, 4 Vegetable, 5 Cactus, 6 Tree Cuttings, 7 Tree Saplings, 8 Wildgrass.
Element ids: 1 Ice, 2 Wind, 3 Earth, 4 Lightning, 5 Water, 6 Fire, 7 Dark, 8 Light. Flowering plants use `element1` = crystal, `element2`=0.
Compared by item-name set per single-crystal section (Herb/Grain/Vegetable; Wildgrass not rechecked with correct id).
- The wiki is crowd-sourced and lists many items the SQL lacks (e.g. Herb/none: Carnation, Sobbing Fungus; Grain/Dark: Ginger; Vegetable/none: Lilac). These are **wiki-only candidates**; no weights or quantities are available, so none were added.
- SQL-only entries absent from the wiki: Herb/Ice Sprig of Misareaux Parsley, Herb/Wind Wind Crystal, Herb/Dark Vanilla, Grain/Fire Fire Crystal, Vegetable/Earth Earth Crystal (the wiki shows the Earth Crystal result under a different bucket ordering — section mapping may be off here).
- Wiki section order assumed: None, Ice, Lightning, Fire?, Earth, Wind, Water, Dark, Light — the Fire/Lightning order is inferred from the crystal that appears in each list, not stated. Treat per-crystal mismatches in Fire/Lightning rows with caution.
- Tree/cactus 9×9 grids scraped but headings flattened; not compared.
- Conclusion: SQL is LSB-derived retail data and a superset-ish/different sample of the wiki; **keep as-is**, do not "fix" from the wiki. The wiki can only suggest missing item names, not weights.

## 6. Order of work
1. Verify packets/messages (§4). 2. Port item class + gardenutils + SQL. 3. Handlers + packet. 4. Mod/config. 5. Test in-game: place pot, plant, feed, examine, harvest, wilt.

## 7. Port status (2026-10-02) — code complete, syntax-checked, NOT yet run in-game
Syntax-checked with `cl /Zs` (VS2019, C++17) on: item_flowerpot.cpp, gardenutils.cpp, furniture_interact.cpp, message_standard.cpp, packet_system.cpp, charentity.cpp, map.cpp, itemutils.cpp — zero errors. Full link/build and runtime test not done.

Files in `D:\Claude\dsp-master`:
- NEW `src/map/items/item_flowerpot.*`, `src/map/utils/gardenutils.*`, `src/map/packets/furniture_interact.*`, `sql/gardening_results.sql` (copied unmodified from Topaz, 2444 rows; all 135 result item ids exist in DSP `item_basic`).
- EDITED `packets/message_standard.*` (2 new ctors), `packets/message_basic.h` (MSGBASIC_GARDENING_* = 256/257/258), `packet_system.cpp` (handlers 0x0FC-0x0FF + registration + 0x00C hook), `entities/charentity.cpp` (PostTick -> UpdateGardening while `m_moghouseID != 0`), `map.cpp/.h`, `conf/map_darkstar.conf` (4 garden_* switches, all off), Makefile.in, vcxproj + filters.
- itemutils NOT changed: like Topaz, pots stay plain `CItemFurnishing` and are cast to `CItemFlowerpot` (the class adds no data members, only accessors over `m_extra`).

Deviations from Topaz: LSB aura logic with DSP 0-based elements; `uint16` cumulative weight; day-element conversion fixed; null/ID/type checks added in 0x0FC-0x0FF; empty-result guard (Topaz would deref null).

Still unverified / known gaps:
1. Basic message ids 256-258 are Topaz-only; DSP's client message table is unconfirmed. If "examine" text is wrong/blank, this is the first suspect. Standard ids 132/133/134/136/137 match LSB.
2. DSP `item_furnishing.sql` flowerpot rows have aura 0 / moghancement 0 (Topaz: mog 515, aura 2,1,1,1,2,4). Only matters if `garden_mh_aura_matters` is enabled; not changed (no verified DSP data).
3. No `GARDENING_WILT_BONUS` mod / Moghancement in DSP, so wilt time is fixed at 36 vana days.
4. 0x0FF struct not checked against LSB `0x0ff_myroom_plant_stop`; Wildgrass wiki comparison not rerun.
5. Server 0xFA layout matches Windower incoming 0x0FA (item@04, slot@0C, 0D = container-like).

To apply (user): `py -3 tools\DBtool.py` (or import `sql/gardening_results.sql` directly, it DROP/CREATEs the table), then rebuild the map server and restart it.

## 8. `!garden` GM debug command (2026-10-02) and package
`!garden <action> {value} {slot}` (permission 1) added: `gardenutils::DebugCommand`, Lua binding `CLuaBaseEntity::gardenDebug`, `scripts/commands/garden.lua`. Documented in `mission-packages/mog_house_gardening/docs/GM_COMMAND_garden.md` and `source/documentation/GM_Commands_Reference.md`. Same syntax-only check status as §7. The whole port is packaged in `mission-packages/mog_house_gardening/`.

## 9. In-game test (2026-10-05)
Tested in-game 2026-10-05 via `!garden`: pots and seeds work; crystal feeding through to mature, then harvest, works as expected. Not every pot/seed/crystal combination has been tested.

## 10. Moghancement backport (2026-10-06)
Furniture aura -> one furniture key item -> modifiers. No DB column: `LoadMoghancement` scans held key items at login; `UpdateMoghancement` (packet 0x0FA ItemID==0) sums aura per element, dominant element wins (tie/zero = none), strongest furniture of that element picks the key item, then `ChangeMoghancement` swaps key items + mods.

**Key items (server ids):** 512-519 elements, 520 Experience, 521 Gardening, 522 Desynthesis, 523-531 crafts (Fishing..Cooking, user-confirmed), 532 Conquest, 533 Region, 534 Fishing-item, 535-537 San/Bas/Win Conquest, 538 Money, 539 Campaign, 540 Money II, 541 Skill Gains, 542 Bounty, 544-561 Moglification/Mega crafts, 562 Experience Boost, 563 Capacity Boost, 2849 Poison, 2850 Paralysis, 2852 Silence, 2853 Petrification, 2854 Virus, 2855 Curse. Client names: `ROM/175/35.DAT` (first field of each dmsg entry = server id).
**Mods added:** 862 EXPERIENCE_RETAINED, 863 DESYNTH_SUCCESS, 864 CONQUEST_BONUS, 865 CONQUEST_REGION_BONUS, 866 GILFINDER, 867 CAMPAIGN_BONUS, 868 CAPACITY_BONUS (`modifier.h` + `status.lua`).
**Consumers wired:** EXPERIENCE_RETAINED (death exp loss), GILFINDER (`DistributeGil`, solo + party), CONQUEST_BONUS/REGION (`conquest_system.cpp`), EXP_BONUS and COMBAT/MAGIC_SKILLUP_RATE (already existed).
**GM command:** `!moghancement info|set <id>|clear|recalc` (`scripts/commands/moghancement.lua`, `moghancementDebug` binding).

**Test status:** aura message + key item swap on furnishing confirmed; `!moghancement set 2850/538` mods correct; Gilfinder confirmed in game (~120 -> ~145 gil). Not yet tested: relog persistence, element swap, exp/conquest consumers.

**Gaps / for the Valhalla port**
- Valhalla has desynthesis; it must apply `success += getMod(Mod::DESYNTH_SUCCESS) * 0.01` (Topaz synthutils.cpp:324). DSP master has no desynth code, so the mod has no consumer here.
- Resist values (20) are unverified placeholders; derive from comparable gear if known. Paralysis uses PARALYZERES (Topaz wrongly uses SILENCERES).
- CAMPAIGN_BONUS, CAPACITY_BONUS and the fishing-item chance (534) have no consumers (unused in Topaz too).
- 543, 2851, 2856 have no client text and are unwired. Client has only 6 resists; no Sleep/Death/Mandragora Mania entry. Do not wire DEATHRES (instance KO only).
- Gilfinder uses integer truncation: no bonus below 10 gil base.
- Moogle aura text ("aglow with ... energy", per-city dialog e.g. Bastok Markets 6856-6858, 6963) is NOT wired in DSP or Topaz; needs a capture of the Moogle talk menu (event id, options, strength param: faint 1-50, powerful 51-100, overwhelming 101+). Supplied capture "Misc - Toggle Open Moghouse" does not contain it.
- Only first-floor furniture should count; aura code does not enforce it.

## 11. Mog Safe 2 furnishing bug (2026-10-06)
`SmallPacket0x0FA` (place) and `0x0FB` (remove) hard-coded `WHERE location = 1` when saving the furniture `extra`, so items in Mog Safe 2 (location 9) matched 0 rows: install state and storage buff were never saved/adjusted, and pots in Safe 2 could not be removed. Fixed to use the client's `containerID` (`location = %u`). Pre-existing DSP bug, not gardening/Moghancement; check Valhalla's copy of these handlers for the same hard-coded location.
Follow-ups (same bug class): `charutils.cpp` login loop only added installed-furniture storage for `LOC_MOGSAFE`; now also `LOC_MOGSAFE2`, otherwise removing a Safe 2 piece shrinks inventory below what was granted. `0x0FB` now answers with the item + finish packets when removal is refused (not enough free inventory), so the client releases the Remove prompt instead of staying greyed out.
