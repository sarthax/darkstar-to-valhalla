-----------------------------------
-- Area: Tavnazian_Safehold
--  NPC: Owain (Voidwatch officer) -- first pass, UNTESTED in-game, no capture exists
-- Event reads params 0..2 like the city officers [V]; value meanings are [H]/[D], see scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {grantPath = 6, officerCsid = 626, refinerCsid = 627, kiMsg = 6391}; -- csids [V] decompiled from this zone's client events dat (no capture); kiMsg = KEYITEM_OBTAINED [V] dialog.yml pulled 2026-10-08; nation/city bits unknown [D=0]

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
