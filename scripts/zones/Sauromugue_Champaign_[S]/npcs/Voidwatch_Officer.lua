-----------------------------------
-- Area: Sauromugue_Champaign_[S]
--  NPC: Voidwatch Officer -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {officerCsid = 16, refinerCsid = 15, kiMsg = 6391,
    -- csids = event ids of the client event dump [V]; kiMsg/atmaMsg ids: fresh mission_toolkit dialog.yml pull 2026-10-14 [V] (atmaMsg = cluster with the Bastok Markets layout; verify in game)
    atmaMsg = {notEnough = 8990, infused = 8993, purged = 8995, swap = 8996, noInfuse = 8994, enriched = 9002, max = 9003}};

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    vwoOfficerTrigger(player, CFG);
end;

function onEventUpdate(player,csid,option)
    vwoOfficerUpdate(player, CFG, option);
end;

function onEventFinish(player,csid,option)
    vwoOfficerFinish(player, CFG, option);
end;
