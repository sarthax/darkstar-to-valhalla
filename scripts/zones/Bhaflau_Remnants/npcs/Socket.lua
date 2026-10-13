-----------------------------------
-- Area: Bhaflau Remnants
-- NPC: Socket
-- Trade Salvage Cells to pop Flux Flan
-- Flux Flan drops 2x the Cells traded
-----------------------------------
-- 2026-09-05: mirrors Arrapago Remnants' real, already-working npcs/Socket.lua exactly. Real NM
-- confirmed: Flux Flan (id 17084720, real row already in Topaz's own sql/mob_spawn_points.sql --
-- see IDs.lua's FLUX_FLAN comment). Real position cross-check placed this zone's Socket
-- (id 17084856) at the "Foxmulder" capture reading (457.5,0,260), ~2.3 units from Flux Flan's own
-- spawn position -- see sql/npc_list.sql's Socket row comment.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
function onTrade(player, npc, trade)
    local instance = npc:getInstance()
    local mob = GetMobByID(Bhaflau.mobs.FLUX_FLAN, instance)
    local COUNT = trade:getItemCount()
    local INCUS_CELL = 5365
    local SPISSATUS_CELL = 5384

    for i = INCUS_CELL, SPISSATUS_CELL do
        if COUNT <= 5 and trade:hasItemQty(i, COUNT) then
            SpawnMob(Bhaflau.mobs.FLUX_FLAN, instance):updateClaim(player)
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

