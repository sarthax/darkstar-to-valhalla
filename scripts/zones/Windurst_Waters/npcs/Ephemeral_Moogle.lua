-----------------------------------
-- Area: Windurst Waters
--  NPC: Ephemeral Moogle
-- Type: Crystal Storage NPC
-- !pos -117.250 -2.000 60.890 238
-----------------------------------
require("scripts/globals/ephemeral");
-----------------------------------

local triggerEvent = 1098;
local tradeEvent = 1099;
local failEvent = 1100;

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
