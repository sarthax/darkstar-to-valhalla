# DSP-Valhalla GM Commands Reference

This document catalogs the in-game `!command` scripts in `scripts/commands/`. It was carried over from the Topaz reference (`C:	opaz\documentation\GM_Commands_Reference.md`) on 2026-10-25: sections for Topaz-only commands that DSP does not have were removed, and DSP-only commands are listed in the final sections. Text for shared commands was written against Topaz, so re-check a command's own header in `scripts/commands/` if behavior differs. It is a reference for server administrators/developers, not a player-facing guide.

Each command script defines a `cmdprops` table with a `permission` integer and a `parameters` string, plus an `onTrigger(player, ...)` function. The dispatcher (`src/map/commandhandler.cpp`) checks `permission > PChar->m_GMlevel` and rejects the command if the caller's GM level is lower than the command's required `permission` value — i.e. **higher number = more restricted**. The codebase does not define named tiers anywhere in scripts or source; the numbers seen across these 149 files are 1, 3, 4, and 5, with 1 being by far the most common (ordinary GM commands) and 4-5 reserved for dangerous/testing-only commands (`!exec`, `!time`, `!reloadglobal`, `!breaklinkshell`, `!gc_full`, `!gc_step`). No source discoverable in this codebase maps these numbers to labels like "Trial GM"/"Senior GM"/etc. — treat them strictly as ordinal gate levels for your own server's staff hierarchy.

`parameters` strings describe argument types positionally: `i` = integer, `s` = string (also used loosely for numeric args parsed with `tonumber`), `b` = raw byte blob (used by `!send`/`!zone` for auto-translate parsing). Optional arguments are shown in `{braces}`; required ones in `<angle brackets>`, matching each file's own usage convention where present.

## Table of Contents

