# Heroines' Holdfast (instance 80) - DSP backport: review notes

Status: built + installed into `dsp-master/scripts` (uncommitted). **No SQL applied anywhere. Nothing tested in-game.**
Lua: 90 files, all pass a lupa syntax load. Every entity method used was checked against dsp-master's C++ bindings.

## Apply SQL (dspdb / dspdb_fresh), in this order
instance_list, mob_pools, mob_skills, mob_skill_lists, mob_pool_mods, mob_groups, mob_spawn_points, npc_list, instance_entities
(all in `sql-dsp/`). Verified collision-free against `dspdb_fresh`. Restart map-server afterwards.

## Decisions to review
1. **Dedicated skill lists 1154-1157** (copies of Topaz 334/337/360/1151). Shared DSP lists (used by ~241 other pools) are untouched. Instance 52 instead kept DSP's list versions - inconsistent approach, pick one.
2. **mob_groups remapped 298-327 -> 18196-18225** (global PK in DSP, no name column). Spawn points remapped to match.
3. **17 mob_skills rows copied** so skills resolve (762, 764, 2899-2904, 3198-3201, 3234-3236, 3243, 3244).
4. **Overrides of existing DSP mobskills**: auroral_uppercut, nullifying_dropkick (zone-gated to Nyzul = zone 77, CoP path preserved), shield_bash (same behaviour, text moved out). Originals saved in `D:\Claude\scratch_merge\orig80`. whirling_edge is new.
5. **Naja_Salaheem** npc_list row overlaps the instance-52 package (`INSERT IGNORE`, harmless).
6. Sixth-battle Unsung Heroine gate is INFERRED, not capture-confirmed.
7. csid 300-305 padding left at the verified 8 values; message/text ids are Topaz-derived (+15 vs dialog.yml in Nyzul) and NOT re-verified for DSP.

## Known gaps
- `entity:sendEntityEmote` (cheerleader emotes) is Topaz-only C++: calls now go through guarded `tpz.heroines.emote` (no-op on DSP). `!wa`, `!npcemote` not ported.
- `instance:setTimeLimit` absent in DSP; code already falls back to the HH_BonusMs local var.
- Pre-existing Topaz bug carried over faithfully: `heroines_holdfast.lua` activateRune - the floor-numbered PrintToPlayer call is swallowed by a comment line (dead code, also in archive).
- Converter's "unmapped tpz.heroines.*" warnings are false positives (the file defines that table itself).
- DSP onEventUpdate is dead for csid 95 (Rune timer reposition used instead).

## Layout
archive-topaz-lua (raw), lua-dsp (converted), sql-dsp.

## 2026-10-03 completeness pass (live import done)
- Imported to live `dspdb_fresh` (backup `D:\Claude\archive\dspdb_fresh_pre-HH_2026-10-03.sql`) and appended to `dsp-master\sql\*.sql`
  (INSERT IGNORE): instance_list(80), 28 pools (7030-7057), skills, skill lists, pool mods, 30 groups (18196-18225), 89 spawns, npcs, 200 instance_entities, family mods, spell lists, npc sync. Verified counts: 200/30/28.
- Added: Ovjang spell hooks (fire_v/blizzard_v/aero_v, lua 7616-7618), C++ `sendEntityEmote` (char_emotion + lua_baseentity; syntax-checked with cl /Zs, NOT yet built) -- `cpp-dsp/` holds the touched files (also luautils/packet_system for the OnPlayerEmote hook).
- Needs: map-server restart + rebuild (darkstar.sln) for emotes; until rebuilt, `npc:sendEntityEmote` is nil and cheerleader emotes error/no-op.
- Not ported: `!npcemote` command (optional).
- Still unverified: Topaz-derived dialog ids vs the Valhalla client (#7), Uka_Totlihn flag/speed differences, shared pools 3241/4381 namevis.

## 2026-10-03 dialog-id audit (blocker #7 CLOSED) + Uka
- Fresh same-session pull from the Valhalla client (`C:\ValhallaXI`, zone 77 dialog dat 6497, zone 72 dat 6492): server message id == dialog.yml entry id, shift 0 for zone 77 (ITEM_OBTAINED 6388, KEYITEM 6391, GIL 6389 all match client text).
- All 121 distinct ids 6300-7700 used by the HH Lua (7311, 7435, 7561-7690) exist in the client and the text matches each script's purpose (Lion/Prishe/Heroine lines, Ovjang spell lines 7616-7623, dance 7643-7660, cameo NPC lines 7667-7690). No missing/mismatched ids.
- csids 1, 300-305 (zone 77) and 405/0x195 (zone 72) exist in the client events dat.
- Uka_Totlihn (17093471): capture-override UPDATE (flag 7/speed 40/entityFlags 2201) removed; live + sql use Topaz values flag 0 / speed 50 / entityFlags 0.

## 2026-10-04 in-game test fixes
- Cheerleader-called skills (tiers 1-3) used Topaz skill ids (2891-2896, 1982/1983) that do not exist in DSP mob_skills, so `useMobAbility` silently no-op'd. Remapped by name to DSP ids: Grapeshot 3198, Powder Keg 3200, Walk the Plank 3201, Nullifying Dropkick 3234, Auroral Uppercut 3235, Knuckle Sandwich 3236, Imperial Authority 3243. Tier 4 (2442-2447) and Mumor (2899-2902) ids already exist.
- `t3Engage`: the three linked engage lines (7596/7597/7598) were all spoken by whichever heroine engaged first; each is now spoken by its own heroine (Nashmeira/Mnejing/Ovjang).
- Puppet fixes: Topaz `OnMobAutomatonWeaponSkill` and the puppetutils attachment pre-cache are Topaz-sol cache workarounds. DSP loads scripts on demand (`lua_prepscript`) and its automaton skills all export `onPetAbility`, which `OnPetAbility` already dispatches, so neither is needed. Mnejing is a plain mob (not a pet) and uses `OnMobWeaponSkill`. Mnejing's Provoke/Flashbulb/Disruptor are placeholder enmity-only skills with msg NONE (no captured effect) -- they show no effect by design.
- Uka Totlihn / tier cheerleader NPCs: `tickMumorCalls` and `tickTierCalls` looked the NPC up with `instance:getEntity(id & 0xFFF, TYPE_NPC)`, which returned nil on DSP, so the scheduler returned early and no call/cheer was ever sent. Replaced with `tpz.heroines.findInstanceNpc` (scans `instance:getNpcs()` by full id).

## 2026-10-04 (later) — warp bounce, Mumor revive visual, Mumor MP
- Rune of Transfer bounce: setPos moved from csid 300 onEventFinish to a mid-fade tick (`tpz.heroines.queueWarp/tickPendingWarp`, `WARP_REPOSITION_MS` = 3300, same as Nyzul Investigation). onEventFinish keeps a fallback. Tune live.
- Mumor floor-6 fake death: `MUMOR_DEATH_POSE_BYTE` (globals/heroines_holdfast.lua) sets ANIMATION_DEATH + "ded", restores on revive. Set false if she returns invisible (earlier bug).
- Mumor MP: MOD_REFRESH 25, MOD_CONSERVE_MP 50, MP floor 500 backstop in Mumor.lua. Strengths are first guesses.
