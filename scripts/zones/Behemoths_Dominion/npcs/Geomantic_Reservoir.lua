-----------------------------------
-- Area: Behemoths Dominion (127)
--  NPC: Geomantic Reservoir (Geo-DEX)
-- Text ids and event 15000 read from the client DAT (fresh pull 2026-10-16).
-----------------------------------
require("scripts/globals/geomantic_reservoir");
-----------------------------------

local cfg = {spell = "dex", event = 15000, learns = 11518, nothing = 6402};

function onTrigger(player, npc)
    geomanticReservoir.onTrigger(player, cfg);
end;

function onEventUpdate(player, csid, option)
end;

function onEventFinish(player, csid, option)
    geomanticReservoir.onEventFinish(player, csid, option, cfg);
end;
