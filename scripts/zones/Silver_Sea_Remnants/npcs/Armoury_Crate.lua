-----------------------------------
-- Area: Silver Sea Remnants
-- NPC: Armoury Crate (Silver Sea)
-----------------------------------
-- 2026-10-01: aligned with Arrapago/Bhaflau. The fixed Floor-1 crate (SilverSea.npcs.ARMOURY_CRATE[1])
-- uses the same real temp-item pick menu (tempBoxTrigger/tempBoxFinish) as every other crate; its
-- only difference is the pre-picked guaranteed cell pool (salvageUtil.tempBoxPickCellItems).
-----------------------------------
require("scripts/zones/Silver_Sea_Remnants/IDs")
require("scripts/globals/status")
require("scripts/globals/salvage")
-----------------------------------
function onTrigger(player, npc)
    if npc:getID() == SilverSea.npcs.ARMOURY_CRATE[1] and npc:getLocalVar('prePicked') == 0 then
        salvageUtil.tempBoxPickCellItems(npc)
    end
    salvageUtil.tempBoxTrigger(player, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
    salvageUtil.tempBoxFinish(player, csid, option, npc)
end

