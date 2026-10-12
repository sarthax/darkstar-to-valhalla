-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Long-Bowed Chariot
-----------------------------------
-- 2026-09-08: real mechanic, ported from LandSandBoat's own real, working Long-Bowed_Chariot.lua.
-- Stationary boss mods (ATT+100, MAIN_DMG_RATING=50, REGAIN=25, no roam) and sleep/gravity/bind
-- immunity are real and confirmed -- immunity moved to sql/mob_pools.sql (this Topaz fork has no
-- Lua-side addImmunity binding; IMMUNITY_SLEEP/GRAVITY/BIND is a real SQL-level bitmask instead,
-- see that file's own comment).
--
-- Real per-chariot boss-weaken effect (matches the Vana'diel Atlas map the user supplied: "The
-- west chariot will weaken mega boss' defense and magical defense. The east chariot will weaken
-- mega boss' attacks (not homing missile)") -- driven by Archaic_Chariot.lua's own
-- instance:setLocalVar('bossModifier', instance:getProgress()) on death, read here on spawn.
require("scripts/globals/titles")
-----------------------------------
function onMobInitialize(mob)
    mob:addMod(MOD_ATT, 100)
    mob:setMod(MOD_MAIN_DMG_RATING, 50)
    mob:setMod(MOD_REGAIN, 25)
    mob:setMobMod(MOBMOD_ROAM_DISTANCE, 0)
    mob:setMobMod(MOBMOD_ROAM_TURNS, 0)
end

function onMobSpawn(mob)
    local instance = mob:getInstance()
    if not instance then
        return
    end

    local bossModifier = instance:getLocalVar('bossModifier')
    if bossModifier == 1 then
        mob:addMod(MOD_DEF, -100)
        mob:setMod(MOD_DMGMAGIC, 100)
    elseif bossModifier == 2 then
        mob:addMod(MOD_ATT, -100)
    end
end

function onMobDeath(mob, player, isKiller)
    if player then
        player:addTitle(COMET_CHARIOTEER)
    end

    local instance = mob:getInstance()
    if instance then
        instance:complete()
    end
end

