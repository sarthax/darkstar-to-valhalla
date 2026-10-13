-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Cornelia (npc_list 17093458 = capture 17093459). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.02 00:08:25, dialog 7705 ("I've always wanted to leave dusty old
-- Bastok..."), immediately followed by "Obtained temporary item: a dusty wing!" -- real item id
-- 5440 (dusty wing, confirmed via id_bridge.py exact name match). Appears only in this capture's
-- 6th-battlefield (2nd) run.
-- POSITION: real spawn packet never carried position data (x/y/z=0 in capture). 2026-09-28: user
-- supplied real live-observed position (-380,0,460), Mumor floor Room 1 -- npc_list updated.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_DUSTY_WING = 5440

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7690, true)
    if not player:hasItem(ITEM_DUSTY_WING, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_DUSTY_WING, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_DUSTY_WING)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

