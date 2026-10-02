-----------------------------------
-- Area: Periqia (Requiem)
--  Mob: Draconic Draugar
-----------------------------------
function onMobEngaged(mob, target)
    local instance = mob:getInstance()
    local mobID = mob:getID()

    -- The Wyvern's DB spawn point is a (1,1,1) placeholder (instance_loader has no pet attach), so
    -- spawn it at its master or it appears out of the map and never reaches the fight.
    local wyvern = instance:getEntity(bit.band(mobID + 1, 0xFFF), TYPE_MOB)
    if wyvern then
        wyvern:setSpawn(mob:getXPos() + 1, mob:getYPos(), mob:getZPos() + 1, mob:getRotPos())
        wyvern:setPos(mob:getXPos() + 1, mob:getYPos(), mob:getZPos() + 1, mob:getRotPos())
    end
    local spawned = SpawnMob(mobID + 1, instance)
    if spawned then
        spawned:updateEnmity(target)
    end
end

function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    instance:setProgress(instance:getProgress() + 1)
end

