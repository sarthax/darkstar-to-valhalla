-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Curilla (npc_list 17093446 = capture 17093447). Grants a one-time temp item.
-- Dialog 7667 ("I was on my way to Castle Oztroja when some strange beastman captured me...").
-- Item unspecified in the source audit -- assigned from the shared Nyzul Isle vending-chest
-- pool (scripts/globals/nyzul/vending_box.lua), excluding ids already mapped to other HH NPCs.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_BRAVERS_DRINK = 5390

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7667, true)
    if not player:hasItem(ITEM_BRAVERS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_BRAVERS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_BRAVERS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

