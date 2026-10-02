--[[
https://ffxiclopedia.fandom.com/wiki/Category:Crawlers

Eruca mobs can optionally be modified by calling EruMix.config(mob, params) from within onMobSpawn
(AFTER calling EruMix.onSpawn(mob) -- config overrides the defaults onSpawn sets).

params is a table that can contain the following keys:
    sleepHour : changes hour at which eruca crawlers naturally fall asleep (default: 18)
    wakeHour  : changes hour at which eruca crawlers naturally wake (default: 6)
--]]
-----------------------------------
-- DSP-PORT (2026-09-14, rewritten): originally ported as a listener-based mixin -- confirmed dead
-- code in old-dsp-reference for the same reasons documented in this family of mixins' sibling
-- ZizMix (see that file's header for the full explanation: no C++ auto-applies a mob script's
-- `mixins` global here at all, and the closest real roam-periodic hook, `onMobRoamAction`, is
-- gated behind an unconfirmed ROAMFLAG_EVENT). Same real fix: a self-rescheduling mob:timer(...)
-- loop from the mob's own real onMobSpawn, SPAWN/ENGAGE/DISENGAGE reshaped into plain functions
-- called from the mob's own real onMobSpawn/onMobEngaged/onMobDisengage.
--
-- `tpz.mobMod.*` -> bare `MOBMOD_*` (status.lua). `tpz.mod.REGAIN` -> bare `MOD_REGAIN`
-- (status.lua). `tpz.day.FIRESDAY` -> bare `FIRESDAY` (scripts/globals/magic.lua -- confirmed
-- same real VanadielDayElement() comparison convention scripts/globals/monstertpmoves.lua already
-- uses). getMod/setMod, getAnimationSub()/setAnimationSub(x) -> this codebase's already-unified
-- AnimationSub().
--
-- REAL GAP, not fabricated around: Topaz's `tpz.mobMod.NO_AGGRO`/`tpz.mobMod.NO_LINK` have no
-- MOBMOD_NO_AGGRO/MOBMOD_NO_LINK equivalent anywhere in this codebase's status.lua (confirmed
-- absent by grepping the full real MOBMOD_* list). NO_AGGRO's intent is covered by the already-
-- real `setAggressive(bool)` binding instead (same one ZizMix's sibling already uses). NO_LINK has
-- no substitute at all -- dropped; a sleeping crawler here can still cause other crawlers to link
-- onto it, a real, known behavioral gap versus Topaz until a MOBMOD_NO_LINK equivalent is added.
-----------------------------------
require("scripts/globals/status")
require("scripts/globals/magic")
-----------------------------------

EruMix = EruMix or {}

local RECHECK_MS = 15000 -- how often to re-evaluate day/night state and the Firesday Regain bonus

local function bedTime(mob)
    mob:AnimationSub(mob:AnimationSub() + 1)
    mob:setMobMod(MOBMOD_NO_MOVE, 1)
    mob:setAggressive(false)
    mob:setLocalVar("ResleepTime", 0)
end

local function wakeUp(mob)
    mob:AnimationSub(mob:AnimationSub() - 1)
    mob:setMobMod(MOBMOD_NO_MOVE, 0)
    mob:setAggressive(true)
    mob:setLocalVar("ResleepTime", 0)
end

local function tick(mob)
    local currentHour = VanadielHour()
    local sleepHour = mob:getLocalVar("[eruca]sleepHour")
    local wakeHour = mob:getLocalVar("[eruca]wakeHour")
    local subAnimation = mob:AnimationSub()

    if subAnimation == 0 and (currentHour >= sleepHour or currentHour < wakeHour) and not mob:isEngaged() then
        local resleepTime = mob:getLocalVar("ResleepTime")

        if resleepTime ~= 0 and mob:checkDistance(mob:getSpawnPos()) > 25 then
            mob:setLocalVar("ResleepTime", os.time() + 120) -- Reset sleep timer until crawler returns home
        elseif resleepTime <= os.time() then -- No timer was set (normal behavior) OR crawler has been back home for 2 minutes since disengaged
            bedTime(mob)
        end
    elseif subAnimation == 1 and currentHour < sleepHour and currentHour >= wakeHour then
        wakeUp(mob)
    end

    if VanadielDayElement() == FIRESDAY and mob:getMod(MOD_REGAIN) == 0 then
        mob:setMod(MOD_REGAIN, 30)
    elseif VanadielDayElement() ~= FIRESDAY and mob:getMod(MOD_REGAIN) ~= 0 then
        mob:setMod(MOD_REGAIN, 0)
    end
end

local function roamLoop(mob)
    if not mob:isSpawned() then
        return
    end
    tick(mob)
    mob:timer(RECHECK_MS, roamLoop)
end

EruMix.config = function(mob, params)
    if params.sleepHour and type(params.sleepHour) == "number" then
        mob:setLocalVar("[eruca]sleepHour", params.sleepHour)
    end
    if params.wakeHour and type(params.wakeHour) == "number" then
        mob:setLocalVar("[eruca]wakeHour", params.wakeHour)
    end
end

-- call from the mob's own real onMobSpawn(mob).
EruMix.onSpawn = function(mob)
    mob:setLocalVar("[eruca]sleepHour", 18)
    mob:setLocalVar("[eruca]wakeHour", 6)
    mob:timer(RECHECK_MS, roamLoop)
end

-- call from the mob's own real onMobEngaged(mob, target).
EruMix.onEngage = function(mob)
    if mob:AnimationSub() == 1 then
        wakeUp(mob)
    end
end

-- call from the mob's own real onMobDisengage(mob).
EruMix.onDisengage = function(mob)
    mob:setLocalVar("ResleepTime", os.time() + 120) -- Eruca crawlers go back to sleep exactly 2 minutes after they were engaged.
end

return EruMix
