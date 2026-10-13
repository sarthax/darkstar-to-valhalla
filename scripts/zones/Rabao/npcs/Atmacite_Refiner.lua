-----------------------------------
-- Area: Rabao
--  NPC: Atmacite Refiner -- first pass, UNTESTED in-game, no capture exists
-- Same 23915-byte refiner event as the city refiners [V]; params are the [H] city layout with nation unknown [D=0]
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {officerCsid = 14, refinerCsid = 16, kiMsg = 6413,
    -- atmacite menu text ids: this zone's client dialog.yml pulled 2026-10-09 [V]
    atmaMsg = {notEnough = 10831, infused = 10834, purged = 10836, swap = 10837, noInfuse = 10835, enriched = 10843, max = 10844}}; -- csids [V] decompiled from this zone's client events dat (no capture); kiMsg = KEYITEM_OBTAINED [V] dialog.yml pulled 2026-10-08; nation/city bits unknown [D=0]

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
