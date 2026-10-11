-----------------------------------
-- Area: Bastok Markets
--  NPC: Ephemeral Moogle
-- Type: Crystal Storage NPC
-- !pos -219.820 -6.820 -63.250 235
-----------------------------------
require("scripts/globals/ephemeral");
-----------------------------------

local triggerEvent = 617;
local tradeEvent = 618;
local failEvent = 619;

function onTrade(player,npc,trade)
    ephemeral.onTrade(player, trade, tradeEvent, failEvent);
end;

function onTrigger(player,npc)
    ephemeral.onTrigger(player, triggerEvent);
end;

function onEventUpdate(player,csid,option)
    ephemeral.onEventUpdate(player);
end;

function onEventFinish(player,csid,option)
    ephemeral.onEventFinish(player, option, csid == tradeEvent);
end;
