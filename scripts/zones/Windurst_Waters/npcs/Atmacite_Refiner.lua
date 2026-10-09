-----------------------------------
-- Area: Windurst_Waters
--  NPC: Atmacite Refiner (Voidwatch Refiner) -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {grantPath = 3, nation = 3, city = 3, officerCsid = 1024, refinerCsid = 1023, kiMsg = 6550,
    -- atmacite menu text ids: zone 238 client dialog.yml pulled 2026-10-09 [V]; other zones need their own pull
    atmaMsg = {notEnough = 15709, infused = 15712, purged = 15714, noInfuse = 15713, enriched = 15721, max = 15722}}; -- csids [C] captures 708-721/699; kiMsg = KEYITEM_OBTAINED from this zone's TextIDs.lua [V]

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
