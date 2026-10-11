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
local ITEM_OBTAINED_MSG = 6388; -- zone-local (client dialog.yml); bare ITEM_OBTAINED global is polluted across zones
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
    ephemeral.onEventFinish(player, option, csid == tradeEvent, ITEM_OBTAINED_MSG);
end;
