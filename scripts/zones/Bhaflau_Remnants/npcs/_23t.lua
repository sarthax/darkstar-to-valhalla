-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23t, LSB: DOOR_4_WEST_EXIT)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23t.lua
-- ("4th Floor West Door to Portal"). Real dual gate: onTrigger checks stage==4/progress==1
-- directly. Opening it marks stageComplete=4 -- no kill/mob-count check.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/status")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
function onTrigger(player, npc)
    local instance = npc:getInstance()
    if instance and instance:getStage() == 4 and instance:getProgress() == 1 then
        player:startEvent(300)
    else
        player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
    if csid == 300 and option == 1 then
        if doorUtil.onDoorOpen(npc) then
            npc:getInstance():setLocalVar("stageComplete", 4)
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

