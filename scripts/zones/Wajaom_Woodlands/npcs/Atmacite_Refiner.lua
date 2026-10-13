-----------------------------------
-- Area: Wajaom_Woodlands
--  NPC: Atmacite Refiner -- first pass, UNTESTED in-game, no capture exists
-- Same 23915-byte refiner event as the city refiners [V]; params are the [H] city layout with nation unknown [D=0]
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {grantPath = 7, officerCsid = 23, refinerCsid = 24, kiMsg = 6391,
    -- atmacite menu text ids: this zone's client dialog.yml pulled 2026-10-09 [V]
    atmaMsg = {notEnough = 8780, infused = 8783, purged = 8785, swap = 8786, noInfuse = 8784, enriched = 8792, max = 8793}}; -- csids [V] decompiled from this zone's client events dat (no capture); kiMsg = KEYITEM_OBTAINED [V] dialog.yml pulled 2026-10-08; nation/city bits unknown [D=0]

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    vwoRefinerTrigger(player, CFG);
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
    vwoRefinerFinish(player, CFG, option);
end;
