-----------------------------------
-- Area: Bhaflau Remnants
-- NPC: Slot
-- trade card to pop NM
-----------------------------------
-- 2026-09-05: mirrors Arrapago Remnants' real, already-working npcs/Slot.lua convention exactly
-- (npcUtil.tradeHas, no DISAPPEAR call -- Topaz's real established pattern, not LSB's). Real
-- mechanic per BG Wiki/ffxiclopedia -- trading a Remnants Card from another Remnants area to a
-- "Slot" spawns that zone's real Slot NM. For Bhaflau, that NM is confirmed real (capture + wiki
-- triangulated, see IDs.lua's DEMENTED_JALAAWA comment): "Demented Jalaawa", spawned by trading
-- an Arrapago Card (real item id 2376, confirmed same on LSB and Topaz via id_bridge.py; matches
-- Arrapago's own real Slot.lua using 2377/Bhaflau Card for its own NM).
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/npc_util")
-----------------------------------
function onTrade(player, npc, trade)
    if npcUtil.tradeHas(trade, 2376) then -- Arrapago Card
        local instance = npc:getInstance()
        SpawnMob(Bhaflau.mobs.DEMENTED_JALAAWA, instance):updateClaim(player)
        player:confirmTrade()
    end
end

function onTrigger(entity, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(entity, eventid, result)
end

