-----------------------------------
-- Area: Al_Zahbi
--  NPC: Voidwatch Purveyor -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_purveyor.lua
-----------------------------------
require("scripts/globals/voidwatch_purveyor");

-- two Purveyors in this zone; lower npc id = event 291, higher = 292 [V]
local CSIDS = {291, 292};
local CURRENCY = 1;

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    local csid = CSIDS[1];
    if (npc:getID() ~= 16974380) then
        csid = CSIDS[2];
    end
    vwpTrigger(player, {csid = csid, currency = CURRENCY});
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
    vwpFinish(player, {csid = csid, currency = CURRENCY}, option);
end;
