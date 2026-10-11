-----------------------------------
-- Area: Northern San d'Oria (Woodworking)
--  NPC: Ephemeral Moogle
-- Type: Crystal Storage NPC
-- !pos -176.090 12.000 268.910 231
-----------------------------------
require("scripts/globals/ephemeral");
-----------------------------------

local triggerEvent = 913;
local tradeEvent = 915;
local failEvent = 917;

function onTrade(player,npc,trade)
    ephemeral.onTrade(player, trade, tradeEvent, failEvent);
end;

function onTrigger(player,npc)
    ephemeral.onTrigger(player, triggerEvent);
end;

function onEventUpdate(player,csid,option)
    ephemeral.onEventUpdate(player, csid, option, csid == tradeEvent);
end;

function onEventFinish(player,csid,option)
    ephemeral.onEventFinish(player, option, csid == tradeEvent);
end;
