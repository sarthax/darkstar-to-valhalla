-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Fablinix (npc_list 17093466 = capture 17093467). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.02 00:08:36, dialog 7703 ("Fab doesn't know how he got here..."),
-- immediately followed by "Obtained temporary item: a pair of lucid wings I!" -- real item id
-- 5834 (pair of lucid wings i, confirmed via id_bridge.py, exact LSB/Topaz id match; distinct
-- from "lucid wings II" at id 6475). Appears only in this capture's 6th-battlefield (2nd) run.
-- POSITION: real spawn packet never carried position data (x/y/z=0 in capture). 2026-09-28: user
-- supplied real live-observed position (-406,0,473), Mumor floor Room 1 -- npc_list updated.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_LUCID_WINGS_I = 5834

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7688, true)
    if not player:hasItem(ITEM_LUCID_WINGS_I, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_LUCID_WINGS_I, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_LUCID_WINGS_I)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

