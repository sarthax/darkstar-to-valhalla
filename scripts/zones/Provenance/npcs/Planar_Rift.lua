-----------------------------------
-- Area: Provenance
--  NPC: Planar Rift (Voidwatch) -- NM not built yet; shared fallback message.
-----------------------------------
require("scripts/globals/voidwatch_unbuilt");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    vwUnbuiltRift(player, "Asb, Provenance Watcher, Rukh, Sarbaz, Shah and Wazir");
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
