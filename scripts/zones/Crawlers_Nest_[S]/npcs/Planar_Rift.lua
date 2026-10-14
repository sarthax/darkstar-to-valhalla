-----------------------------------
-- Area: Crawlers_Nest_[S]
--  NPC: Planar Rift (Voidwatch) -- NM not built yet; shared fallback message.
-----------------------------------
require("scripts/globals/voidwatch_unbuilt");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    vwUnbuiltRift(player, "Nympha Eunomia");
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
