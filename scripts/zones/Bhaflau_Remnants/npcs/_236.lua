-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_236, LSB: DOOR_1_EAST_EXIT_1 / real role: "1st Floor East Exit Door")
-----------------------------------
-- 2026-09-08: real fix, ported directly from LandSandBoat's own real _236.lua. This is the one
-- real "exit" door for the East hallway -- opening it unseals CENTER and spawns this room's real
-- mob roster. It does NOT share a lock with _237/_238 (those are plain sequential hallway doors,
-- see their own files) -- the earlier version incorrectly tied all 3 to one shared
-- BhaflauFloor1Exit flag, so opening this door (or any of its "siblings") would immediately seal
-- the other two, and this door itself stayed sealed if the flag was ever set by mistake elsewhere.
-- Converted to its own self-tracked unSealed state, matching every other real Bhaflau door.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/status")
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
        local instance = door:getInstance()

        doorUtil.openSimple(door)
        doorUtil.unsealDoors(instance, { Bhaflau.npcs.DOOR._239, Bhaflau.npcs.DOOR._23a })
        for _, id in ipairs({ Bhaflau.npcs.DOOR._239, Bhaflau.npcs.DOOR._23a }) do
            local center = instance:getEntity(bit.band(id, 0xFFF), TYPE_NPC)
            if center then
                center:untargetable(false)
                center:setStatus(STATUS_NORMAL)
            end
        end

        local mobs = {
            doorUtil.slice(Bhaflau.mobs.TROLL_IRONWORKER, 1, 2),
            doorUtil.slice(Bhaflau.mobs.SULFUR_SCORPION, 1, 3),
        }
        doorUtil.spawnGroup(instance, mobs)
    end
end

