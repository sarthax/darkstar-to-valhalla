-----------------------------------
-- Area: Periqia (Shooting Down the Baron)
--  Mob: Black Baron
-----------------------------------
-- Single kill-target boss (retail objective: "Eliminate the Black Baron"). The 5 Periqia Pugil
-- spawned alongside him are obstacles, not tracked here.
-- 2026-08-19: this file's own header comment used to call out "progress-on-despawn" as the
-- pattern to match, but that pattern is exactly the bug fixed elsewhere this session (onMobDespawn
-- fires on ANY despawn, including a leash, not just a real kill). Moved to onMobDeath gated on a
-- real killer, plus MOBMOD_NO_DESPAWN so the Baron can't leash away uncounted -- matching
-- Sagelord_Molaal_Ja.lua/Broken_Troll_Soldier.lua/Frozen_Bones.lua/Gelid_Bhoot.lua.
-- 2026-08-23: added the real warp mechanic (user-provided wiki writeup, cross-checked against a
-- real Thris Nov2025 capture's HP%/position history -- "Periqia LC" turned out to be a duplicate
-- of the same capture session, not a second independent source). Confirmed in that capture: 2
-- warps during the fight, both a sudden large position jump (52-116 yalms) with no HP regen across
-- the jump and no player-initiated event immediately before it -- matches the wiki's "warps every
-- 15% or so, disappears/reappears unclaimed, does not regen HP" exactly. The capture's exact warp
-- timing doesn't cleanly divide into even 15% steps (first warp happened almost immediately, ~99%
-- HP; second around ~30%) -- consistent with the wiki's own "or so" hedge, not treated as a
-- precise threshold. WARP_INTERVAL below is a reasonable approximation of "every ~15%", not a
-- capture-exact value.
-- 2026-08-23, cross-confirmed by a genuinely independent 2nd capture (Giichi, different capturer/
-- session, downloaded from the Discord archive): real spawn position (-207.777,-16.162,-144.718),
-- and a real HP figure from HP Track -- "Killed 17006658 (Black Baron): 2180~16215HP, Est.HP:
-- 13618". This 2nd capture's fight was a single-round BST WS kill, too fast to observe a warp --
-- doesn't contradict the mechanic, just never triggered it.
-- 2026-08-23, further cross-confirmed by a 3rd independent capture (Siknawz, also from the
-- Discord archive): another real spawn position (-252.279,-5.964,17.985), and a much tighter HP
-- figure -- "Killed 17006658 (Black Baron): 14206~14341HP" -- overlapping the 2nd capture's looser
-- range around ~14000-14300. `mob_groups` now uses 14270 (midpoint of this tighter range).
-- Real text confirmation of "spams amnesia": "Black Baron Abrasive Tantara -> Siknawz (amnesia)".
-- This 3rd capture's fight ran ~3 minutes (long enough a warp could plausibly have happened) but
-- this capture format only logs a single position snapshot per NPC, not a delta history like the
-- Thris capture -- no way to directly confirm or rule out a warp here either way.
-- Warp destinations: the wiki says "he can spawn anywhere on the map" -- no real data exists for
-- the full space of valid points, so rather than fabricate coordinates (risking an off-navmesh
-- warp), WARP_POINTS below uses 6 real, independently-observed positions as a small, data-grounded
-- pool -- flagged as an approximation of "anywhere", not the real range: the Thris capture's own
-- spawn point plus its 2 real warp destinations, the Giichi and Siknawz captures' own spawn
-- points, plus `mob_spawn_points.sql`'s existing default spawn position for this npcid
-- (`-248.371,-3.731,12.415`, itself commented "random but encountered @ the following position" --
-- a real, separately-observed sample, left as this mob's static default spawn rather than
-- overwritten). 4 independent real samples landing in different parts of the map is itself good
-- supporting evidence for the wiki's "spawns anywhere" claim.
-----------------------------------
local WARP_POINTS =
{
    -- Real, from actual Black Baron captures (Thris/Giichi/Siknawz + mob_spawn_points.sql default).
    { -310.905, -13.787,  -98.837 },
    { -219.000,  -5.378,  -30.000 },
    { -198.972,  -8.147,   20.571 },
    { -248.371,  -3.731,   12.415 },
    { -207.777, -16.162, -144.718 },
    { -252.279,  -5.964,   17.985 },
    -- 2026-08-24 REMOVED: the "improvised" block that used to sit here (6 points borrowed from
    -- Seagull Grounded/Excaliace's route data, same zoneid 56 but a different mission's territory)
    -- was confirmed live as the source of a real bug -- the Baron warped to
    -- (-419.9437,-15.8397,49.3929), right next to one of those borrowed points, landing him well
    -- outside this mission's own playable area. Removed entirely rather than left as a trap for a
    -- future warp roll. See Black_Baron.lua's git history (2026-08-23 commit) for the original
    -- 6-point block if it's ever worth revisiting with real per-instance !checknav verification.
    -- 2026-08-23, real -- user live-walked these directly inside this mission's own instance via
    -- !logpos, so unlike the improvised block above, these are individually navmesh-confirmed for
    -- Shooting Down the Baron specifically, not borrowed from a different mission's instance.
    { -340.3518, -15.3159,   56.8760 },
    { -139.9854, -15.1657,   56.3777 },
    { -142.3751, -15.3514, -140.4670 },
    { -341.5163, -15.2990, -136.3085 },
    { -296.5429, -15.2502,  -15.3825 },
    { -299.7343, -15.6928,  -83.8255 },
    { -207.0763, -15.7590, -138.7586 },
    { -183.6538, -15.9742,    8.0313 },
    { -272.9188, -15.7105,   59.3329 },
    { -142.6781, -15.2655,  -56.7389 },
}

