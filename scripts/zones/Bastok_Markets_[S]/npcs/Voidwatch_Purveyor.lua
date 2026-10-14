-----------------------------------
-- Area: Bastok_Markets_[S]
--  NPC: Voidwatch Purveyor -- first pass, UNTESTED in-game
-- Logic and evidence tags live in scripts/globals/voidwatch_purveyor.lua
-----------------------------------
require("scripts/globals/voidwatch_purveyor");

local CFG = {csid = 81, currency = 2};

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    vwpTrigger(player, CFG);
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
    vwpFinish(player, CFG, option);
end;
