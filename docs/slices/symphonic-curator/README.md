# Symphonic Curator (Mog House) — DSP port handoff

Ported from LSB into DSP (`D:\Claude\dsp-master`). User-tested in-game 2026-10-06 on Port Bastok: Curator appears, menu opens,
music previews/plays, Cancel restores. The NPC name is kept as `SymphonicCurat` (nameplate "Symphonic Curator"); in the client
the Curator is the "???" near the Mog House door (left of the entrance, 2.0 / -1.0 / -7.5, look face 0x37).

## Contents
| File | Applies to | Notes |
|---|---|---|
| `patches/01-engine-cpp.patch` | `src/map/lua/lua_baseentity.{cpp,h}`, `src/map/packets/entity_update.cpp`, `src/map/zone_entities.cpp` | `git apply`; adds `isFurnitureInstalled`, Curator spawn, name-in-spawn packet, 0x067 follow-up packet |
| `new-files/scripts/globals/symphonic_curator.lua` | copy as-is | trigger/update/finish, option->song table, key item bit packing |
| `new-files/scripts/zones/<Zone>/npcs/SymphonicCurat.lua` x10 | copy as-is | thin wrappers; script lookup is by npc_list `name` |

No SQL needed: the 10 `SymphonicCurat` rows already exist in `sql/npc_list.sql`. Rebuild the map server after applying the patch.

## Behavior
- **Spawn gate:** the Curator is sent to the player only when an **Orchestrion (item 426)** is *installed* (`m_extra[1] & 0x40`) in Mog Safe 1 or 2. This matches LSB `isOrchestrionPlaced`. A Spinet or Nanaa statue alone does NOT show it (user-confirmed: Spinet alone = no Curator; Spinet + Orchestrion = Curator; removing the Orchestrion removes it after a re-zone).
- **Instruments in the menu:** bitmask param (0 bit = shown, 1 = hidden), shown only while installed in either Mog Safe: bit0 Orchestrion 426, bit1 Spinet 3677, bit2 Nanaa Mihgo Statue 286, bit3 Nanaa Mihgo Statue II 287. Not verified in-game beyond the Orchestrion; check the Spinet/statue entries with a non-GM character.
- **Song packs:** bitmask param, bit0 always on (Mog House 126 / Vana'diel March 108); other bits follow the key items below. There is no GM override (an early version unlocked everything for GMs; removed).
- **Event:** csid `30034` (the Curator's own event in each home-city MH, from FFXI-EventsDump). Call: `player:startEvent(30034, 0, 0xFFFF, songPacks, instruments)` (LSB layout). **Not compared with a retail capture** — retail params looked like `<time>, 4095, 1, -2, <current song>, 0, 1, <selected>`; if a client misbehaves, test that layout.
- **Music slot:** `player:ChangeMusic(6, song)` (6 = Mog House). The current song is kept in `player:setLocalVar("Symphonic_Curator_Music")`; Cancel (option 0) restores it.
- **Instrument installed while inside:** may require a re-zone (the spawn is evaluated in `SpawnMoogle` at zone-in).

## Key items (DSP `scripts/globals/keyitems.lua`, same numbers as LSB) -> pack bit
| Bit | Key item | KI id | Wired |
|---|---|---|---|
| 1 | SHEET_OF_SAN_DORIAN_TUNES | 2152 | yes |
| 2 | SHEET_OF_BASTOKAN_TUNES | 2153 | yes |
| 3 | SHEET_OF_WINDURSTIAN_TUNES | 2154 | yes |
| 4 | SHEET_OF_E_ADOULINIAN_TUNES | 2341 | yes |
| 5 | SHEET_OF_W_ADOULINIAN_TUNES | 2342 | yes |
| 6 | SHEET_OF_ZILART_TUNES | 2564 | yes |
| 7 | SHEET_OF_CONFLICT_TUNES | 2790 | yes |
| 8 | SHEET_OF_PROMATHIA_TUNES | 2791 | yes |
| 9 | SHEET_OF_ADOULINIAN_TUNES | 2792 | yes |

Not wired (no key item id in DSP `keyitems.lua`; LSB ids shown for reference only — **do not use without verifying against Valhalla's client**): Shadow Lord 3136, Mapitoto 3191, Al'Taieu 3226, Jeuno 3227, Harvest 3228, Ancient 3268, Ancient Battle 3329, Destiny Destroyer 3330, Character Selection 3331, Starlight 3332, Chocobo 3344 (plus Near East / Divine / Fishing in LSB's item scripts).

## Sheet-of-tunes ITEM ids (items that grant the key item)
- DSP `item_basic.sql` has only these, all **unimplemented** (`item_usable` marks them `-- TODO: Not implemented`, no item lua): 6347 sheet_of_promathian_tunes, 6348 sheet_of_adoulinian_tunes, 6456 sheet_of_shadow_lord_tunes.
- LSB has working ones (item_usable animation 117 plus `scripts/items/sheet_of_*_tunes.lua` calling `npcUtil.giveKeyItem`): 6690 starlight, 6691 mapitoto, 6696 near_east, 6704 divine; 6707 fishing (TODO there). None of these five are in DSP `item_basic`.
- The San d'Oria / Bastok / Windurst / Zilart / Conflict / Adoulinian E/W key items have no known item id here; they are obtained through quests/events that were not ported.
- For testing use `!addkeyitem 2152` etc.

## NPC rows (all already in `sql/npc_list.sql`; id -> zone)
17719442 Southern San d'Oria (230), 17723535 Northern San d'Oria (231), 17727584 Port San d'Oria (232), 17735775 Bastok Mines (234), 17739878 Bastok Markets (235), 17743983 Port Bastok (236), 17752229 Windurst Waters (238), 17756273 Windurst Walls (239), 17760411 Port Windurst (240), 17764549 Windurst Woods (241). The Moogle in each is id-5, z=1.5, face 0x52.

## Packet findings (retail capture `Misc - Orchestrion Synth + Install + Testing.zip`)
- Curator spawn = 0x00E, size **0x24**, update mask 0x0F, **NPC name written at 0x34** (retail includes it in the spawn).
- After each Mog House NPC spawn retail sends **0x067** (size byte 0x0C; [04]=0x03, [05]=0x05, [06..07]=targid, [08..0B]=id). Implemented as `CMogNpcSetPacket` in `zone_entities.cpp`. Whether it is strictly required was never tested in isolation.
- The 0x18 `flag` word (ours 0x8001, retail 0x800E) and speed (0x28 vs 0x32) differ; changing the DB flag had no effect and was reverted.
- Spawn = status NORMAL + `CEntityUpdatePacket(ENTITY_SPAWN, UPDATE_ALL_MOB)` then status back to DISAPPEAR, from the 0x14 branch via `SpawnMoogle`.

## Gotchas
- `require`d globals (`symphonic_curator.lua`) are cached until a server restart.
- An event started by a GM command dispatches `onEventUpdate/Finish` to `Zone.lua`, not the Curator script (m_event.Script); don't test the update path with a command.
- Do not widen the spawn gate to Spinet/statues: tested, the client does not show the Curator for them.

## Known gaps / unverified
- The option -> song table (`SYMPHONIC_CURATOR_SONGS`) is copied from LSB and unverified against Valhalla's client; later sheet key items are not wired; no item scripts for the DSP sheet items.
- Instrument menu bits for the Spinet/statues, and the non-GM view, are untested (the test character is a GM; the override was removed but not retested on a non-GM character).
- The event param layout is LSB's, not retail's.
- Not committed in dsp-master.

See `TEST_PLAN.md` for the live test checklist.
