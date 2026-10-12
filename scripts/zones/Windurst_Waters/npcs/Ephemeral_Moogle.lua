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
local ITEM_OBTAINED_MSG = 6547; -- zone-local (client dialog.yml); bare ITEM_OBTAINED global is polluted across zones
local failEvent = 1100;

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
