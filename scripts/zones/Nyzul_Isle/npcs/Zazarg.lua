-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Zazarg (npc_list 17093451 = capture 17093452). Grants a one-time temp item.
-- Dialog 7680 ("No one will fight your battles for you. Onward! Onward, you fools! Gahahaha!...").
-- Item unspecified in the source audit -- assigned from the shared Nyzul Isle vending-chest
-- pool (scripts/globals/nyzul/vending_box.lua), excluding ids already mapped to other HH NPCs.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_CHAMPIONS_DRINK = 5392

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7680, true)
    if not player:hasItem(ITEM_CHAMPIONS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_CHAMPIONS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_CHAMPIONS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

