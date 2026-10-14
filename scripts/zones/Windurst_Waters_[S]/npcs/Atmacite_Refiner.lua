-----------------------------------
-- Area: Windurst_Waters_[S]
--  NPC: Atmacite Refiner -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {grantPath = 3, nation = 3, city = 3, officerCsid = 47, refinerCsid = 46, kiMsg = 6391,
    -- csids = event ids of the client event dump [V]; kiMsg/atmaMsg ids: fresh mission_toolkit dialog.yml pull 2026-10-14 [V] (atmaMsg = cluster with the Bastok Markets layout; verify in game)
    atmaMsg = {notEnough = 13936, infused = 13939, purged = 13941, swap = 13942, noInfuse = 13940, enriched = 13948, max = 13949}};

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
