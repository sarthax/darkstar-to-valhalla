-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Ayame (npc_list 17093447 = capture 17093448). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.01 23:37:18, dialog 7690, immediately followed by
-- "Obtained temporary item: a bottle of fighter's drink!" -- real item id 5386
-- (bottle of fighters drink, confirmed via id_bridge.py, exact LSB/Topaz id match).
-- Position (-258.000, 0.000, -338.000, r96) recovered from npclogger/database's raw capture row
-- for id 17093448 -- the row's 'name' field itself decoded as garbled ASCII, but x/y/z/r were
-- intact and the CapLog's own NPC-chat packet independently confirms this id is really Ayame.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_FIGHTERS_DRINK = 5386

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7675, true)
    if not player:hasItem(ITEM_FIGHTERS_DRINK, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_FIGHTERS_DRINK, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_FIGHTERS_DRINK)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

