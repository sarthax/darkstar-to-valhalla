-----------------------------------
-- Area: Zeruhn Mines
--  NPC: Treasure Casket
-----------------------------------
require("scripts/globals/caskets");
-----------------------------------

function onTrigger(player, npc)
    caskets.onTrigger(player, npc);
end;

function onTrade(player, npc, trade)
    caskets.onTrade(player, npc, trade);
end;

function onEventUpdate(player, csid, option)
end;

function onEventFinish(player, csid, option)
    caskets.onEventFinish(player, csid, option);
end;
