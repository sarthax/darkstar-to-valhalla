-----------------------------------
-- Area: Bhaflau Remnants
-- NPC: Armoury Crate (Bhaflau)
-----------------------------------
-- 2026-09-09: real fix -- was granting the fixed Floor-1 crate's items directly via
-- player:addTreasure() with no menu at all, unconditionally, on every trigger -- helpful for
-- testing but not the real mechanic. User confirmed (and Arrapago Remnants' own real
-- Armoury_Crate.lua already proved) the fixed crate uses the SAME real temp-item pick-one-at-a-
-- time menu (tempBoxTrigger/tempBoxFinish) as every other Armoury Crate -- the only real
-- difference is its item POOL (guaranteed real cells via tempBoxPickCellItems, not the pool's
-- random drinks). Rebuilt to match Arrapago's own real file exactly.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/status")
require("scripts/globals/salvage")
-----------------------------------
function onTrigger(player, npc)
    if npc:getID() == Bhaflau.npcs.ARMOURY_CRATE[1] and npc:getLocalVar('prePicked') == 0 then
        salvageUtil.tempBoxPickCellItems(npc)
    end
    salvageUtil.tempBoxTrigger(player, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
    salvageUtil.tempBoxFinish(player, csid, option, npc)
end

