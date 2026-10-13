-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23g, LSB: DOOR_2_SE_ENTRANCE)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23g.lua.
-- "2nd Floor 2nd Door East Wing, opens SE section, locks NE Section." Seals the NE entrance --
-- REAL GAP: no NE entrance id exists in this zone's IDs.lua (see _23c.lua's own comment), so that
-- seal is not ported. Unseals the SE exit (_23k), spawns this room's real mob roster.
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
            doorUtil.unsealDoors(instance, Bhaflau.npcs.DOOR._23k)

            local mobs = {
                doorUtil.slice(Bhaflau.mobs.SULFUR_SCORPION, 16, 22),
                Bhaflau.mobs.TROLL_SMELTER[6],
                Bhaflau.mobs.TROLL_STONEWORKER[3],
                Bhaflau.mobs.TROLL_CAMEIST[3],
            }
            doorUtil.spawnGroup(instance, mobs)
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

