# Voidwalker (F-11e) - slice plan

Branch: `feature/voidwalker` (cut from `main`). Status: Batallia Downs pilot written (Lua + SQL), untested in game. Nothing pushed.
Not the same system as Voidwatch (`docs/voidwatch/`): Voidwalker is the older abyssite /heal-to-pop NM hunt.
Overlap with Voidwatch is limited to the no-rebuff pattern and the new-NM checklist.

## LSB source (read only)
`D:\Claude\DSP-LSB-Gap-Audit\evidence\lsb_snapshot\server-base\scripts\`
- `globals/voidwalker.lua` (~600 lines): pop on /heal, hint/direction messages, KI upgrade chain (1/10), 2h / 25y despawn, per-NM mods
- `globals/voidwalkerpos.lua`: ~520 position rows
- `effects/healing.lua`: calls `xi.voidwalker.onHealing`
- `zones/<zone>/mobs/<NM>.lua`: 186 thin wrappers, 37 NM names, 25-26 zones
- `zones/<zone>/IDs.lua`: `VOIDWALKER` mob-id tables + 11 `VOIDWALKER_*` text ids
- `zones/Ru'Lude_Gardens/npcs/Assai_Nybaem.lua`: clear abyssite vendor / discard (event 10120)
- Topaz has nothing.

## Verified 2026-10-16 against the client (Eden535 ROM, ROM/175/35.DAT and Batallia_Downs dialog)
- All 9 abyssite key items exist in the client and their server ids (first field of the entry) match DSP `keyitems.lua`:
  clear 1253, colorful 1254, blue 1255, orange 1256, brown 1257, yellow 1258, purple 1259, black 1260, grey 1590.
  (Client table indexes are 1026-1033 and 1055; those are NOT server ids.)
- The hint/spawn/upgrade/break/despawn messages exist in the client dialog. Batallia_Downs: 11317 no-mob, 11318 too-far, 11319 hint,
  11320 spawn, 11321 despawn, 11322/11323 upgrade 1/2, 11324 break. LSB has these 25 higher (11342..11349), so LSB ids must NOT be copied.
  Despawn also appears at 7729 (LSB 7754, also +25) and 11326/11399, check which one the script path uses.
- Obtained-key-item message already exists in DSP TextIDs (`KEYITEM_OBTAINED`), so LSB's `VOIDWALKER_OBTAIN_KI` can map to it.

## Still missing in DSP (work list)
1. DONE (textids.csv, 25 zones, tool tools/voidwalker_textids.py). Was: re-pull each zone's dialog (`mission_toolkit.py <zone>`), map by TEXT, never by LSB number. 25 zones.
2. NM data: CORRECTION - it IS in LSB `data/zones/*/mobs.yaml` (templates + spawn ids, levels, hp, loot). Convert per zone like `sql/slices/voidwalker/batallia_pilot.sql` (pools copied from the DSP base pool by name, model = LE16 at bytes 2-3, skill_list ids match DSP family ids).
   Sources: BG wiki dump (`wiki_lookup.py`), FFXIclopedia, wikiwiki.jp, FFXIDB drop rates, Discord scrapes, captures.
3. Position set: validate ~520 positions with `!checknav` (Y inverted); drop any that fail.
4. Engine methods the LSB globals call; check each exists in DSP (`hideHP`, `hideName`, `setUntargetable`, `updateClaim`, `AnimationSub()` traps).
5. Mobskill ids used by per-NM scripts (client + DSP `mobskills`), and mods/mixins names mapped to DSP enums (F-07 remap).
6. `/heal` hook: DSP `scripts/effects/healing.lua` plus Assai Nybaem script (npc_list row 17772776, no script).
7. Event 10120 (Assai) csid + startEvent padding verified from client events (`explore_event.py`), not assumed.

## Suggested order
A. Zone text-id table (script it once, emit a CSV zone -> 11 ids).
B. Port `voidwalker.lua`, `/heal` hook, Assai script with one pilot zone (Batallia Downs: Aither etc.).
C. Pilot NM SQL from sources; test pop, hint, upgrade, despawn in game.
D. Roll out remaining zones in batches; Discord scrapes fill NM stats/drops/levels.

## Data needed from scrapes
Per NM: level range, family/pool, HP/skills notes, drops (with TH0 rates), spawn zone list, pop abyssite tier, any behaviour quirks.
