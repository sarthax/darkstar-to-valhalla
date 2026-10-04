-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Excenmille (npc_list 17093455 = capture 17093456). Grants a one-time temp item.
-- Dialog 7674 ("Where is my liege? Where is Prince Trion!?...").
-- Item unspecified in the source audit -- assigned from the shared Nyzul Isle vending-chest
-- pool (scripts/globals/nyzul/vending_box.lua), excluding ids already mapped to other HH NPCs.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_SPRINTERS_DRINK = 5397

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7674, true)
    if not player:hasItem(ITEM_SPRINTERS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_SPRINTERS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_SPRINTERS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

