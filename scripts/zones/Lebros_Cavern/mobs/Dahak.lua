-----------------------------------
-- Area: Lebros Cavern (Evade and Escape)
--  Mob: Dahak
-----------------------------------
-- Kill-all pattern -- see instances/evade_and_escape.lua.
-- 2026-08-19: progress was being counted from onMobDespawn, which fires on ANY despawn
-- (including a leash back to spawn), not just a real kill. Moved to onMobDeath gated on a real
-- killer, plus MOBMOD_NO_DESPAWN so a Dahak can't leash away uncounted -- same fix already
-- applied to Sagelord_Molaal_Ja.lua/Broken_Troll_Soldier.lua/Frozen_Bones.lua/Gelid_Bhoot.lua
-- this session.
--
-- 2026-09-02: real patrol/roam logic added, backported from a user-supplied LandSandBoat-format
-- reference script (real 6 endpoint positions, split into a "top" group of 3 and a "bottom" group
-- of 3, bitwise-gated per Dahak by numeric offset from 17035324). This directly resolves the
-- open gap flagged in instances/evade_and_escape.lua's own header ("Dahak roam is currently
-- non-functional... needs real per-Dahak waypoint capture data"). Real access per the user's own
-- explanation: id 17035325 (offset 1, binary 01) can only path to the top group; 17035326 (offset
-- 2, binary 10) only the bottom group; 17035327 (offset 3, binary 11) can path to either.
--
-- Backport notes (LSB -> Topaz, this codebase's bindings differ):
--   - `mob:getPathLen()` has no Topaz equivalent (not a registered binding) -- the LSB source used
--     it to compute a rising probability of picking a new path as the current one nears its end.
--     Simplified to Topaz's own established pattern instead (Periqia's Lamia patrol, Ilrusi's
--     Giant Orobon roam): just wait for isFollowingPath() to go false, then immediately pick the
--     next random endpoint. Loses the "more likely to redirect near path end" nuance, keeps the
--     real endpoint-selection/access-group logic intact.
--   - `utils.isBitSet` isn't a Topaz global -- this codebase already uses LuaJIT's real `bit`
--     library directly elsewhere (scripts/globals/besieged.lua, conquest.lua) -- used
--     `bit.band()` here instead.
--   - `xi.pathflag.SCRIPT` alone became `RUN|SCRIPT` (no WALLHACK) -- 2026-09-02, user-directed:
--     WALLHACK is only meant as a workaround for genuinely broken/incomplete navmesh, and the
--     navmesh in this area has since been corrected -- proper navmesh-following pathing should
--     work now, so it should NOT be blanket-applied here. If a live test finds a specific leg that
--     still can't path (a real remaining navmesh gap on that one route), fix it surgically for
--     that leg / report the gap for a navmesh fix, rather than reintroducing a blanket wallhack.
--   - `mob:speed(N)` (Topaz's own `mob:setBaseSpeed(N)`) -> old-dsp-reference has no split
--     get/set speed bindings, only a unified `speed()` method (get with no args, set with one arg)
--     confirmed at src/map/lua/lua_baseentity.cpp:4511 -- rewritten to `mob:speed(N)` (2026-09-13).
--   - `mob:addImmunity(xi.immunity.X)` has no Topaz Lua binding -- status-effect immunity in this
--     engine is DB-only (mob_pools.immunity bitmask, see scripts/globals/status.lua's own
--     IMMUNITY note: "This only works from the db, not scripts"). SLEEP(0x01)/GRAVITY(0x02)/
--     BIND(0x04) = 7 needs to be set on poolid 894's `immunity` column in sql/mob_pools.sql
--     instead (not yet done -- flagged, needs a SQL edit + reimport). TERROR has no immunity bit
--     at all in this Topaz build (only a status effect, EFFECT_TERROR, no IMMUNITY_TERROR flag
--     exists in src/map/entities/battleentity.h) -- real engine gap, can't be ported.
--   - `mob:setMobMod(xi.mobMod.DONT_ROAM_HOME, 1)` has no Topaz mobMod equivalent -- not needed
--     anyway: confirmed via mob_controller.cpp that onMobRoam() fires on its own fixed ~3s tick
--     independent of the native RoamAround()/GetRoamDistance() path, so this custom pathTo()-
--     driven roam works without it (and without the ROAM_DISTANCE mob_pool_mods row the instance
--     file's header flagged as missing -- that row is only needed for the native default-wander
--     behavior, which this script fully overrides).
--   - `assaultUtil.adjustMobLevel(mob)` and the `MOBS_START.BOSS` per-mob speed/DRAW_IN
--     differentiation are LSB-side concepts with no equivalent structure in this repo's Evade and
--     Escape build (no "boss" Dahak is currently distinguished anywhere in this mission's SQL/Lua)
--     -- dropped rather than inventing a boss designation this mission doesn't have.
--   - `mob:setMod(xi.mod.REGEN, 54)`, `setMobMod(...SIGHT_RANGE, 13)`, and DRAW_IN on engage are
--     kept as-is -- real Topaz equivalents exist (MOD_REGEN, MOBMOD_SIGHT_RANGE,
--     MOBMOD_DRAW_IN all confirmed in src/map/mob_modifier.h) and directly usable.
-----------------------------------
local DAHAK_OFFSET = 17035324

local END_POINTS =
{
    { -- top group (bit 0) -- 17035325, 17035327
        { 399.139, -50.584,   18.213 },
        { 418.842, -29.734,  -73.800 },
        { 398.097, -30.508, -261.095 },
    },
    { -- bottom group (bit 1) -- 17035326, 17035327
        { 245.000, -30.662,  100.970 },
        { 304.730, -30.097,   16.565 },
        { 205.767, -29.020,  -59.178 },
    },
}

-- RUN(1) | SCRIPT(8) -- no WALLHACK(2). Navmesh in this area was corrected, so proper
-- navmesh-following pathing is expected to work; see header for what to do if a specific leg
-- can't path.
local PATHFLAG_RUN_SCRIPT = 9

local function startNewPath(mob)
    local dahakNumber = mob:getID() - DAHAK_OFFSET
    local validTargetPos = {}

    for index, points in ipairs(END_POINTS) do
        if bit.band(dahakNumber, bit.lshift(1, index - 1)) ~= 0 then
            for _, pos in ipairs(points) do
                table.insert(validTargetPos, pos)
            end
        end
    end

    if #validTargetPos == 0 then
        return
    end

    local lastIndex = mob:getLocalVar("targetPos")
    local newIndex = lastIndex
    while newIndex == lastIndex do
        newIndex = math.random(#validTargetPos)
    end
    mob:setLocalVar("targetPos", newIndex)

    local targetX, targetY, targetZ = unpack(validTargetPos[newIndex])
    mob:pathTo(targetX, targetY, targetZ, PATHFLAG_RUN_SCRIPT)
end

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
    mob:setMobMod(MOBMOD_SIGHT_RANGE, 13)
    -- 2026-09-02, user-reported live: the header above already claimed DRAW_IN was "kept as-is"
    -- from the source LSB script, but the call was never actually written here -- real, standard
    -- pattern for this dragon family (Wyrm.lua/Black_Dragon.lua/Dark_Dragon.lua all set this on
    -- spawn), now actually applied.
    mob:setMobMod(MOBMOD_DRAW_IN, 1)
    mob:setMod(MOD_REGEN, 54)
    mob:setTrueDetection(1)
    mob:speed(32)
end

function onMobRoam(mob)
    if not mob:isFollowingPath() then
        startNewPath(mob)
    end
end

function onMobEngaged(mob)
    mob:speed(40)
end

function onMobDisengage(mob)
    mob:speed(32)
end

function onMobDeath(mob, player, isKiller)
    if player then
        local instance = mob:getInstance()
        -- 2026-08-29: no longer touches instance:setProgress() directly -- the real mechanic
        -- (see npcs/Switch.lua) needs 3 SIMULTANEOUSLY active switches, checked by real-time
        -- expiry, not a flat monotonic counter. A Dahak kill is still user-confirmed
        -- independently valid, modeled as a permanent credit (no expiry, since a kill has no
        -- natural "5-minute window") toward the same 3-needed total -- see
        -- instances/evade_and_escape.lua's onInstanceTimeUpdate for where this is combined with
        -- live switch state.
        instance:setLocalVar("dahakKills", (instance:getLocalVar("dahakKills") or 0) + 1)
    end
end

function onMobDespawn(mob)
end

