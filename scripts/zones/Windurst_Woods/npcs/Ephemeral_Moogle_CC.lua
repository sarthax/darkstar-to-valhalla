-----------------------------------
-- Area: Windurst Woods (Clothcraft)
--  NPC: Ephemeral Moogle
-- Type: Crystal Storage NPC
-- !pos -34.840 -1.250 -114.490 241
-----------------------------------
require("scripts/globals/ephemeral");
-----------------------------------

local triggerEvent = 896;
local tradeEvent = 898;
local failEvent = 900;

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
