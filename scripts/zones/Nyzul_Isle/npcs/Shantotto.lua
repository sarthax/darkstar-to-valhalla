-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  NPC: Shantotto (npc_list 17093448 = capture 17093449). Grants a one-time temp item on trigger.
-- Line is CapLog 2025.05.01 23:35:29, dialog 7691 ("Why do these girls get to have all the
-- fun?..."), immediately followed by "Obtained temporary item: a bottle of strange juice!" --
-- real item id 5438 (bottle of strange juice, confirmed via id_bridge.py, exact LSB/Topaz id
-- match). An intervening "[NPCL] New: 17093189 (CelebratoryCon)" line sits between the chat and
-- the item-grant line in the raw log, but that's an unrelated mob spawning into range at the same
-- moment -- the CapLog's own dialog-id-to-item pairing pattern (identical for all 12 other
-- helper NPCs this session, always chat-line immediately followed by the grant) confirms Shantotto
-- is the source, not the coney.
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
local ITEM_STRANGE_JUICE = 5438

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    player:messageText(npc, 7676, true)
    if not player:hasItem(ITEM_STRANGE_JUICE, LOC_TEMPITEMS) then
        if player:addTempItem(ITEM_STRANGE_JUICE, 1) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, ITEM_STRANGE_JUICE)
        end
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

