-----------------------------------
-- Area: Ru'Lude Gardens
-- NPC:  Artisan Moogle (npc_list name is 'artisanMoogle')
-- Mog Sack purchase / expansion and the daily Scroll of Instant Warp (item 4181).
-- Ported from Topaz scripts/globals/artisan.lua; csid 10162 is the Ru'Lude event in the client DAT.
-- @zone 243
-- !pos 52.109 9 -50.085
-----------------------------------
package.loaded["scripts/zones/RuLude_Gardens/TextIDs"] = nil;
-----------------------------------
require("scripts/globals/status");
require("scripts/zones/RuLude_Gardens/TextIDs");

local CSID_ARTISAN    = 10162;
local SACK_COST       = 9980;
local SACK_BASE_SIZE  = 30;
local SCROLL_ITEM     = 4181;
local MENU_EXPAND     = 0x8;
local MENU_AEXPAND    = 0x2;

local function scrollAvailable(player)
    return (player:getVar("[artisan]nextScroll") < getMidnight()) and 1 or 0;
end

local function sackDisplaySize(player)
    local size = player:getContainerSize(LOC_MOGSACK);
    if (size > 0) then
        size = size + 1;
    end
    return size;
end

function onTrade(player,npc,trade)
end;

function onTrigger(player,npc)
    local menuMask = 0;
    local sackSize = player:getContainerSize(LOC_MOGSACK);
    local visited = ((sackSize > 0 or player:getVar("[artisan]visited") > 0) and 1) or 0;

    if (visited == 0) then
        player:setVar("[artisan]visited", 1);
    end
    if (sackSize > 0) then
        sackSize = sackSize + 1;
    else
        menuMask = MENU_EXPAND + MENU_AEXPAND;
    end
    player:startEvent(CSID_ARTISAN, 0, 0, 0, sackSize, 0, 0, menuMask, visited);
end;

function onEventUpdate(player,csid,option)
    if (option == 1) then -- buy sack
        if (player:getGil() >= SACK_COST and player:getContainerSize(LOC_MOGSACK) == 0) then
            player:delGil(SACK_COST);
            player:changeContainerSize(LOC_MOGSACK, SACK_BASE_SIZE);
            player:setVar("[artisan]visited", 0);
            player:updateEvent(0, 0, 0, SACK_BASE_SIZE + 1, 0, 0, 0, 2);
        end
    elseif (option == 2) then -- expand sack to match the gobbiebag
        local sackSize = player:getContainerSize(LOC_MOGSACK);
        local bagSize = player:getContainerSize(LOC_INVENTORY);
        local bagCanUpgrade = (bagSize < 80 and 1) or 0;
        if (sackSize < bagSize and sackSize > 0) then
            player:changeContainerSize(LOC_MOGSACK, bagSize - sackSize);
            player:updateEvent((bagSize - 30) / 5, 0, 0, player:getContainerSize(LOC_MOGSACK) + 1, 0, 0, 2, 0);
        else
            player:updateEvent(0, 0, 0, 0, 0, 0, bagCanUpgrade, 0);
        end
    elseif (option == 3) then -- client asks for sack size + scroll status
        player:updateEvent(0, 0, 0, sackDisplaySize(player), 0, 0, 0, scrollAvailable(player));
    elseif (option == 4) then -- main dialogue
        player:updateEvent(0, 0, player:getGil(), sackDisplaySize(player), 0, 0, 0, scrollAvailable(player));
    end
end;

function onEventFinish(player,csid,option)
    if (option == 99 and player:getVar("[artisan]nextScroll") < getMidnight()) then -- daily scroll
        if (player:addItem(SCROLL_ITEM)) then
            player:messageSpecial(ITEM_OBTAINED, SCROLL_ITEM);
            player:setVar("[artisan]nextScroll", getMidnight());
        else
            player:messageSpecial(ITEM_CANNOT_BE_OBTAINED, SCROLL_ITEM);
        end
    end
end;
