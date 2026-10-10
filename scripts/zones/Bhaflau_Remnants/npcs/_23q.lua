-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23q, LSB: DOOR_3_SE_ENTRANCE)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23q.lua
-- ("3rd Floor SE door"). Real dual gate: onTrigger checks stage==3/progress==4 directly. Opening
-- it unseals the South Center door (_23r) and spawns 10 Black Pudding.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/status")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
function onTrigger(player, npc)
    local instance = npc:getInstance()
    if instance and instance:getStage() == 3 and instance:getProgress() == 4 then
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
            doorUtil.spawnGroup(instance, { doorUtil.slice(Bhaflau.mobs.BLACK_PUDDING, 15, 24) })
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

