-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_233, LSB: DOOR_1_WEST_EXIT_1)
-----------------------------------
-- 2026-09-08: real fix, ported directly from LandSandBoat's own real _233.lua ("1st floor hallway
-- 1st door west wing"). This is a plain, standalone sequential hallway door -- LSB's own file has
-- NO group-lock/unseal-other logic at all here. The earlier version incorrectly treated this as
-- part of a "pick one of 3, lock the others" group sharing a single BhaflauFloor1Exit flag with
-- _234/_235 -- live-confirmed real bug: opening _236 (east's own equivalent) immediately sealed
-- _237/_238 too, even though this hallway is just a straight walk-through sequence per the user's
-- own map knowledge, not a branch choice. Converted to a simple self-tracked door.
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

