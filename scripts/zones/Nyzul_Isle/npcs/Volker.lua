-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Volker (npc_list 17093444 = capture 17093445). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.01 23:25:30, dialog 7684 ("I thought I'd seen everything, but the nature
-- of this tower is a mystery to me."), immediately followed in the same log line by
-- "Obtained temporary item: a bottle of monarch's drink!" -- real item id 5393
-- (bottle_of_monarchs_drink, confirmed via id_bridge.py, exact LSB/Topaz id match) and text
-- VENDING_ITEM_OBTAINED (7344, "Obtained temporary item: <item>!", Nyzul_Isle/IDs.lua) matches the
-- capture's wording exactly.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_MONARCHS_DRINK = 5393

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7669, true)
    if not player:hasItem(ITEM_MONARCHS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_MONARCHS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_MONARCHS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

