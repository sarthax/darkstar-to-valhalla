-----------------------------------
-- Area: Bastok_Markets
--  NPC: Atmacite Refiner (Voidwatch Refiner) -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {grantPath = 2, nation = 2, city = 1, officerCsid = 9, refinerCsid = 8, kiMsg = 6391,
    -- atmacite menu text ids: zone 235 client dialog.yml pulled 2026-10-09 [V]
    atmaMsg = {notEnough = 12906, infused = 12909, purged = 12911, noInfuse = 12910, enriched = 12918, max = 12919}}; -- csids [C] captures 708-721/699; kiMsg = KEYITEM_OBTAINED from this zone's TextIDs.lua [V]

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    vwoRefinerTrigger(player, CFG);
end;

function onEventUpdate(player,csid,option)
    vwoAtmaUpdate(player, CFG, option);
end;

function onEventFinish(player,csid,option)
    vwoRefinerFinish(player, CFG, option);
end;
