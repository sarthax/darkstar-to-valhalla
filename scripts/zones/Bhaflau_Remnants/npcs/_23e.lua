-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23e, LSB: DOOR_2_SW_ENTRANCE)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23e.lua.
-- "2nd Floor 2nd Door West Wing, opens SW section, locks NW Wing." Seals the NW entrance (_23d),
-- unseals the SW exit (_23i), spawns this room's real mob roster. Mob-array index references are
-- ported as-is from LSB, not individually position-verified against Topaz's own array order.
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
            doorUtil.sealDoors(instance, Bhaflau.npcs.DOOR._23d)
            doorUtil.unsealDoors(instance, Bhaflau.npcs.DOOR._23i)

            local mobs = {
                doorUtil.slice(Bhaflau.mobs.WANDERING_WAMOURA, 17, 23),
                Bhaflau.mobs.TROLL_ENGRAVER[6],
                Bhaflau.mobs.TROLL_STONEWORKER[6],
                Bhaflau.mobs.TROLL_CAMEIST[6],
            }
            doorUtil.spawnGroup(instance, mobs)
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

