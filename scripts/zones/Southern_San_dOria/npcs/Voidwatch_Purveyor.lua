-----------------------------------
-- Area: Southern_San_dOria
--  NPC: Voidwatch Purveyor -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_purveyor.lua
-----------------------------------
require("scripts/globals/voidwatch_purveyor");

-- two Purveyors in this zone; lower npc id = event 975, higher = 976 [V]
local CSIDS = {975, 976};
local CURRENCY = 0;

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    local csid = CSIDS[1];
    if (npc:getID() ~= 17719636) then
        csid = CSIDS[2];
    end
    vwpTrigger(player, {csid = csid, currency = CURRENCY});
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
    vwpFinish(player, {csid = csid, currency = CURRENCY}, option);
end;
