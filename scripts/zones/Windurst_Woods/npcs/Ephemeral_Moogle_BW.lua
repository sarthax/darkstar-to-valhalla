-----------------------------------
-- Area: Windurst Woods (Bonecraft)
--  NPC: Ephemeral Moogle
-- Type: Crystal Storage NPC
-- !pos -10.500 -5.250 -143.400 241
-----------------------------------
require("scripts/globals/ephemeral");
-----------------------------------

local triggerEvent = 895;
local tradeEvent = 897;
local failEvent = 899;

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
