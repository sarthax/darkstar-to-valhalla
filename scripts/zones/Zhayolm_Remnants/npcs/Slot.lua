-----------------------------------
-- Area: Zhayolm Remnants
-- NPC: Slot
-- trade card to pop NM
-----------------------------------
-- 2026-09-04: mirrors Arrapago/Bhaflau/Silver Sea Remnants' real, already-working npcs/Slot.lua
-- convention exactly (npcUtil.tradeHas, no DISAPPEAR call). Real mechanic per BG Wiki/ffxiclopedia
-- route table: trading a Silver Sea Card (real item id 2378, confirmed SAME on LSB and Topaz via
-- id_bridge.py) spawns this zone's real Slot NM, Jakko.
-----------------------------------
require("scripts/zones/Zhayolm_Remnants/IDs")
require("scripts/globals/npc_util")
-----------------------------------
function onTrade(player, npc, trade)
    if npcUtil.tradeHas(trade, 2378) then -- Silver Sea Card
        local instance = npc:getInstance()
        SpawnMob(Zhayolm.mobs.JAKKO, instance):updateClaim(player)
        player:confirmTrade()
    end
end

function onTrigger(entity, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(entity, eventid, result)
end

