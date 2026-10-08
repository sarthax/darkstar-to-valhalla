-----------------------------------
-- Area: Windurst_Waters
--  NPC: Voidwatch Officer (Voidwatch Officer) -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {nation = 3, city = 3, officerCsid = 1024, refinerCsid = 1023, kiMsg = 6550}; -- csids [C] captures 708-721/699; kiMsg = KEYITEM_OBTAINED from this zone's TextIDs.lua [V]

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
