-----------------------------------
-- Area: Meriphataud_Mountains
--  NPC: Mog-Tablet
-- Mog Tablets / Super Kupowers (see scripts/globals/mog_tablets.lua)
-----------------------------------
require("scripts/globals/mog_tablets");
-----------------------------------

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    MOG_TABLET.onTabletTrigger(player,npc);
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