local WARP_INTERVAL = 15
-- 2026-08-24: widened + added a pulse, per user feedback that the old single kesu -> 1000ms ->
-- teleport+deru sequence read as an instant, jarring disappear rather than a telegraphed warp.
-- Root cause of why this can't just hide the model outright (setStatus(DISAPPEAR)/(NORMAL), like
-- Armoury_Crate.lua's NPC door props do) is now confirmed, not just "reverted after a live
-- regression, unconfirmed why" as before: CBattleEntity::isDead() (src/map/entities/
-- battleentity.cpp:94-97) treats status==DISAPPEAR as literally DEAD for anything that's a
-- CBattleEntity (mobs included) -- NPCs aren't CBattleEntity, so Armoury_Crate's own use of the
-- same toggle is safe, but doing it to a live mob gets it flagged dead to the whole combat/AI
-- system, and flipping status back to NORMAL afterward doesn't undo whatever the AI controller
-- does in response (most likely edges toward a death/despawn state that isn't reversible by a bare
-- status flip) -- exactly matching the "vanished permanently, no crash/error" regression reported
-- last time. No other mob script in this codebase uses kesu/deru + DISAPPEAR/NORMAL -- only NPCs
-- do -- confirming this isn't a one-off mistake, it's a real engine constraint for anything with
-- HP/combat state. No portal/warp-specific VFX exists elsewhere in this codebase to borrow either
-- (the only other slrg/klrg usage found, Inner_Horutoto_Ruins/npcs/_5c8.lua, is a static door
-- prop's open/close animation, not something meaningful on a boss's own model). kesu/deru (real,
-- already firing, proven safe on its own) is genuinely the best available option -- the fix here is
-- making that existing sequence actually readable as a warp instead of a near-instant blink.
local WARP_TELEGRAPH_DELAY_MS = 800 -- gap between the first kesu pulse and the second
local WARP_ANIM_DELAY_MS = 2200 -- gap between the second (final) kesu pulse and the actual teleport+deru -- not capture-confirmed for the real warp's timing (see onMobFight comment below), lengthened from the old 1000ms purely to give the animation room to read as intentional

