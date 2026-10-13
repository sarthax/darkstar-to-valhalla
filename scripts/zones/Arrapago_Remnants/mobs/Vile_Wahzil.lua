-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Vile Wahzil
-----------------------------------
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------
function onMobSpawn(mob)
    local instance = mob:getInstance()
    instance:getEntity(bit.band(Arrapago.npcs[2][2].SOCKET, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
end

function onMobDeath(mob, player, isKiller)
    local CELL = mob:getLocalVar("Cell")
    local AMOUNT = mob:getLocalVar("Qnt") *2

    while AMOUNT > 0 do
        player:addTreasure(CELL)
        AMOUNT = AMOUNT -1
    end
end

function onMobDespawn(mob)
end

