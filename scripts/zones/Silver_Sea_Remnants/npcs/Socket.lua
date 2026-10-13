-----------------------------------
-- Area: Silver Sea Remnants
-- NPC: Socket
-- Trade Salvage Cells to pop Gakke
-- Gakke drops 2x the Cells traded
-----------------------------------
-- 2026-09-06: mirrors Arrapago Remnants' real, already-working npcs/Socket.lua exactly. Real NM
-- confirmed: Gakke (id 17088596, real row already in Topaz's own sql/mob_spawn_points.sql,
-- position within a fraction of a unit of this zone's real SOCKET position).
-----------------------------------
require("scripts/zones/Silver_Sea_Remnants/IDs")
-----------------------------------
function onTrade(player, npc, trade)
    local instance = npc:getInstance()
    local mob = GetMobByID(SilverSea.mobs.GAKKE, instance)
    local COUNT = trade:getItemCount()
    local INCUS_CELL = 5365
    local SPISSATUS_CELL = 5384

    for i = INCUS_CELL, SPISSATUS_CELL do
        if COUNT <= 5 and trade:hasItemQty(i, COUNT) then
            SpawnMob(SilverSea.mobs.GAKKE, instance):updateClaim(player)
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

