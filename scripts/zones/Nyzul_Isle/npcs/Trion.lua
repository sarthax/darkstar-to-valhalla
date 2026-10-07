-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Trion (npc_list 17093443 = capture 17093444). Grants a one-time temp item on trigger.
-- Dialog 7668 ("Do you adventurers never tire of these pointless contests of strength?...").
-- Item unspecified in the source audit -- assigned from the shared Nyzul Isle vending-chest
-- pool (scripts/globals/nyzul/vending_box.lua), excluding ids already mapped to other HH NPCs.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_BARBARIANS_DRINK = 5385

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7668, true)
    if not player:hasItem(ITEM_BARBARIANS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_BARBARIANS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_BARBARIANS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

