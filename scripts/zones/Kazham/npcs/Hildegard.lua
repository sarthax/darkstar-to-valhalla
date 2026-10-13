-----------------------------------
-- Area: Kazham
--  NPC: Hildegard (Voidwatch officer) -- first pass, UNTESTED in-game, no capture exists
-- Sub-quest NPC (Ashen path): no abyssite grant; the VW Op quest flags are NOT implemented
-- Event reads params 0..2 like the city officers [V]; value meanings are [H]/[D], see scripts/globals/voidwatch_officer.lua
-----------------------------------
require("scripts/globals/voidwatch_officer");

local CFG = {officerCsid = 314, refinerCsid = 316, kiMsg = 6391}; -- csids [V] decompiled from this zone's client events dat (no capture); kiMsg = KEYITEM_OBTAINED [V] dialog.yml pulled 2026-10-08; nation/city bits unknown [D=0]

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
