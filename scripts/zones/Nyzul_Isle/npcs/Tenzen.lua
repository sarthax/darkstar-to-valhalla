-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Tenzen (npc_list 17093463 = capture 17093464). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.01 23:35:23, dialog 7692, immediately followed by
-- "Obtained temporary item: a flask of healing powder!" -- real item id 5322
-- (flask of healing powder, confirmed via id_bridge.py, exact LSB/Topaz id match).
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_HEALING_POWDER = 5322

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7677, true)
    if not player:hasItem(ITEM_HEALING_POWDER, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_HEALING_POWDER, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_HEALING_POWDER)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

