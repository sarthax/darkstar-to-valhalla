-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Verena (npc_list 17093457 = capture 17093458). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.02 00:09:04, dialog 7689 ("You're fighting ever so bravely..."),
-- 2026-09-29: dialog id corrected from 7704 to 7689 (-15 shift, confirmed system-wide
-- by user re-verification against a fresh source; applied to every HH reward NPC).
-- immediately followed by "Obtained temporary item: a dusty potion!" -- real item id 5431
-- (dusty potion, confirmed via id_bridge.py exact name match). Appears only in this capture's
-- 6th-battlefield (2nd) run.
-- POSITION: real spawn packet never carried position data (x/y/z=0 in capture). 2026-09-28: user
-- supplied real live-observed position (-379,0,379), Mumor floor Room 1 -- npc_list updated.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_DUSTY_POTION = 5431

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7689, true)
    if not player:hasItem(ITEM_DUSTY_POTION, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_DUSTY_POTION, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_DUSTY_POTION)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

