-----------------------------------
-- Area: Southern San d'Oria
--  NPC: Ephemeral Moogle
-- Type: Crystal Storage NPC
-- !pos -185.750 -2.000 -3.860 230
-----------------------------------
require("scripts/globals/ephemeral");
-----------------------------------

local triggerEvent = 3549;
local tradeEvent = 3550;
local failEvent = 3551;

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
