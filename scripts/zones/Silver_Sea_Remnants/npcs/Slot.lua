-----------------------------------
-- Area: Silver Sea Remnants
-- NPC: Slot
-- trade card to pop NM
-----------------------------------
-- 2026-09-06: mirrors Arrapago Remnants' real, already-working npcs/Slot.lua convention exactly
-- (npcUtil.tradeHas, no DISAPPEAR call). Real mechanic per BG Wiki: trading a Remnants Card from
-- another Remnants area to a "Slot" spawns that zone's real Slot NM -- for Silver Sea, that's
-- "Don Poroggo" (real id 17088668, Topaz's own sql/mob_spawn_points.sql), spawned by trading a
-- Zhayolm Card. See IDs.lua's DON_POROGGO/SLOT comments for the real-position discrepancy still
-- unresolved (this zone may have two real Slot locations, same open question as Bhaflau).
-----------------------------------
require("scripts/zones/Silver_Sea_Remnants/IDs")
require("scripts/globals/npc_util")
-----------------------------------
function onTrade(player, npc, trade)
    if npcUtil.tradeHas(trade, 2375) then -- Zhayolm Card, confirmed real via id_bridge.py (SAME id on LSB and Topaz)
        local instance = npc:getInstance()
        SpawnMob(SilverSea.mobs.DON_POROGGO, instance):updateClaim(player)
        player:confirmTrade()
    end
end

function onTrigger(entity, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(entity, eventid, result)
end

