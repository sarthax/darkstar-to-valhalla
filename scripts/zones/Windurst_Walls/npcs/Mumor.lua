-----------------------------------
-- Area: Windurst Walls
-- NPC:  Mumor (Sunbreeze 2021 add-on stage cast; sells fireworks after the show, otherwise inert)
-----------------------------------
require("scripts/globals/settings");

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    if (isSunbreeze2021AddonEnabled == nil and not pcall(require, "scripts/globals/events/sunbreeze_2021_addon")) then return; end
    SUNBREEZE2021.vendorTrigger(player, npc, "Mumor");
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