-- 2026-08-24: brief damage immunity added for the kesu-pulse telegraph window (see
-- WARP_TELEGRAPH_DELAY_MS/WARP_ANIM_DELAY_MS above, ~3s total), reusing the same real engine
-- mechanism just applied to Sagelord Molaal Ja's own Warm-Up/flee/Warp-cast windows -- see that
-- file's `setInvincible()` header comment for the full explanation of why `Mod.UDMGPHYS/
-- UDMGMAGIC/UDMGRANGE` (true, uncapped 0-damage, not an HP-floor patch) was used over reusing the
-- built-in EFFECT_INVINCIBLE status (physical-only) or an HP-floor timer.
-- NOTE this is a smaller-stakes fix than Sagelord's: unlike Sagelord Elimination (escape IS the
-- win condition, killing him during the vulnerable window was a wrong-outcome bug), Black Baron's
-- `onMobDeath` already counts ANY death as mission success regardless of when it happens, so
-- dying exactly mid-telegraph was never actually broken here. This purely matches the wiki's
-- "does not regen HP... escapes unclaimed" flavor more precisely (he shouldn't die exactly at the
-- instant he's supposed to be teleporting away), not a completion-logic fix.
local function setInvincible(mob, on)
    local value = on and -100 or 0
    mob:setMod(MOD_UDMGPHYS, value)
    mob:setMod(MOD_UDMGMAGIC, value)
    mob:setMod(MOD_UDMGRANGE, value)
end

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
    mob:setLocalVar("lastWarpHpp", 100)
    setInvincible(mob, false) -- hygiene reset on a fresh spawn/respawn

    -- 2026-08-30 user-directed: excluded from Wide Scan, name/target/attack stay normal -- real
    -- C++ addition (src/map/entities/baseentity.cpp's isWideScannable()), same mechanism first
    -- built for Shanarha Grass Conservation's Coney. mob_pools' own namevis (2) doesn't set
    -- FLAG_HIDE_NAME/FLAG_UNTARGETABLE, so no SQL change needed here -- this localVar is the only
    -- thing gating widescan specifically.
    mob:setLocalVar("wideScanHidden", 1)
end

function onMobFight(mob, target)
    local hpp = mob:getHPP()
    local lastWarpHpp = mob:getLocalVar("lastWarpHpp")

    -- 2026-08-23, user-reported crash: warping (disengage()/setPos()) directly inside onMobFight
    -- is called mid-tick from CMobController::DoCombatTick() (mob_controller.cpp:531), while that
    -- same AI combat state is still executing -- disengage() mutates/tears down that state stack
    -- out from under itself, a reentrancy bug that crashed the server at ~86% HP. Fixed by
    -- deferring the actual warp to the next tick via mob:timer(), the same established pattern
    -- Tuchulcha.lua already uses for its own mid-fight warp/disengage.
    if lastWarpHpp - hpp >= WARP_INTERVAL then
        mob:setLocalVar("lastWarpHpp", hpp)
        local targetId = target and target:isPC() and target:getID() or nil
        mob:timer(1, function(baron)
            -- 2026-08-23: "kesu"/"deru" (vanish/appear) FourCC animation -- NOT capture-confirmed
            -- for this specific warp mechanic (checked: the real capture's kesu/deru moments line
            -- up exactly with Deafening/Abrasive Tantara weaponskill flourishes, position
            -- unchanged both times -- a red herring, not the warp). Position-update packets aren't
            -- surfaced as readable CapLog text at all, so there's no way to confirm what, if
            -- anything, plays on a real warp from this capture format. Used here anyway as a
            -- deliberate, user-approved best guess ("let's try option 2") rather than a silent
            -- teleport -- it's a real vanish/appear pair with genuine precedent elsewhere
            -- (Armoury_Crate.lua:1052-1058), just not verified for Black Baron specifically.
            -- 2026-08-24: cannot pair this with setStatus(DISAPPEAR)/(NORMAL) the way
            -- Armoury_Crate.lua's NPC door props do to actually hide the model -- root cause of the
            -- earlier permanent-vanish regression now confirmed (CBattleEntity::isDead() treats
            -- status==DISAPPEAR as literally dead for anything with combat state, mobs included --
            -- see WARP_ANIM_DELAY_MS's comment above for the full writeup). The model stays visible
            -- through the teleport itself (an abrupt pop, not a true vanish) -- what changed instead
            -- is the BUILDUP: kesu now pulses twice with a real gap between them before the actual
            -- teleport, giving players enough time to register "he's about to warp" rather than the
            -- old single-pulse-into-instant-blink that read as a jarring instant disappear.
            setInvincible(baron, true)
            baron:entityAnimationPacket("kesu")
            baron:timer(WARP_TELEGRAPH_DELAY_MS, function(baron2)
                baron2:entityAnimationPacket("kesu")
                baron2:timer(WARP_ANIM_DELAY_MS, function(baron3)
                    baron3:disengage()
                    -- re-resolve: a captured `target` wrapper can be freed by now (resetEnmity derefs it unchecked)
                    local liveTarget = targetId and GetPlayerByID(targetId)
                    if liveTarget then
                        baron3:resetEnmity(liveTarget)
                    end
                    local p = WARP_POINTS[math.random(#WARP_POINTS)]
                    baron3:setPos(p[1], p[2], p[3])
                    baron3:entityAnimationPacket("deru")
                    setInvincible(baron3, false) -- landed safely, back to a normal vulnerable fight
                end)
            end)
        end)
    end
end

function onMobDeath(mob, player, isKiller)
    if player then
        local instance = mob:getInstance()
        instance:setProgress(instance:getProgress() + 1)
    end
end

function onMobDespawn(mob)
end

