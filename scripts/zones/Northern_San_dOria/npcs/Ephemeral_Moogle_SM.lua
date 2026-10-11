-----------------------------------
-- Area: Northern San d'Oria (Smithing)
--  NPC: Ephemeral Moogle
-- Type: Crystal Storage NPC
-- !pos -186.440 12.000 140.310 231
-----------------------------------
require("scripts/globals/ephemeral");
-----------------------------------

local triggerEvent = 914;
local tradeEvent = 916;
local failEvent = 918;

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
