--[[
https://ffxiclopedia.fandom.com/wiki/Ziz

AnimationSub(1) small neck pouch
AnimationSub(2) large neck pouch
AnimationSub(3) sleeping z's
--]]
-----------------------------------
-- DSP-PORT (2026-09-14, rewritten): originally ported as a listener-based mixin (`mixins = {...}`
-- + addListener("ROAM_TICK"/"SPAWN"/"ENGAGE", ...)) -- confirmed that whole approach is dead code
-- in old-dsp-reference: nothing in this codebase's C++ reads a mob script's `mixins` global at
-- all (that auto-apply only exists in Topaz's own luautils.cpp -- zero native old-dsp-reference
-- scripts even use `mixins = {...}`), and even applied, neither "ROAM_TICK" nor a periodic
-- roam-check fires reliably here anyway -- the closest real equivalent, `onMobRoamAction`, is
-- gated behind ROAMFLAG_EVENT (mob_controller.cpp) which isn't confirmed set for this project's
-- real mob rows.
--
-- Real fix: a self-rescheduling mob:timer(...) loop, started from the mob's own real onMobSpawn
-- -- the same proven pattern this project already uses extensively elsewhere (Mining_Point.lua's
-- mining-point cycling, Sagelord_Molaal_Ja.lua's flee logic) instead of depending on an unconfirmed
-- roam-flag gate. SPAWN/ENGAGE are real, always-firing events in this codebase (confirmed via
-- EventHandler.triggerListener call sites) -- but reshaped here to plain functions called from
-- the mob's own real onMobSpawn/onMobEngaged, matching this codebase's real per-mob-callback
-- convention (see ImpMix's sibling header for the fuller explanation) rather than addListener.
-- `tpz.time.NIGHT`/`tpz.time.MIDNIGHT` -> bare `TIME_NIGHT`/`TIME_MIDNIGHT` (weather.lua, same
-- real VanadielTOTD() comparison convention chocobo_digging.lua already uses). `tpz.mobMod.NO_MOVE`
-- -> bare `MOBMOD_NO_MOVE` (status.lua). getAnimationSub()/setAnimationSub(x) -> this codebase's
-- already-unified AnimationSub()/AnimationSub(x).
-----------------------------------
require("scripts/globals/status")
require("scripts/globals/weather")
-----------------------------------

ZizMix = ZizMix or {}

local RECHECK_MS = 15000 -- how often to re-evaluate day/night state while roaming

local function sleepDuringNight(mob)
    local aSub = mob:AnimationSub()
    local totd = VanadielTOTD()

    if totd == TIME_NIGHT or totd == TIME_MIDNIGHT then -- 20:00 to 4:00
        if aSub ~= 3 then
            mob:AnimationSub(3)
            mob:setAggressive(false)
            mob:setMobMod(MOBMOD_NO_MOVE, 1)
        end
    else
        if aSub ~= 1 then
            mob:AnimationSub(1)
            mob:setAggressive(true)
            mob:setMobMod(MOBMOD_NO_MOVE, 0)
        end
    end
end

local function roamLoop(mob)
    if not mob:isSpawned() then
        return
    end
    if not mob:isEngaged() then
        sleepDuringNight(mob)
    end
    mob:timer(RECHECK_MS, roamLoop)
end

-- call from the mob's own real onMobSpawn(mob).
ZizMix.onSpawn = function(mob)
    sleepDuringNight(mob)
    mob:timer(RECHECK_MS, roamLoop)
end

-- call from the mob's own real onMobEngaged(mob, target).
ZizMix.onEngage = function(mob)
    mob:AnimationSub(1)
    mob:setAggressive(true)
    mob:setMobMod(MOBMOD_NO_MOVE, 0)
end

return ZizMix
