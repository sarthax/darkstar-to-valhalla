-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Klara (npc_list 17093456 = capture 17093457). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.01 23:55:43, dialog 7701 ("Hail, Siknawz! What brings you here?..."),
-- immediately followed by "Obtained temporary item: a bottle of spy's drink!" -- real item id
-- 5389 (bottle of spys drink, confirmed via id_bridge.py, exact LSB/Topaz id match).
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_SPYS_DRINK = 5389

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7686, true)
    if not player:hasItem(ITEM_SPYS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_SPYS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_SPYS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

