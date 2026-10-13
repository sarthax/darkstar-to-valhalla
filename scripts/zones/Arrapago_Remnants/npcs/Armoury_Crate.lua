-----------------------------------
-- Area: Arrapago Remnants
-- NPC: Armoury Crate (Arrapago)
-----------------------------------
-- 2026-09-06: real fix -- user confirmed the fixed Floor-1 crate uses the same real temp-item
-- pick-one-at-a-time menu (tempBoxTrigger/tempBoxFinish) as the drop-pool caskets, NOT a no-menu
-- unconditional player:addTreasure() list. What's different about the fixed crate is only its item
-- pool (guaranteed real cells, not the pool's random drinks) -- so it now pre-picks its cell items
-- via salvageUtil.tempBoxPickCellItems (setting prePicked=1, same real localvar tempBoxTrigger
-- already checks to skip its own random drink picker) and then shares the exact same real menu
-- flow as every other Armoury_Crate-named npc.
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/status")
require("scripts/globals/salvage")
-----------------------------------
function onTrigger(player, npc)
    if npc:getID() == Arrapago.npcs.ARMOURY_CRATE[1] and npc:getLocalVar('prePicked') == 0 then
        salvageUtil.tempBoxPickCellItems(npc)
    end
    salvageUtil.tempBoxTrigger(player, npc)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
    salvageUtil.tempBoxFinish(player, csid, option, npc)
end

