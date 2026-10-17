-----------------------------------
-- Area: Rolanberry Fields (110)
--  NPC: Geomantic Reservoir (Geo-MND)
-- Text ids and event 15000 read from the client DAT (fresh pull 2026-10-16).
-----------------------------------
require("scripts/globals/geomantic_reservoir");
-----------------------------------

local cfg = {spell = "mnd", event = 15000, learns = 12250, nothing = 6424};

function onTrigger(player, npc)
    geomanticReservoir.onTrigger(player, cfg);
end;

function onEventUpdate(player, csid, option)
end;

function onEventFinish(player, csid, option)
    geomanticReservoir.onEventFinish(player, csid, option, cfg);
end;
