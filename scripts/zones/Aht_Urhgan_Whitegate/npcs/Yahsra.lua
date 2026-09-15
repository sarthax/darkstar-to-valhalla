-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Yahsra
-- Type: Assault Mission Giver
-- !pos 120.967 0.161 -44.002 50
-----------------------------------
require("scripts/globals/keyitems")
package.loaded["scripts/zones/Aht_Urhgan_Whitegate/TextIDs"] = nil;
require("scripts/zones/Aht_Urhgan_Whitegate/TextIDs");
require("scripts/globals/besieged")
require("scripts/globals/missions")
require("scripts/globals/npc_util")
-----------------------------------
function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    -- 2026-08-19: getAssaultRank() caps the rank sent to the client's mission menu at
    -- ASSAULT_MAX_RANK (settings.lua) -- see scripts/globals/besieged.lua for why this is the
    -- right place to restrict which missions are offered.
    local rank = getMercenaryRank(player)
    local haveimperialIDtag
    local assaultPoints = player:getAssaultPoint(LEUJAOAM_ASSAULT_POINT)

    if player:hasKeyItem(IMPERIAL_ARMY_ID_TAG) then
        haveimperialIDtag = 1
    else
        haveimperialIDtag = 0
    end

    if (rank > 0) then
        player:startEvent(273, rank, haveimperialIDtag, assaultPoints, player:getCurrentAssault())
    else
        player:startEvent(279) -- no rank
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if csid == 273 then
        local selectiontype = bit.band(option, 0xF)
        if selectiontype == 1 then
            -- taken assault mission
            player:addAssault(bit.rshift(option, 4))
            player:delKeyItem(IMPERIAL_ARMY_ID_TAG)
            player:addKeyItem(LEUJAOAM_ASSAULT_ORDERS)
            player:messageSpecial(KEYITEM_OBTAINED, LEUJAOAM_ASSAULT_ORDERS)
        elseif selectiontype == 2 then
            -- purchased an item
            local item = bit.rshift(option, 14)
            local itemID = 0
            local price = 0
            local items =
            {
                [1]  = {itemid = 15970, price = 3000},
                [2]  = {itemid = 15775, price = 5000},
                [3]  = {itemid = 15521, price = 8000},
                [4]  = {itemid = 15884, price = 10000},
                [5]  = {itemid = 15490, price = 10000},
                [6]  = {itemid = 18408, price = 10000},
                [7]  = {itemid = 18485, price = 15000},
                [8]  = {itemid = 18365, price = 15000},
                [9]  = {itemid = 14933, price = 15000},
                [10] = {itemid = 16069, price = 20000},
                [11] = {itemid = 15606, price = 20000},
            }

            local choice = items[item]
            if choice and npcUtil.giveItem(player, choice.itemid) then
                -- 2026-09-15, real bug found live while fixing the Nyzul token gap: this was
                -- quoted as a STRING ("LEUJAOAM_ASSAULT_POINT") instead of the bare numeric
                -- global -- line 23's getAssaultPoint call above already uses it correctly
                -- unquoted. lua_tointeger() on a non-numeric string silently returns 0. Before
                -- lua_baseentity.cpp's own delAssaultPoint arg-order fix (region/points were
                -- reversed there), this string coerced to a "points" value of 0 and the real
                -- price ended up read as "region" -- never matching a valid 0-5 case, so no
                -- deduction ever happened at all. Fixed to the real bare constant either way.
                player:delAssaultPoint(LEUJAOAM_ASSAULT_POINT, choice.price)
            end
        end
    end
end

