-----------------------------------
-- Area: Kazham
--  NPC: Atmacite Refiner -- first pass, UNTESTED in-game, no capture exists
-- Same 23915-byte refiner event as the city refiners [V]; params are the [H] city layout with nation unknown [D=0]
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {officerCsid = 314, refinerCsid = 316, kiMsg = 6391,
    -- atmacite menu text ids: this zone's client dialog.yml pulled 2026-10-09 [V]
    atmaMsg = {notEnough = 11074, infused = 11077, purged = 11079, swap = 11080, noInfuse = 11078, enriched = 11086, max = 11087}}; -- csids [V] decompiled from this zone's client events dat (no capture); kiMsg = KEYITEM_OBTAINED [V] dialog.yml pulled 2026-10-08; nation/city bits unknown [D=0]

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
