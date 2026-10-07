-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Lilisette (tier 4)
-- Wiki: splits into two below 50% HP. The clone (mob 17093287, same group) is spawned at the
-- capture's clone position with the parent's current HP; tier is done when both are dead.
-- Whether the clone spawns at instance start (all instance_entities load) is handled by
-- despawning it until the split fires. UNVERIFIED LIVE.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-- Tier 4 uses instance 80's LILISETTE/LILISETTE_SPLIT; the 6th battle has its own pair (capture 17093315/16).
local function ids(mob)
    if tpz.heroines.isSix(mob) then
        return tpz.heroines.SIX_LILISETTE, tpz.heroines.SIX_LILISETTE_SPLIT, "HH_S_"
    end
    return NyzulIsle.mobs[80].LILISETTE, NyzulIsle.mobs[80].LILISETTE_SPLIT, "HH_T4_"
end

function onMobSpawn(mob)
    local instance = mob:getInstance()
    local main, split, prefix = ids(mob)
    if instance and mob:getID() == split and instance:getLocalVar(prefix .. "Split") ~= 1 then
        DespawnMob(mob:getID(), instance)
        return
    end
    tpz.heroines.armSixNoDespawn(mob)
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    local main, split, prefix = ids(mob)
    if not instance or mob:getID() ~= main or instance:getLocalVar(prefix .. "Split") == 1 then
        return
    end
    if mob:getHPP() < 50 then
        instance:setLocalVar(prefix .. "Split", 1)
        local clone = SpawnMob(split, instance)
        if clone then
            clone:setHP(mob:getHP())
            clone:updateEnmity(target)
        end
    end
end

function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    if not instance then
        return
    end
    local main, split, prefix = ids(mob)
    instance:setLocalVar(prefix .. "Dead", instance:getLocalVar(prefix .. "Dead") + 1)
    if instance:getLocalVar(prefix .. "Dead") >= 2 then
        tpz.heroines.mobSay(mob, 7633) -- "Oh, drat! This wasn't in the script..." (death line, inferred from text)
        tpz.heroines.onHeroineDeath(mob)
    end
end

