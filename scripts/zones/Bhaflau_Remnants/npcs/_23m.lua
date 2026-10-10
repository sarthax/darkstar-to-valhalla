-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23m, LSB: DOOR_3_WEST_EXIT)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23m.lua
-- ("3rd Floor Central West Door to Portal"). Opening this seals the East exit (_23p) and marks
-- stageComplete=3 -- no kill/mob-count check.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/status")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
function onTrigger(player, npc)
    if npc:getLocalVar("unSealed") == 1 then
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

        if instance and doorUtil.onDoorOpen(npc) then
            doorUtil.sealDoors(instance, Bhaflau.npcs.DOOR._23p)
            instance:setLocalVar("stageComplete", 3)
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

