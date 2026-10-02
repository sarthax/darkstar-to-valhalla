-----------------------------------
-- Area: Nyzul Isle
--  NPC: Vending Box
-- Notes: Lobby temp-item shop (npc_list 17093430), spends NYZUL_ISLE_ASSAULT_POINT tokens.
-- !pos -22.000 -4.000 -11.000
-----------------------------------
require("scripts/globals/nyzul/vending_box")
-----------------------------------
function onTrigger(player, npc)
    Nyzul.vendingBoxOnTrigger(player)
end

function onEventUpdate(player, csid, option)
    Nyzul.vendingBoxOnEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

