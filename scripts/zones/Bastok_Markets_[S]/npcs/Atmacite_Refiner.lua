-----------------------------------
-- Area: Bastok_Markets_[S]
--  NPC: Atmacite Refiner -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {grantPath = 2, nation = 2, city = 1, officerCsid = 80, refinerCsid = 79, kiMsg = 6391,
    -- csids = event ids of the client event dump [V]; kiMsg/atmaMsg ids: fresh mission_toolkit dialog.yml pull 2026-10-14 [V] (atmaMsg = cluster with the Bastok Markets layout; verify in game)
    atmaMsg = {notEnough = 13676, infused = 13679, purged = 13681, swap = 13682, noInfuse = 13680, enriched = 13688, max = 13689}};

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
