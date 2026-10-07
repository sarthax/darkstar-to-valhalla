-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Ajido-Marujido (npc_list 17093445 = capture 17093446). Grants a one-time temp item.
-- Dialog 7670 ("This building is simply-wimply fascinating!...").
-- Item unspecified in the source audit -- assigned from the shared Nyzul Isle vending-chest
-- pool (scripts/globals/nyzul/vending_box.lua), excluding ids already mapped to other HH NPCs.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_ORACLES_DRINK = 5387

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7670, true)
    if not player:hasItem(ITEM_ORACLES_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_ORACLES_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_ORACLES_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

