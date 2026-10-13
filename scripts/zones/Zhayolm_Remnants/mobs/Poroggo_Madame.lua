-----------------------------------
-- Area: Zhayolm Remnants
--  Mob: Poroggo Madame
-----------------------------------
-- 2026-09-04: Poroggo Madame is BOTH this zone's real Socket NM (see npcs/Socket.lua) AND a
-- regular trash mob spawned directly via SQL across several floors (see IDs.lua) -- unlike
-- Bhaflau/Silver Sea where the Socket NM (Flux Flan/Gakke) is a dedicated id never used as trash.
-- onMobSpawn's Socket-hide call only matters for the Socket-popped instance (a trash spawn's own
-- SOCKET npc is unrelated/already resolved, so the extra setStatus call is harmless). onMobDeath
-- checks whether Cell/Qnt localvars were set by npcs/Socket.lua's onTrade (Socket-popped path,
-- mirrors Vile_Wahzil.lua's cell-drop) -- if not (a trash spawn, localvars default 0), falls back
-- to the same salvageUtil.spawnTempChest call the zone's other trash mobs use.
-----------------------------------
require("scripts/zones/Zhayolm_Remnants/IDs")
require("scripts/globals/status")
require("scripts/globals/salvage")
-----------------------------------
function onMobSpawn(mob)
    local instance = mob:getInstance()
    instance:getEntity(bit.band(Zhayolm.npcs.SOCKET, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
end

function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    if instance and (isKiller or not player) then
        -- LSB: boss-floor spawns (stage 6) check killedNMs >= 4
        instance:setLocalVar('killedNMs', instance:getLocalVar('killedNMs') + 1)
    end

    local CELL = mob:getLocalVar("Cell")
    local AMOUNT = mob:getLocalVar("Qnt") * 2

    if AMOUNT > 0 then
        while AMOUNT > 0 do
            player:addTreasure(CELL)
            AMOUNT = AMOUNT - 1
        end
    else
        salvageUtil.spawnTempChest(mob)
    end
end

function onMobDespawn(mob)
end

