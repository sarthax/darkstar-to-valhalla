-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Naja Salaheem (npc_list 17093464 = capture 17093465). Grants a one-time temp item.
-- Dialog 7683 ("From an age long past I... But I should say no more...").
-- 2026-09-30 (user): dialog swapped with Mihli Aliapoh (17093453); was 7685.
-- Distinct from the unrelated Path-of-Darkness mob script of the same name under mobs/ --
-- name-based script dispatch looks in this zone's npcs/ folder, so no collision.
-- Item unspecified in the source audit -- assigned from the shared Nyzul Isle vending-chest
-- pool (scripts/globals/nyzul/vending_box.lua), excluding ids already mapped to other HH NPCs.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_RERAISE_SCROLL = 5436

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7683, true)
    if not player:hasItem(ITEM_RERAISE_SCROLL, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_RERAISE_SCROLL, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_RERAISE_SCROLL)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

