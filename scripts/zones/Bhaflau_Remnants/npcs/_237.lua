-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_237, LSB: DOOR_1_EAST_EXIT_2)
-----------------------------------
-- 2026-09-08: real fix, ported directly from LandSandBoat's own real _237.lua ("1st floor East
-- wing 2st hall door"). Same real fix/reasoning as _233.lua/_234.lua -- plain standalone
-- sequential hallway door, NOT part of a group-lock with _236/_238. Live-confirmed real bug: this
-- door showed "Door is sealed..." immediately after _236 (a different door) was opened, because
-- both incorrectly shared one BhaflauFloor1Exit flag. Converted to a simple self-tracked door.
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

