-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Najelith (npc_list 17093452 = capture 17093453). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.01 23:43:30, dialog 7696 ("May the winds speed you to safety, friend."),
-- immediately followed by "Obtained temporary item: a bottle of body boost!" -- real item id 4147
-- (bottle of body boost, confirmed via id_bridge.py, exact LSB/Topaz id match).
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_BODY_BOOST = 4147

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7681, true)
    if not player:hasItem(ITEM_BODY_BOOST, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_BODY_BOOST, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_BODY_BOOST)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

