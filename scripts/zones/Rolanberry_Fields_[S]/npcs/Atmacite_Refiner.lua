-----------------------------------
-- Area: Rolanberry_Fields_[S]
--  NPC: Atmacite Refiner -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {officerCsid = 9, refinerCsid = 8, kiMsg = 6391,
    -- csids = event ids of the client event dump [V]; kiMsg/atmaMsg ids: fresh mission_toolkit dialog.yml pull 2026-10-14 [V] (atmaMsg = cluster with the Bastok Markets layout; verify in game)
    atmaMsg = {notEnough = 8262, infused = 8265, purged = 8267, swap = 8268, noInfuse = 8266, enriched = 8274, max = 8275}};

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
