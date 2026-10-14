-----------------------------------
-- Area: Sauromugue_Champaign
--  NPC: Planar Rift (Voidwatch) -- NM not built yet; shared fallback message.
-----------------------------------
require("scripts/globals/voidwatch_unbuilt");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    vwUnbuiltRift(player, "Goji");
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
