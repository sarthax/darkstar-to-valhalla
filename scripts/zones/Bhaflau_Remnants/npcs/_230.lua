-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_230, LSB: DOOR_1_0, real Floor 1 entrance/branch point)
-----------------------------------
-- 2026-09-07: real, video-confirmed (this file's own IDs.lua header): the player's teleport-in
-- lands here, and from here the real branch is WEST (_232, 17084891) or EAST (_231, 17084890) --
-- opening one locks the other (same group-lock mechanic as Arrapago's own confirmed door chain).
-- Real door-open csid (300) confirmed via a fresh eventview capture (Foxmulder), same shared event
-- family as every other Gilded Doors entity in this zone.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
function onTrigger(player, npc)
    player:startEvent(300)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, door)
    if csid == 300 and option == 1 then
        doorUtil.openAndAdvance(door, Bhaflau.npcs.FLOOR1_GROUPS.ENTRANCE, Bhaflau.npcs.FLOOR1_GROUPS.BRANCH)
    end
end

