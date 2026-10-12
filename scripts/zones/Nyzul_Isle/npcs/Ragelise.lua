-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Ragelise (npc_list 17093465 = capture 17093466). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.01 23:56:30, dialog 7702 ("Did that curious black-and-white hand lead
-- you here as well?..."), immediately followed by "Obtained temporary item: a flask of mana
-- mist!" -- real item id 5833 (flask of mana mist, confirmed via id_bridge.py, exact LSB/Topaz
-- id match).
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_MANA_MIST = 5833

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7687, true)
    if not player:hasItem(ITEM_MANA_MIST, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_MANA_MIST, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_MANA_MIST)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

