-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23l, LSB: DOOR_3_SW_ENTRANCE)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23l.lua
-- ("3rd Floor SW door"). Real dual gate: onTrigger checks stage==3/progress==2 directly (not just
-- the unSealed flag) before even attempting the event -- LSB's own real pattern for this
-- particular door. Opening it seals nothing else but unseals the South Center door (_23r) and
-- spawns the last 10 Black Pudding.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/status")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
function onTrigger(player, npc)
    local instance = npc:getInstance()
    if instance and instance:getStage() == 3 and instance:getProgress() == 2 then
        player:startEvent(300)
    else
        player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
    if csid == 300 and option == 1 then
        local instance = npc:getInstance()

        if instance and doorUtil.onDoorOpen(npc, nil, 6) then
            doorUtil.unsealDoors(instance, Bhaflau.npcs.DOOR._23r)
            doorUtil.spawnGroup(instance, { doorUtil.slice(Bhaflau.mobs.BLACK_PUDDING, 25, 34) })
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