- [Player Stats & Progression](#player-stats--progression)
- [Items, Currency & Key Items](#items-currency--key-items)
- [Missions, Quests & Records](#missions-quests--records)
- [Teleportation & Movement](#teleportation--movement)
- [Mob & NPC Spawning / Control](#mob--npc-spawning--control)
- [Visual, Animation & Cosmetic](#visual-animation--cosmetic)
- [Status Effects & Special Modes](#status-effects--special-modes)
- [Server & Zone Administration](#server--zone-administration)
- [Debugging & Diagnostics](#debugging--diagnostics)
- [Linkshells & Social](#linkshells--social)
- [Misc](#misc)

---

## Player Stats & Progression

### !hp
**Syntax:** `!hp <amount> {player}`
**Permission:** 1
**Description:** Sets HP for the GM, a named target, or current cursor target (in that priority). Refuses if the target is currently dead.

### !mp
**Syntax:** `!mp <amount> {player}`
**Permission:** 1
**Description:** Sets MP for the GM, named target, or cursor target. Refuses if the target is dead.

### !tp
**Syntax:** `!tp <amount> {player}`
**Permission:** 1
**Description:** Sets TP for the GM, named target, or cursor target; if the target has a live pet, also sets the pet's TP to the same value.

### !pettp
**Syntax:** `!pettp {amount}`
**Permission:** 1
**Description:** Sets the caller's own pet's TP. Errors if no pet is out.

### !cp
**Syntax:** `!cp <amount>`
**Permission:** 1
**Description:** Adds Capacity Points to the caller only (no target argument).

### !givexp
**Syntax:** `!givexp <amount> {player}`
**Permission:** 1
**Description:** Adds experience points to the GM or a named target and reports their new level.

### !takexp
**Syntax:** `!takexp <amount> {player}`
**Permission:** 1
**Description:** Removes experience points from the GM or a named target.

### !setplayerlevel
**Syntax:** `!setplayerlevel {player} <level>`
**Permission:** 1
**Description:** Sets a player's (main job) level to 1-99. If only one argument is given it's treated as the level for the caller.

### !changejob
**Syntax:** `!changejob <jobID> {level}`
**Permission:** 1
**Description:** Changes the caller's main job (by short name like WAR or numeric ID), optionally also setting level.

### !changesjob
**Syntax:** `!changesjob <jobID> {level}`
**Permission:** 1
**Description:** Same as `!changejob` but affects the caller's sub job.

### !setmerits
**Syntax:** `!setmerits <amount> {player}`
**Permission:** 1
**Description:** Sets a player's total merit point count.

### !capskill
**Syntax:** `!capskill <skillID>`
**Permission:** 1
**Description:** Caps the caller's specified skill at its current level cap.

### !capallskills
**Syntax:** `!capallskills`
**Permission:** 1
**Description:** Caps every skill for the caller at once.

### !addspell
**Syntax:** `!addspell <spellID> {player}`
**Permission:** 1
**Description:** Grants a single spell to the GM or target player.

### !delspell
**Syntax:** `!delspell <spellID> {player}`
**Permission:** 1
**Description:** Removes a single spell from the GM or target player's spell list.

### !addallspells
**Syntax:** `!addallspells {player}`
**Permission:** 1
**Description:** Grants every standard (non-trust) spell in the game to the GM or target.

### !addassaultpoints
**Syntax:** `!addassaultpoints <points> {player}`
**Permission:** 1
**Description:** Adds assault/mercenary rank promotion points (AssaultPromotion charvar) to the GM or target, capped at 25. Used for testing the mercenary rank promotion system at Naja Salaheem without having to run assault missions.

### !resetmercrank
**Syntax:** `!resetmercrank {player}`
**Permission:** 1
**Description:** Resets the GM or target's mercenary rank back to Private Second Class (PSC) by removing all higher-rank wildcat badges (PFC through Captain) and clearing AssaultPromotion/PromotionPFC/PromotionSP/AssaultsCompleted charvars. Used to replay the rank promotion quest chain from scratch during testing.

### !addallmaps
**Syntax:** `!addallmaps {player}`
**Permission:** 1
**Description:** Grants every zone map key item to the GM or target.

### !addallattachments
**Syntax:** `!addallattachments {player}`
**Permission:** 1
**Description:** Unlocks all puppetmaster automaton attachments for the GM or target.

### !setmentor
**Syntax:** `!setmentor <mode> {player}` (mode: 0=not a mentor, 1=unlocked but inactive)
**Permission:** 1
**Description:** Sets a player's mentor unlock state. Note the file's own usage text only documents modes 0 and 1, though `parameters` accepts up to mode 1 per its own validation (2 is documented elsewhere as "unlocked & flag on" in the header comment but rejected by the actual range check).

### !cnation
**Syntax:** `!cnation <player> <campaign allegiance>`
**Permission:** 1
**Description:** Views or sets a player's Campaign nation allegiance (NONE/SANDORIA/BASTOK/WINDURST).

### !setplayernation
**Syntax:** `!setplayernation {player} <nation>` (0=San d'Oria, 1=Bastok, 2=Windurst)
**Permission:** 1
**Description:** Sets a player's home nation.

### !getmod
**Syntax:** `!getmod <modID>`
**Permission:** 3
**Description:** Reports the current value of a modifier on the cursor target (or self if no target). Refuses NPC targets.

### !setgil
**Syntax:** `!setgil <amount>`
**Permission:** 1
**Description:** Sets the caller's own gil total directly (no target argument).

### !givegil
**Syntax:** `!givegil <amount> {player}`
**Permission:** 1
**Description:** Adds gil to the GM or target player.

### !takegil
**Syntax:** `!takegil <amount> {player}`
**Permission:** 1
**Description:** Removes gil from the target (clamped so it can't go negative).

### !addcurrency
**Syntax:** `!addcurrency <currency type> <amount> {player}`
**Permission:** 1
**Description:** Adds an amount of a named currency (e.g. conquest points, cruor, imperial standing) to a target.

### !delcurrency
**Syntax:** `!delcurrency <currency type> <amount> {player}`
**Permission:** 1
**Description:** Removes an amount of a named currency from a target, clamped to not go below zero.

---

## Items, Currency & Key Items

### !additem
**Syntax:** `!additem <itemId> {quantity} {aug1} {v1} {aug2} {v2} {aug3} {v3} {aug4} {v4} {trial}`
**Permission:** 1
**Description:** Adds an item (optionally augmented, optionally a trial item) to the GM's own inventory. Refuses if the GM has no free inventory slots.

### !giveitem
**Syntax:** `!giveitem <player> <itemId> <amount> <aug1> <v1> <aug2> <v2> <aug3> <v3> <aug4> <v4>`
**Permission:** 1
**Description:** Adds an item (optionally augmented) to a named target player's inventory. Refuses if the target has no free space.

### !delitem
**Syntax:** `!delitem <itemID> {player}`
**Permission:** 1
**Description:** Deletes one copy of an item from a target's inventory, searching all inventory/wardrobe locations for it.

### !hasitem
**Syntax:** `!hasitem <itemID> {player}`
**Permission:** 1
**Description:** Reports whether a target has a given item.

### !addtempitem
**Syntax:** `!addtempitem <itemID> <quantity>`
**Permission:** 1
**Description:** Adds a temporary item (event/quest-scoped) to the caller's own inventory.

### !addtreasure
**Syntax:** `!addtreasure <itemID> {player} {npcID}`
**Permission:** 1
**Description:** Adds an item directly into a target's (or their party/alliance's) treasure pool, optionally attributing the drop to a specific NPC/mob.

### !addkeyitem
**Syntax:** `!addkeyitem <key item ID> {player}`
**Permission:** 1
**Description:** Grants a key item (by numeric ID or `keyitems.lua` name) to the GM or target, with the standard key-item-obtained message.

### !delkeyitem
**Syntax:** `!delkeyitem <key item ID> {player}`
**Permission:** 1
**Description:** Removes a key item from the GM or target.

### !haskeyitem
**Syntax:** `!haskeyitem <key item ID> {player}`
**Permission:** 1
**Description:** Reports whether the target has a given key item.

### !salvagedrinks
**Syntax:** `!salvagedrinks [quantity]`
**Permission:** 1
**Description:** Adds one (or N) of each of the 13 real Salvage "Bottle of X's Drink" items (ids 5385-5397) to the caller's inventory, for testing Salvage temp-item bonuses without farming.

---

## Missions, Quests & Records

### !addmission
**Syntax:** `!addmission <logID> <missionID> {player}`
**Permission:** 1
**Description:** Adds (activates) a mission at the given mission log for the GM or target.

### !delmission
**Syntax:** `!delmission <logID> <missionID> {player}`
**Permission:** 1
**Description:** Removes a mission from the target's given mission log.

### !checkmission
**Syntax:** `!checkmission <logID> {player}`
**Permission:** 1
**Description:** Prints the target's currently active mission ID for a given mission log.

### !completemission
**Syntax:** `!completemission <logID> <missionID> {player}`
**Permission:** 1
**Description:** Marks the given mission complete for the target, provided it's currently active in that log.

### !addquest
**Syntax:** `!addquest <logID> <questID> {player}`
**Permission:** 1
**Description:** Adds (accepts) a quest in the given quest log for the target.

### !delquest
**Syntax:** `!delquest <logID> <questID> {player}`
**Permission:** 1
**Description:** Removes a quest from the target's given quest log.

### !checkquest
**Syntax:** `!checkquest <logID> <questID> {player}`
**Permission:** 1
**Description:** Prints a quest's status (AVAILABLE/ACCEPTED/COMPLETED) for the target.

### !completequest
**Syntax:** `!completequest <logID> <questID> {player}`
**Permission:** 1
**Description:** Marks the given quest complete for the target.

### !resetlcquest
**Syntax:** `!resetlcquest {player}`
**Permission:** 1
**Description:** Resets only the Lance Corporal promotion quest state (charvars `PromotionLC`/`LCProg`/`LCOption`/`LCSubmitDay`/`LCZonedBack`/`LCTubesFilled`, strips the LC badge + test tube key items), and sets `AssaultPromotion=25` for immediate re-testing without a full character reset.

---

## Teleportation & Movement

### !pos
**Syntax:** `!pos {x} {y} {z} {zone ID} {player}`
**Permission:** 1
**Description:** With no coordinates given, reports the target's current position. With coordinates, moves the target there (optionally into a different zone). Target and zone arguments are shifted/inferred based on how many arguments are given.

### !goto
**Syntax:** `!goto <player> {forceZone}`
**Permission:** 1
**Description:** Warps the caller to a named player's position, crossing zones by default (`forceZone` defaults to 1). Falls back to a cross-zone-server `gotoPlayer` if the target isn't on the same zone process.

### !gotoinstid
**Syntax:** `!gotoinstid <mobId|npcId>`
**Permission:** 1
**Description:** Like `!gotoid`, but checks the caller's current instance for the entity first before falling back to the global zone lookup — needed for entities (e.g. Assault mission mobs/props) that only exist inside an instance.

### !bring
**Syntax:** `!bring <player> {forceZone}`
**Permission:** 1
**Description:** Warps a named target to the caller's own position, crossing zones by default. Falls back to a cross-zone `bringPlayer` if the target isn't found locally.

### !send
**Syntax:** `!send <player1> <player2 or zone (also accepts an auto-translated zone phrase)>`
**Permission:** 1
**Description:** Teleports one named player to either another named player's position or a specific zone (by numeric ID or in-game auto-translate zone phrase). Parses the raw packet byte blob directly rather than plain string arguments.

### !zone
**Syntax:** `!zone <zone ID or autotranslate phrase>`
**Permission:** 1
**Description:** Teleports the caller to a given zone by numeric ID or auto-translate phrase, to that zone's default entry point (x/y/z default to 0,0,0 unless an override is defined in the zone table).

### !return
**Syntax:** `!return {player}`
**Permission:** 1
**Description:** Warps the GM or target back to their previously recorded zone. Fails if the previous zone was a Mog House or unrecorded.

### !homepoint
**Syntax:** `!homepoint {player}`
**Permission:** 1
**Description:** Sends the GM or target to their set homepoint, same as a Home Point teleport.

### !posfix
**Syntax:** `!posfix <player>`
**Permission:** 1
**Description:** Resets an **offline** player's saved session/position data server-side (used to fix a character stuck due to a bad save) — does not itself move a live player.

### !jail
**Syntax:** `!jail <player> {cellId} {reason}`
**Permission:** 1
**Description:** Teleports a named player into one of 32 jail cells in Mordion Gaol, tags them with an `inJail` charvar, and logs the reason to the server console. No built-in `error()` usage helper is defined for invalid input beyond inline checks.

### !pardon
**Syntax:** `!pardon <player>`
**Permission:** 1
**Description:** Clears a player's jail status and warps them to their homepoint, if they were jailed via `!jail`.

### !speed
**Syntax:** `!speed <0-255>`
**Permission:** 1
**Description:** With no argument, reports the caller's current movement speed and MOVE modifier. With an argument, sets movement speed directly.

### !wallhack
**Syntax:** `!wallhack {player}`
**Permission:** 1
**Description:** Toggles the wallhack nameflag (0x200) on the GM or target, allowing them to walk through walls/geometry.

### !checknav
**Syntax:** `!checknav {x} {y} {z}`
**Permission:** 1
**Description:** Diagnostic tool: checks whether a given coordinate is valid on the current zone's compiled navmesh, and whether a path exists from the caller's current position to it. Used to verify candidate spawn/prop coordinates before committing them to SQL.

### !wa / !warpassault
**Syntax:** `!warpassault <instanceid>` / `!warpassault leave` / `!warpassault list`
**Permission:** 1
**Description:** Debug command that bypasses the Assault officer NPC and runic portal, letting the GM directly enter/exit any of the 50 built Assault mission instances (plus a handful of non-Assault instanced zones) without the normal trigger sequence. `list` prints all known instance IDs and their zones; `leave` properly fails/cleans up the live instance rather than just clearing the assault-log flag. If the GM isn't standing in the mission's own zone, it warps them there first and asks them to re-run the command (zoning is asynchronous, so entry can't be chained in one call). `wa.lua` and `warpassault.lua` are byte-for-byte identical duplicate scripts registering two aliases for the same command.

### !nyzuldebug
**Syntax:** `!nyzuldebug complete` / `!nyzuldebug floor <N>` / `!nyzuldebug reroll` / `!nyzuldebug layout <N>|clear` / `!nyzuldebug leader <name>|clear`
**Permission:** 1
**Description:** Debug command for testing Nyzul Isle Investigation (instance 51) floor objectives/win conditions without climbing 100 floors of random rolls. Must be run while standing inside a live instance (`!warpassault 51`, then enter via the entrance rune, or already be mid-run).
- `complete` -- force-completes the current floor's objective regardless of stage (works for both the "flag" objectives -- Free Floor, Eliminate Enemy Leader, Activate All Lamps, Eliminate Specified Enemy -- and the "counter" ones -- Eliminate All Enemies, Eliminate Specified Enemies), lighting the Rune of Transfer immediately.
- `floor <N>` -- jumps to floor N (1-100) on the next Rune of Transfer "next floor" interaction, by priming `Nyzul_Current_Floor` to N-1 and force-completing the current floor. This is the only way to land on an exact boss floor (20/40/60/80/100) -- the real token-based floor-select menu only offers 5-floor checkpoints (1/6/11.../96).
- `reroll` -- re-rolls the current floor's objective/spawns in place (calls the same real `pickSetPoint` the engine uses on a normal floor transition), without spending a floor transition.
- `layout <N>|clear` -- pins `Nyzul_Isle_FloorLayout` to an exact value (1-16, see `scripts/globals/nyzul.lua`'s `tpz.nyzul.FloorLayout` table) instead of the normal random roll, and applies it immediately. Stays pinned across further rerolls/floor transitions until cleared.
- `leader <name>|clear` -- pins a specific Eliminate Enemy Leader mob (any of the 24 real names in `nyzul_isle_investigation.lua`'s leader pool, e.g. `ginger_custard`, `vanilla_custard`, `mokke`, `shielded_chariot`) instead of the normal random pick, forcing the current floor's stage to Eliminate Enemy Leader and spawning that mob right away. Stays pinned across further rerolls/floor transitions until cleared. Added 2026-09-07 to let the 8 Custard/Flan mobs be tested on demand rather than waiting on a random roll.

### !addnyzultokens
**Syntax:** `!addnyzultokens <points> {player}`
**Permission:** 1
**Description:** Adds Nyzul Isle Assault Points (via `targ:addAssaultPoint()`) to the GM or target, for testing floor-select-menu token thresholds without grinding.

### !nyzulflorlayout
**Syntax:** `!nyzulflorlayout`
**Permission:** 1
**Description:** Displays the current Nyzul Isle floor layout number and current floor for the caller's active instance. Works for both Investigation (instance 51) and Uncharted Area Survey (instance 52), zone 77.

### !astraria
**Syntax:** `!astraria <bronze|silver|mythril|gold|platinum> <set|add|clear|redeem|grant> [N] {player}`
**Permission:** 1
**Description:** GM debug command for the Uncharted Area Survey (instance 52) astraria fragment system, added 2026-09-23. Operates directly on the same `tpz.nyzul.astraria` table (`scripts/globals/nyzul.lua`) that the real boss-kill fragment-gain/redemption logic uses, so tier names and max-fragment counts always stay in sync with production behavior.
- `set <N> {player}` -- sets the tier's fragment char_var directly to N (0 to maxFragments-1).
- `add <N> {player}` -- adds N (may be negative) to the tier's current fragment count, clamped to [0, maxFragments-1].
- `clear {player}` -- resets the tier's fragment char_var to 0.
- `redeem {player}` -- removes the completed key item (if held) and resets the fragment char_var to 0, via `tpz.nyzul.unchartedAstrariaRedeem`.
- `grant {player}` -- force-grants the completed key item directly, bypassing fragment counting entirely (for reward testing).

---

## Mob & NPC Spawning / Control

### !spawnmob
**Syntax:** `!spawnmob <mob ID> {despawntime} {respawntime}`
**Permission:** 1
**Description:** Spawns a mob by its SQL-defined ID, with optional custom despawn/respawn timers.

### !despawnmob
**Syntax:** `!despawnmob {mobID}`
**Permission:** 1
**Description:** Despawns a mob, either by ID or the currently targeted mob.

### !mobhere
**Syntax:** `!mobhere {mobID} {noDepop}`
**Permission:** 1
**Description:** Spawns a mob (or uses the cursor target) and moves it to the caller's current position, but only if the caller is in the same zone the mob belongs to. On failure it despawns the mob again unless any value is passed for `noDepop`.

### !npchere
**Syntax:** `!npchere {npcID} {noDepop}`
**Permission:** 1
**Description:** Same idea as `!mobhere` but for a static NPC — moves it to the caller's position if same-zone, otherwise sets it to DISAPPEAR status unless `noDepop` is passed.

### !getmobaction
**Syntax:** `!getmobaction {mobID}`
**Permission:** 1
**Description:** Prints a mob's current internal action ID (by ID or cursor target).

### !setmobflags
**Syntax:** `!setmobflags <flags> {mob ID}`
**Permission:** 1
**Description:** Sets a mob's nameflags value directly (by ID or cursor target).

### !animatenpc
**Syntax:** `!animatenpc {npcID} <animationID>`
**Permission:** 1
**Description:** Sets an NPC's primary animation ID, either by explicit npcID or the currently cursor-targeted NPC. Testing tool.

### !animatesubnpc
**Syntax:** `!animatesubnpc {npcID} <animationID>`
**Permission:** 1
**Description:** Same as `!animatenpc` but sets the NPC's secondary/sub-animation.

### !mobsub
**Syntax:** `!mobsub {mob ID} <animation ID>`
**Permission:** 1
**Description:** Sets a mob's sub-animation, either by ID or cursor target. Testing tool.

### !npcsub
**Syntax:** `!npcsub {npc ID} <animation ID>`
**Permission:** 1
**Description:** NPC-side counterpart to `!mobsub`, which can't target TYPE_NPC entities. Sets a sub-animation and force-respawns the NPC for a reliable client redraw. Added 2026-09-01.

---

## Visual, Animation & Cosmetic

### !animation
**Syntax:** `!animation {animationID}`
**Permission:** 1
**Description:** With no argument, reports the caller's current animation ID. With an argument, sets it.

### !costume
**Syntax:** `!costume <costumeID>`
**Permission:** 1
**Description:** Puts the caller into a costume model by ID.

### !setplayermodel
**Syntax:** `!setplayermodel <model> <slot> {player}` (slots: 0=main 1=sub 2=ranged 3=ammo 4=head 5=body 6=hands 7=legs 8=feet)
**Permission:** 1
**Description:** Sets a specific equipment-slot model override on the GM or target player, for testing appearance.

### !entityvisual
**Syntax:** `!entityvisual <animation string>`
**Permission:** 1
**Description:** Pushes a raw entityVisual packet to the caller using a hand-built animation string.

### !setmusic
**Syntax:** `!setmusic <type ID> <song ID>` (types: 0=BGM Day, 1=BGM Night, 2=Solo-Battle, 3=Party-Battle, 4=Chocobo, 5=Death, 6=Moghouse, 7=Fishing)
**Permission:** 1
**Description:** Temporarily overrides the music the caller's client plays for a given music channel.

### !setweather
**Syntax:** `!setweather <weather ID>`
**Permission:** 1
**Description:** Sets the current weather in the caller's zone (client-side effect for the caller).

### !fourccanim
**Syntax:** `!fourccanim {npcID} <4-char code>`
**Permission:** 1
**Description:** Fires a raw `CEntityAnimationPacket` (0x038) FourCC animation code (e.g. `"kesu"`, `"open"`) at an NPC, either by explicit npcID or the currently cursor-targeted NPC. Added 2026-08-25 for brute-forcing candidate motion codes, since no server-side lookup table for these exists anywhere in this codebase — the server does zero validation of the string (a straight `memcpy` in `packets/entity_animation.cpp`), so this is a completely safe way to test real vs. fake codes in-game. Testing tool.

---

## Status Effects & Special Modes

### !addeffect
**Syntax:** `!addeffect {player} <effect> {power} {duration} {subid} {subPower}`
**Permission:** 1
**Description:** Adds a status effect (by numeric ID or `tpz.effect` name) to the GM or a named target, with configurable power/duration/sub-values. Note: the internal call to `addStatusEffect` passes an undefined `subid` local (should be `subId`) — likely always applies subId 0 regardless of the `subid` argument parsed from input; flagged as a probable bug, not intentional behavior.

### !deleffect
**Syntax:** `!deleffect {player} <effect>`
**Permission:** 1
**Description:** Removes a status effect (by ID or name) from the GM or target.

### !godmode
**Syntax:** `!godmode`
**Permission:** 1
**Description:** Toggles a large bundle of buffs (max HP/MP boost, Mighty Strikes, Hundred Fists, Chainspell, Perfect Dodge, Invincible, Elemental Sforzo, Manafont, Regain/Refresh/Regen) and stat mods (+2500 to all major accuracy/attack/defense mods) on the caller, plus a full heal. Calling again removes everything. State tracked via the `GodMode` charvar.

### !petgodmode
**Syntax:** `!petgodmode`
**Permission:** 1
**Description:** Same effect bundle as `!godmode` (plus Sentinel) but applied to the caller's current pet instead. Requires an active pet; state tracked via a pet localvar.

### !raise
**Syntax:** `!raise {power} {player}`
**Permission:** 1
**Description:** Sends a raise (Raise/Raise II/Raise III, power 1-3, default 3) to the GM or a dead target. Does nothing if the target isn't dead.

### !reset
**Syntax:** `!reset {player}`
**Permission:** 1
**Description:** Resets all job ability recast timers for the GM or target.

---

## Server & Zone Administration

### !updateconquest
**Syntax:** `!updateconquest <type>` (0=Tally Start, 1=Tally End, 2=Update)
**Permission:** 1
**Description:** Manually triggers a weekly Conquest update step. Requires conquest data to already be modified in the database first.

### !updateservermessage
**Syntax:** `!updateservermessage`
**Permission:** 1
**Description:** Reloads/republishes the server login message after it's been edited elsewhere.

### !reloadglobal
**Syntax:** `!reloadglobal <lua file path> {I_am_sure}`
**Permission:** 4
**Description:** Hot-reloads a single Lua file under `scripts/globals/` without a full server restart. Passing the literal token `I_am_sure` as the second argument allows reloading files outside that directory. Explicitly documented in its own header comment as dangerous — some files (e.g. `player.lua`) can break things if reloaded live.

### !exec
**Syntax:** `!exec <Lua string>`
**Permission:** 4
**Description:** Compiles and executes an arbitrary Lua string in a sandboxed context where `player` (the caller) and `target` (their cursor target) are predefined; the `os` table is nulled out for the duration of execution as a safety measure. Extremely powerful — effectively unrestricted scripting access.

### !promote
**Syntax:** `!promote <player> <level>`
**Permission:** 1
**Description:** Changes a target's GM level, capped to one below the caller's own level; refuses to act on GMs at or above the caller's own tier. Setting level to 0 also strips GodMode buffs, GM nameflags, hidden status, costume, and wallhack from the target — a full GM-privilege teardown.

### !togglegm
**Syntax:** `!togglegm`
**Permission:** 1
**Description:** Toggles the caller's own GM nameflag/icon on or off (does not change actual GM level/permissions, just the visible flag and icon tier shown to others).

### !hide
**Syntax:** `!hide {status}`
**Permission:** 1
**Description:** Toggles GM-hidden mode (invisible to other players). Passing the literal argument `status` instead reports current hidden state without toggling.

### !logoff
**Syntax:** `!logoff {player}`
**Permission:** 1
**Description:** Forcibly logs the GM or a named target player off.

---

## Debugging & Diagnostics

### !getid
**Syntax:** `!getid`
**Permission:** 1
**Description:** Prints the entity ID of whatever the caller currently has selected with their in-game cursor.

### !where
**Syntax:** `!where`
**Permission:** 1
**Description:** Prints the caller's current position/zone via the client's own position display.

### !checklocalvar
**Syntax:** `!checklocalvar <variable name> {'player', 'mob', or 'npc'} {name or ID}`
**Permission:** 1
**Description:** Reads and prints a local variable's value from a player, mob, or NPC target. Instance-aware: if the zone is instanced, resolves mob/NPC IDs through the caller's current instance.

### !setlocalvar
**Syntax:** `!setlocalvar <variable name> <value> {'player', 'mob', or 'npc'} {name or ID}`
**Permission:** 3
**Description:** Sets a local variable's value on a player, mob, or NPC target. Same instance-aware target resolution as `!checklocalvar`.

### !checkvar
**Syntax:** `!checkvar {'server', or player} <variable name>`
**Permission:** 1
**Description:** Reads and prints either a server-wide variable or a player character variable (charvar).

### !setplayervar
**Syntax:** `!setplayervar <player> <variable> <value>`
**Permission:** 1
**Description:** Sets a character variable (charvar) on a named target player.

### !inject
**Syntax:** `!inject <packet>`
**Permission:** 1
**Description:** Injects a raw packet (by file/name reference) into the caller's own connection, for testing packet handling.

### !injectaction
**Syntax:** `!injectaction <action ID> <animation ID> {speceffect} {reaction} {message}`
**Permission:** 1
**Description:** Injects a fully custom action packet on the caller, with defaults for the optional special-effect, reaction, and message fields.

### !messagebasic
**Syntax:** `!messagebasic <message ID> {param1} {param2}`
**Permission:** 1
**Description:** Sends a "basic" system message packet (targeted at the cursor target, or self if none) with up to two numeric parameters — for testing message text/formatting.

### !messagespecial
**Syntax:** `!messagespecial <message ID> {param1} {param2} {param3} {param4} {param5}`
**Permission:** 1
**Description:** Sends a "special" system message packet to the caller with up to five numeric parameters, for testing message text/formatting.

### !logpos
**Syntax:** `!logpos {optional label}`
**Permission:** 1
**Description:** Prints the caller's current position to chat AND to the map-server console as a CSV line (`LOGPOS,label,zone_id,x,y,z`), for quickly building coordinate lists while playing live rather than hand-transcribing `!pos` output.

### !navdebug
**Syntax:** `!navdebug [radius] [namefilter]` / `!navdebug spawn [radius] [modelid]`
**Permission:** 1
**Description:** Lists every NPC in the caller's current instance/zone within `radius` yalms (default 25) with position, distance, facing, and on-navmesh status. `spawn` mode additionally clears the untargetable flag and swaps the model on matching NPCs for visual identification in-client. Added 2026-08-24 as a companion to `!showhelper`.

### !showhelper
**Syntax:** `!showhelper <npcid> [modelid]`
**Permission:** 1
**Description:** Visually verifies a helper-prop entity's real live position: prints its x/y/z/rot, clears its untargetable flag, warps the caller onto its coordinates, and optionally swaps its model. Added 2026-08-24. Does not persist anything or touch SQL — purely a live-verification tool.

### !nyzulnavsweep
**Syntax:** `!nyzulnavsweep`
**Permission:** 1
**Description:** Sweeps every point in `tpz.nyzul.lampSpawnPoints`/`layoutSpawnPoints` (all 17 layouts) against the compiled navmesh, flagging any point that's off-mesh or unreachable from that layout's anchor point. Must be run while standing in the Nyzul_Isle zone (77).

### !setstage
**Syntax:** `!setstage <stage> [progress]`
**Permission:** 1
**Description:** Directly jumps the caller's current instance's stage/progress via `instance:setStage()`/`setProgress()`, skipping normal replay. Does not replicate any door-reveal/spawn side effects a real stage transition would trigger — those must still happen manually or via other debug commands.

### !testmine
**Syntax:** `!testmine`
**Permission:** 1
**Description:** Directly triggers Arrapago Remnants' (zoneid 74) Qiqirn Mine drop sequence via `instance:insertAlly(22)` plus the real ability-timer chain, targeting the caller's cursor target or self, with extensive `[MINE DEBUG]` console logging. Added 2026-09-07.

---

## Linkshells & Social

### !ah
**Syntax:** `!ah`
**Permission:** 1
**Description:** Opens the Auction House menu for the caller from anywhere in the world (normally only available near an AH NPC).

### !cs
**Syntax:** `!cs <csID> {op1} {op2} {op3} {op4} {op5} {op6} {op7} {op8} {texttable}`
**Permission:** 1
**Description:** Starts an arbitrary cutscene/event ID on the caller, with up to 8 numeric options and a text table override.

### !cs2
**Syntax:** `!cs2 <csID> {string1} {string2} {string3} {string4} {op1} {op2} {op3} {op4} {op5} {op6} {op7} {op8}`
**Permission:** 1
**Description:** Variant of `!cs` that also accepts up to 4 string parameters for the event (via `startEventString`), in addition to the 8 numeric options.

### !release
**Syntax:** `!release {name}`
**Permission:** 1
**Description:** Forces the GM or a named target out of their currently active event/cutscene.

### !setflag
**Syntax:** `!setflag <flags> {player}`
**Permission:** 1
**Description:** Sets an arbitrary raw nameflags value on the GM or target. Generic low-level testing tool — `!wallhack` and `!togglegm` are effectively specialized wrappers around the same underlying flag bits.

### !adddynatime
**Syntax:** `!adddynatime <minutes> {player}`
**Permission:** 1
**Description:** Extends a target's currently active Dynamis status-effect duration by the given number of minutes. Requires the target to currently be in Dynamis; uses `effect:setDuration()` and sends a `DYNAMIS_TIME_EXTEND` special message.

---

## DSP-only commands

### !chocobo
**Syntax:** `!chocobo <sub> {a} {b}`
**Permission:** 1
**Description:** Chocobo raising diagnostics and state editing on the caller. `info` dumps the chocobo (age, stage, stats, conditions, walk meetings and wins, raising vars, story key items); `age <days>` moves the birthday back (negative = forward) so the next trainer talk rolls days over; `set <field> <value>` sets any numeric chocobo field (stage, energy, affection, strength, walk_progress, ...); `cond <bit> <0|1>` sets or clears a condition bit (0-13 current, 16+ pending cure); `meet <trainer 1-6> <0-3>` sets a trainer's walk meeting count (5 = rivals); `wins <0-3>` sets the compete win counter; `var <name> {value}` reads or sets a raising char var (lost, whistle, hiding, search, dietmund, egg, genes, ready); `ki <id> <add|del>` adds or removes story key items (837-841, 850, 809); `delete` removes the chocobo.

### !garden
**Syntax:** `!garden <action> <value> <slot>`
**Permission:** 1
**Description:** Mog House flowerpot test command (info, plant, stage, grow, mature, wilt, ready, crystal1/2, strength, dry, examined, results, clean). Must be inside your Mog House. Full list in the file header and `docs/slices/gardening/GM_COMMAND_garden.md`.

### !moghancement
**Syntax:** `!moghancement <action> <keyitemid>`
**Permission:** 1
**Description:** Mog House Moghancement test command: `info`, `set <keyitemid>` (512-563, 2849-2855), `clear`, `recalc`.

### !addlights / !resetlights / !showlights
**Syntax:** `!addlights <light> <amount> <player>` / `!resetlights {player}` / `!showlights`
**Permission:** 1
**Description:** Add, zero, or print a player's Abyssea lights.

### !resetvoidwatch
**Syntax:** `!resetvoidwatch <player>`
**Permission:** 1
**Description:** Resets all Voidwatch officer/refiner progress (Stratum Abyssite key items, voidstones, tier records, stock clock, atmacite levels). Does not touch periapts, atmacite key items or cruor.

### !gotoentity
**Syntax:** `!gotoentity <id> [spawnedOnly]`
**Permission:** 1
**Description:** Warps to a mob/NPC by id, across zones; falls back to its spawn point unless `spawnedOnly` is 1.

### !mobskilldiag
**Syntax:** `!mobskilldiag`
**Permission:** 1
**Description:** Prints the targeted mob's skill-related state (skill list mod, TP-use chance, TP, HP%, job, pool). Pair with `!tp 3000 <t>`.

### !timeoffset
**Syntax:** `!timeoffset <offset>`
**Permission:** 1
**Description:** Sets the custom time offset of the Vana'diel time instance (DSP's counterpart to Topaz `!time`).

### !title
**Syntax:** `!title <title> {player}`
**Permission:** 1
**Description:** Sets a player's title.

### !revision
**Syntax:** `!revision`
**Permission:** 0
**Description:** Sends the Git revision to the player.

### !godmode (file Godmode1.lua)
**Syntax:** `!godmode`
**Permission:** 1
**Description:** DSP's stock god-mode toggle.

## Topaz-only commands (not in DSP)

`!addallmounts`, `!addalltrusts`, `!addallweaponskills`, `!addtitle`, `!addweaponskillpoints`, `!breaklinkshell`, `!completerecord`, `!gc_full`, `!gc_step`, `!getcraftrank`, `!getmobflags`, `!getmobmodel`, `!getskill`, `!givels`, `!gotoid`, `!hastitle`, `!immortal`, `!loadattachment`, `!mount`, `!setallegiance`, `!setcraftrank`, `!setmoblevel`, `!setmobmodel`, `!setmod`, `!setrank`, `!setskill`, `!stats`, `!testanim`, `!time`
