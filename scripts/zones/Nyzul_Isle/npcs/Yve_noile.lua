-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Yve'noile (npc_list 17093462 = capture 17093463). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.01 23:26:48, dialog 7688, immediately followed by
-- "Obtained temporary item: a bottle of cleric's drink!" -- real item id 5395
-- (bottle of clerics drink, confirmed via id_bridge.py, exact LSB/Topaz id match).
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_CLERICS_DRINK = 5395

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7673, true)
    if not player:hasItem(ITEM_CLERICS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_CLERICS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_CLERICS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

