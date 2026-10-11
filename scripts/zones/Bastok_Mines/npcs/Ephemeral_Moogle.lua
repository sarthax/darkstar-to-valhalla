-----------------------------------
-- Area: Bastok Mines
--  NPC: Ephemeral Moogle
-- Type: Crystal Storage NPC
-- !pos 118.870 2.020 4.290 234
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
    ephemeral.onEventUpdate(player, csid, option, csid == tradeEvent);
end;

function onEventFinish(player,csid,option)
    ephemeral.onEventFinish(player, option, csid == tradeEvent);
end;
