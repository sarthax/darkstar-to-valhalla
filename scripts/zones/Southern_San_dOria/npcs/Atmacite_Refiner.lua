-----------------------------------
-- Area: Southern_San_dOria
--  NPC: Atmacite Refiner (Voidwatch Refiner) -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {grantPath = 1, nation = 1, city = 2, officerCsid = 963, refinerCsid = 962, kiMsg = 6435,
    atmaMsg = {notEnough = 13990, infused = 13993, purged = 13995, swap = 13996, noInfuse = 13994, enriched = 14002, max = 14003}}; -- atmaMsg [V] dialog.yml pulled 2026-10-09; -- csids [C] captures 708-721/699; kiMsg = KEYITEM_OBTAINED from this zone's TextIDs.lua [V]

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
