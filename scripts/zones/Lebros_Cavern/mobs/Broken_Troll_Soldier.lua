-----------------------------------
-- Area: Lebros Cavern (Troll Fugitives)
--  Mob: Broken Troll Soldier
-----------------------------------
-- 2026-08-20: progress hook was on onMobDespawn (fires on ANY despawn, not just death -- e.g.
-- a leash back to spawn during the HP-randomized fight below would silently count as a kill,
-- or conversely just never firing correctly could stall the mission at less than 15/15). Applied
-- the same fix already used for Sagelord Molaal Ja (Mamool_Ja_Training_Grounds) and Lamia No.13
-- (Ilrusi Atoll): NO_DESPAWN so it can't leash away uncounted, and progress now only increments
-- on a real player kill via onMobDeath.
-- 2026-08-20, user-confirmed live: real mechanic is "they start out somewhat wounded... range in
-- health from 25% to 75%." The HP roll below already existed but was wrongly on onMobEngaged (so
-- it wouldn't apply until first engaged, and re-firing on every re-engage after losing aggro would
-- reset/partially heal an already-damaged Troll back up) -- moved to onMobSpawn so it applies once,
-- at spawn, and stays for the fight, matching "start out wounded," not "reset whenever re-engaged."
-- 2026-09-14, user-confirmed live on Topaz: Broken Troll Soldiers really do use their job's
-- 2-hour ability -- a hard requirement, not optional flavor. Wired to JobSpecialMix
-- (scripts/mixins/job_special.lua) via this codebase's real per-mob callback functions
-- (onMobSpawn/onMobEngaged/onMobFight), NOT Topaz's `mixins = {...}` auto-apply table -- confirmed
-- old-dsp-reference has no C++ equivalent that reads/applies that table at all (see
-- job_special.lua's own header for the full explanation). Troll Soldiers are WAR, so this
-- resolves to Mighty Strikes (real mob_skills.sql id 688 -- the same id old-dsp-reference's own
-- Attohwa_Chasm/mobs/Tiamat.lua already uses live for the identical purpose).
require("scripts/mixins/job_special")
-----------------------------------
function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
    mob:setHP(mob:getMaxHP() * math.random(25, 75) / 100)
    JobSpecialMix.onSpawn(mob)
end

function onMobEngaged(mob, target)
    JobSpecialMix.onEngage(mob)
end

function onMobFight(mob, target)
    JobSpecialMix.onFight(mob, target)
end

function onMobDeath(mob, player, isKiller)
    if player then
        local instance = mob:getInstance()
        instance:setProgress(instance:getProgress() + 1)
    end
end

function onMobDespawn(mob)
end

