-----------------------------------
-- Area: Windurst Walls
-- NPC:  Sunbreeze Moogle (event guide, add-on; row 17756356 renamed so it does not run the Mog House Moogle script)
-- Instruction lines = client dialog ids 10004, 9984, 9970, 9971, 9985, 9986, 9968 (capture 479 order); server id = client id + TEXT_OFFSET.
-----------------------------------
require("scripts/globals/settings");

local INSTRUCTIONS = { 10004, 9984, 9970, 9971, 9985, 9986, 9968 };

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    if (isSunbreeze2021AddonEnabled == nil and not pcall(require, "scripts/globals/events/sunbreeze_2021_addon")) then return; end
    if (not isSunbreeze2021AddonEnabled()) then return; end
    local off = SUNBREEZE2021.TEXT_OFFSET[239];
    for _, id in ipairs(INSTRUCTIONS) do
        player:showText(npc, id + off);
    end
end;

function onEventUpdate(player,csid,option)
end;

function onEventFinish(player,csid,option)
end;
