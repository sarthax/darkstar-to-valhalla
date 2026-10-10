-----------------------------------
-- Area: Silver Sea Remnants
--  Mob: Gakke
-----------------------------------
-- 2026-09-06: mirrors Arrapago Remnants' real, already-working mobs/Vile_Wahzil.lua exactly --
-- same real Socket mechanic (hide Socket on spawn, drop back 2x the traded cell on death), just
-- this zone's real Socket NM (see npcs/Socket.lua).
-----------------------------------
require("scripts/zones/Silver_Sea_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------
function onMobSpawn(mob)
    local instance = mob:getInstance()
    instance:getEntity(bit.band(SilverSea.npcs.SOCKET, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
end

function onMobDeath(mob, player, isKiller)
    local CELL = mob:getLocalVar("Cell")
    local AMOUNT = mob:getLocalVar("Qnt") * 2

    while AMOUNT > 0 do
        player:addTreasure(CELL)
        AMOUNT = AMOUNT - 1
    end
end

function onMobDespawn(mob)
end

