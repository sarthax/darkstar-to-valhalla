-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Lehko Habhoka (npc_list 17093454 = capture 17093455). Grants a one-time temp item on
-- trigger. Line is CapLog 2025.05.01 23:55:01, dialog 7699 ("Our paths cross again, dear
-- Siknawz..."), immediately followed by "Obtained temporary item: a bottle of assassin's drink!"
-- -- real item id 5388 (bottle of assassins drink, confirmed via id_bridge.py, exact LSB/Topaz id
-- match).
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_ASSASSINS_DRINK = 5388

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7684, true)
    if not player:hasItem(ITEM_ASSASSINS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_ASSASSINS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_ASSASSINS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

