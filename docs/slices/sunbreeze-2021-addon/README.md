# Sunbreeze 2021 add-on (skeleton) — Superheroine Stage Show

Optional, default OFF, self-contained. Gate: `isSunbreeze2021AddonEnabled()` (`SUNBREEZE_2021_ADDON` in settings, see `settings_snippet.lua`).

## What exists
- `scripts/globals/events/sunbreeze_2021_addon.lua`: gate, per-zone text offset table, a 66-beat fixed-timing show timeline from capture 479 (client dialog ids, text-verified), `startShow()` that speaks each line via `npc:timer` + `p:showText`.
- `sql/stage_show_npcs_windurst_walls.sql`: template only (ids to be allocated by the server devs).

## Before enabling
1. **In-game text test (required):** with the module loaded, call `SUNBREEZE2021.say(npc, 239, 10016)` and confirm Mumor says "Hello, faithful fans! Mighty Maiden Mumor here!". If wrong, fix `TEXT_OFFSET[239]`.
2. Allocate NPC ids and add rows (template). Verify coordinates with `!checknav`.
3. Add a trigger that calls `SUNBREEZE2021.startShow(239, cast)`; none exists yet (no schedule/NPC onTrigger written).

## Missing pieces (not built, no data invented)
- Player cheer/clap/dance input: DSP's `SmallPacket0x05D` only rebroadcasts emotes; an `onEmote(player, emoteId, target)` C++ hook is needed (check whether Valhalla already has one).
- Sync tiers (0x02A message with param1 0-3) and bond meter; reward logic (Goshikitege/Agent set/Trust Mumor II); Mumor animations/skills (see `Mumor_Ullegore_Skill_Mapping.md`).
- San d'Oria and Bastok: text offsets not measured, so those zones are disabled in the table.

## Emote input (added)
`SUNBREEZE2021.onEmote(player, emoteId)` follows Topaz's Wake the Puppet pattern. Call `registerMumor(zoneId, npc)` when the show starts.
- **Topaz**: add `SUNBREEZE2021.onEmote(player, emoteId)` to `tpz.player.onPlayerEmote` (scripts/globals/player.lua).
- **DSP/Valhalla**: needs an engine patch + rebuild. In `src/map/packet_system.cpp` (~2663-2671, the 0x05D handler) after the rebroadcast, call a new `luautils::OnPlayerEmote(PChar, emoteId)` that invokes a Lua `onPlayerEmote(player, emoteId)` dispatcher (model: Topaz luautils.cpp ~4380).
- Emote ids from Topaz char_emotion.h (WAVE 8, CHEER 12, CLAP 13, DANCE1-4 = 65-68); DSP's emote numbering is NOT verified to match.
- PLACEHOLDERS (not from captures): accolade count, dance window, tier cutoffs, ranges. Sync-tier message and bond meter unwired. Lua untested (no interpreter).

## Questions for Valhalla devs
1. Can they accept an `OnPlayerEmote` Lua hook (C++ patch)? 2. Seasonal flag convention? 3. NPC/mob id ranges in use in Windurst Walls / N. San d'Oria / Bastok Markets? 4. Is there an existing stage show? 5. Qu'Bia Arena battlefield id for the Encore? 6. Trust template (pet-like lua)?

## Engine patch (DSP/Valhalla) — `engine_patch/dsp_emote_hook.patch`
Backport of Topaz's emote hook (packet_system.cpp 0x05D -> luautils::OnPlayerEmote -> player.lua). Dry-run applied cleanly (`patch -p1`) against dsp-fresh; NOT compiled. Adds `luautils::OnPlayerEmote(PChar, uint8)` (DSP prepFile/lua_pcall style, mirroring OnPlayerLevelDown), the call after the emote rebroadcast, and a global `onPlayerEmote` in scripts/globals/player.lua that pcall-requires this add-on. Topaz's 2 s emote rate limit is NOT ported (DSP has none; add if Valhalla wants it). Without the patch the add-on's emote path is inert.

## Sync tier / bond decode (captures 441, 0x02A packets, message id = dialog + 9)
- Sync message = dialog 10104 (capture id 10113), param1 = tier 0-3 (4 variants of the text). Sent per matching player.
- Phase 1 tiers: always 0. Firesday dances: 0,1,2,3 on four consecutive matches in both captures -> tier = match streak (reset on miss is inferred).
- Dialog 10103 (capture 10112, "overflowing with trust" family) appears instead of 10104 in the Trust II capture's Firesday window, with param4 = 4000; what selects it and what 4000 means are NOT decoded. `bondVariant` flag left off.
- No captured packet exposes an accolade/energy meter: accolade thresholds stay placeholders. The fireworks bonus message (dialog 10105) arrives as packet 0x043 with the name "Mumor" — not implemented.
- Rewards seen: Perfect run -> Agent hood/coat/cuffs/pants/boots set; Trust II run -> "You learned Trust: Mumor II!"; non-perfect -> 30 Goshikitenge / Cipher of Mumor's alter ego. Item ids not resolved yet (use id_bridge).

## Rewards
`SUNBREEZE2021.giveAgentSet(player, zoneId, textIds)` gives the Agent set (25606, 26974, 27111, 27296, 27467; valid in Valhalla's db) to players who reached sync tier 3 in Firesday (inferred "perfect"), skips pieces the player already holds (RaEx), requires free slots only for the missing ones, one set per run. Call it from the Moogle's onTrigger. Not wired: Trust Mumor II, 30 Goshikitenge / Cipher of Mumor's alter ego (ids unresolved), Moogle dialog text ids.
