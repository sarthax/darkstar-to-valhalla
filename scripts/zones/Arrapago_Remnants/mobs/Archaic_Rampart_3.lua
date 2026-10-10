-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Archaic Rampart
-----------------------------------
mixins = {require("scripts/mixins/families/rampart")}
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------
function onMobSpawn(mob)
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    local popTime = mob:getLocalVar("lastPetPop")
    local POS = mob:getPos()
    local PET1 = GetMobByID((mob:getID() +1), instance)
    local PET2 = GetMobByID((mob:getID() +2), instance)
    local PET3 = GetMobByID((mob:getID() +3), instance)


    if os.time() - popTime > 15 then
        if not PET1:isSpawned() then
            PET1:setSpawn(POS.x, POS.y, POS.z, POS.rot)
            mob:useMobAbility(2034)
            mob:setLocalVar("lastPetPop", os.time())
            mob:timer(2500, function(m)
                SpawnMob((m:getID() +1), instance)
            end)
        elseif not PET2:isSpawned() then
            PET2:setSpawn(POS.x, POS.y, POS.z, POS.rot)
            mob:useMobAbility(2034)
            mob:setLocalVar("lastPetPop", os.time())
            mob:timer(2500, function(m)
                SpawnMob((m:getID() +2), instance)
            end)
        elseif not PET3:isSpawned() then
            PET3:setSpawn(POS.x, POS.y, POS.z, POS.rot)
            mob:useMobAbility(2034)
            mob:setLocalVar("lastPetPop", os.time())
            mob:timer(2500, function(m)
                SpawnMob((m:getID() +3), instance)
            end)
        end
    end
    if PET1:isSpawned() then
        PET1:updateEnmity(target)
    end
    if PET2: isSpawned() then
        PET2:updateEnmity(target)
    end
    if PET3: isSpawned() then
        PET3:updateEnmity(target)
    end
end

function onMobDeath(mob, player, isKiller)
    -- 2026-09-05: real fix -- this was an empty stub. Per confirmed real mechanic (ffxiclopedia),
    -- the east-room rampart (rampart4) only pops once the west-room rampart (rampart3) is defeated.
    -- Both ramparts share this same script (SQL name Archaic_Rampart_3), so this only fires for the
    -- west one's own death, not a double-spawn on the east one's death too.
    local instance = mob:getInstance()
    if Arrapago.mobs[6].rampart3 == mob:getID() then
        SpawnMob(Arrapago.mobs[6].rampart4, instance)
    end
end

function onMobDespawn(mob)
end

