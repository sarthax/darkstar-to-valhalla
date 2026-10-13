-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_238, LSB: DOOR_1_EAST_EXIT_3)
-----------------------------------
-- 2026-09-08: real fix, ported directly from LandSandBoat's own real _238.lua ("1st floor East
-- wing 1st hall door"). Same real fix/reasoning as _233.lua/_234.lua/_237.lua -- plain standalone
-- sequential hallway door, no shared group-lock flag.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
function onTrigger(player, npc)
    if npc:getLocalVar("opened") == 1 then
        player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
    else
        player:startEvent(300)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, door)
    if csid == 300 and option == 1 then
        doorUtil.openSimple(door)
    end
end

