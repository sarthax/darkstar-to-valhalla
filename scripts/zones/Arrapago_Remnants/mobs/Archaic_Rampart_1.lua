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

    if os.time() - popTime > 15 then
        if not PET1:isSpawned() then
            PET1:setSpawn(POS.x, POS.y, POS.z, POS.rot)
            mob:useMobAbility(2034)
            mob:setLocalVar("lastPetPop", os.time())
            mob:timer(2500, function(m)
                SpawnMob((m:getID() +1), instance)
            end)
        end
    end
    if PET1:isSpawned() then
        PET1:updateEnmity(target)
    end
end

function onMobDeath(mob, player, isKiller)
    -- 2026-09-05: real fix -- this was an empty stub, so a rampart1-named mob's death never
    -- counted toward door progress on ANY floor. Archaic_Rampart_2.lua's own onMobDeath checks
    -- for both rampart1 and rampart2 ids, but that check is dead code for rampart1 -- mob scripts
    -- resolve by SQL name, so a mob named Archaic_Rampart_1 always runs THIS file, never
    -- Archaic_Rampart_2.lua. Confirmed cause of door _22f (floor 6, requires progress >= 11)
    -- feeling permanently sealed -- rampart1's kill was never being credited.
    local instance = mob:getInstance()
    if Arrapago.mobs[6].rampart1 == mob:getID() then
        if instance:getStage() == 6 and instance:getProgress() >= 1 then
            if isKiller then
                instance:setProgress(instance:getProgress() + 1)
            end
        end
    end
end

function onMobDespawn(mob)
end

