-----------------------------------
-- Area: Port Bastok (Mog House)
-- NPC:  Symphonic Curator
-----------------------------------
require("scripts/globals/symphonic_curator");

function onTrade(player, npc, trade)
end;

function onTrigger(player, npc)
    symphonicCuratorTrigger(player, npc);
end;

function onEventUpdate(player, csid, option)
    symphonicCuratorUpdate(player, csid, option);
end;

function onEventFinish(player, csid, option)
    symphonicCuratorFinish(player, csid, option);
end;
