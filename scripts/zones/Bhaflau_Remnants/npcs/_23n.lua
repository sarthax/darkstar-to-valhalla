-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23n, LSB: DOOR_3_NW_ENTRANCE)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23n.lua
-- ("3rd Floor NW Door"). Real dual gate: onTrigger checks stage==3/progress==1 directly. Opening
-- it unseals the North Center door (_23s) and spawns this room's real mob roster.
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/status")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
function onTrigger(player, npc)
    local instance = npc:getInstance()
    if instance and instance:getStage() == 3 and instance:getProgress() == 1 then
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

        if instance and doorUtil.onDoorOpen(npc, nil, 5) then
            doorUtil.unsealDoors(instance, Bhaflau.npcs.DOOR._23s)

            local mobs = {
                doorUtil.slice(Bhaflau.mobs.TROLL_STONEWORKER, 10, 11),
                Bhaflau.mobs.TROLL_SMELTER[9],
                Bhaflau.mobs.TROLL_CAMEIST[9],
                Bhaflau.mobs.TROLL_IRONWORKER[10],
                doorUtil.slice(Bhaflau.mobs.TROLL_ENGRAVER, 10, 11),
                doorUtil.slice(Bhaflau.mobs.TROLL_GEMOLOGIST, 5, 6),
                Bhaflau.mobs.TROLL_LAPIDARIST[4],
            }
            doorUtil.spawnGroup(instance, mobs)
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

