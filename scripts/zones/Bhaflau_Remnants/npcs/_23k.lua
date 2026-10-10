-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23k, LSB: DOOR_2_SE_EXIT)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23k.lua
-- ("2nd Floor Door to SE Portal"). Opening this marks stageComplete=2 -- no kill/mob-count check.
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
        if doorUtil.onDoorOpen(npc) then
            npc:getInstance():setLocalVar("stageComplete", 2)
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

