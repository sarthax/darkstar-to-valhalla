-----------------------------------
-- Area: Arrapago Remnants
-- NPC: Slot
-- trade card to pop NM
-----------------------------------
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/npc_util")
-----------------------------------
function onTrade(player, npc, trade)
    -- 2026-09-06: real fix -- was checking item 2377 (bhaflau_card, a leftover copy-paste from
    -- Bhaflau Remnants' own Slot.lua) instead of this zone's real card, 2376 (arrapago_card) --
    -- confirmed both real, distinct ids in item_basic.sql. This is why trading the real Arrapago
    -- Card here never registered.
    if npcUtil.tradeHas(trade, 2376) then
        local instance = npc:getInstance()
        SpawnMob(Arrapago.mobs[2][2].princess, instance):updateClaim(player)
        player:confirmTrade()
    end
end

function onTrigger(entity, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(entity, eventid, result)
end

