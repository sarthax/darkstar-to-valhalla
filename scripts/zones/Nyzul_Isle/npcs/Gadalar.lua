-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Gadalar (npc_list 17093450 = capture 17093451). Grants a one-time temp item.
-- Dialog 7679 ("Do you need me to light a fire under your sorry behind!?...").
-- Item unspecified in the source audit -- assigned from the shared Nyzul Isle vending-chest
-- pool (scripts/globals/nyzul/vending_box.lua), excluding ids already mapped to other HH NPCs.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_SOLDIERS_DRINK = 5391

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7679, true)
    if not player:hasItem(ITEM_SOLDIERS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_SOLDIERS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_SOLDIERS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

