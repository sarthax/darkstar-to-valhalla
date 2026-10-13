-----------------------------------
-- Area: Zhayolm Remnants
-- NPC: Socket
-- Trade Salvage Cells to pop Poroggo Madame
-- Poroggo Madame drops 2x the Cells traded
-----------------------------------
-- 2026-09-04: mirrors Arrapago/Bhaflau/Silver Sea Remnants' real, already-working npcs/Socket.lua
-- exactly. Real NM per BG Wiki's route table: Poroggo Madame (multiple real ids share this
-- mobname across floors, see IDs.lua -- Zhayolm.mobs.POROGGO_MADAME[1] used here as the Socket's own
-- popped instance, matching the other 3 zones' one-Socket-one-NM-id convention).
-----------------------------------
require("scripts/zones/Zhayolm_Remnants/IDs")
-----------------------------------
function onTrade(player, npc, trade)
    local instance = npc:getInstance()
    local mob = GetMobByID(Zhayolm.mobs.POROGGO_MADAME[1], instance)
    local COUNT = trade:getItemCount()
    local INCUS_CELL = 5365
    local SPISSATUS_CELL = 5384

    for i = INCUS_CELL, SPISSATUS_CELL do
        if COUNT <= 5 and trade:hasItemQty(i, COUNT) then
            SpawnMob(Zhayolm.mobs.POROGGO_MADAME[1], instance):updateClaim(player)
            player:tradeComplete()
            mob:setLocalVar("Cell", i)
            mob:setLocalVar("Qnt", COUNT)
        end
    end
end

function onTrigger(entity, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(entity, eventid, result)
end

