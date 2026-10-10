-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23b, LSB: DOOR_2_WEST_ENTRANCE)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23b.lua.
-- "2nd Floor 1st Door opens West Wing, locks East Wing." Opening this seals the East entrance
-- (_23c) and unseals both NW/SW entrances, spawns this room's real mob roster, and has a 50%
-- chance to reveal the West Socket/Flux Flan room. Mob-array index references below are ported
-- as-is from LSB and have NOT been individually position-verified against Topaz's own array order
-- (unlike the Floor 3/4 room slices checked earlier this session) -- flagged, not fabricated.
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

        if instance and doorUtil.onDoorOpen(npc, nil, 2) then
            doorUtil.sealDoors(instance, Bhaflau.npcs.DOOR._23c)
            doorUtil.unsealDoors(instance, { Bhaflau.npcs.DOOR._23e, Bhaflau.npcs.DOOR._23d })

            local mobs = {
                doorUtil.slice(Bhaflau.mobs.WANDERING_WAMOURA, 4, 12),
                doorUtil.slice(Bhaflau.mobs.TROLL_ENGRAVER, 1, 3),
                doorUtil.slice(Bhaflau.mobs.TROLL_IRONWORKER, 6, 8),
            }
            doorUtil.spawnGroup(instance, mobs)

            if math.random(1, 100) >= 50 then
                local socket = instance:getEntity(bit.band(Bhaflau.npcs.SOCKET, 0xFFF), TYPE_NPC)
                local flan = GetMobByID(Bhaflau.mobs.FLUX_FLAN, instance)
                if socket then
                    socket:setPos(222, 0, 260, 0)
                end
                if flan then
                    flan:setSpawn(225, -0.5, 260, 0)
                end
                if socket then
                    socket:setStatus(STATUS_NORMAL)
                end
            end
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

