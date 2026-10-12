-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Rughadjeen (npc_list 17093449 = capture 17093450). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.01 23:44:19, dialog 7693, immediately followed by
-- "Obtained temporary item: a bottle of mana boost!" -- real item id 4200
-- (bottle of mana boost, confirmed via id_bridge.py, exact LSB/Topaz id match; not to be confused
-- with the separate "mana booster" item at ids 2242/8481).
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_MANA_BOOST = 4200

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7678, true)
    if not player:hasItem(ITEM_MANA_BOOST, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_MANA_BOOST, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_MANA_BOOST)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

