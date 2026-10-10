-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23c, LSB: DOOR_2_EAST_ENTRANCE)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23c.lua.
-- "2nd Floor 1st Door opens East Wing, locks West Wing." Opening this seals the West entrance
-- (_23b), unseals the SE entrance, spawns this room's real mob roster, and has a 50% chance to
-- reveal the East Socket/Flux Flan room.
--
-- 2026-09-09: real fix -- the "REAL GAP" noted below is resolved. _23f (DOOR_2_NE_ENTRANCE) was
-- never missing an id, just missing its npc_list row -- confirmed real via FFXI-DATS' client dat
-- extraction and added (see _23f.lua/IDs.lua's own writeup). Now unseals both real entrance doors,
-- mirroring _23b's own unseal of both _23d/_23e exactly.
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

        if instance and doorUtil.onDoorOpen(npc, nil, 1) then
            doorUtil.sealDoors(instance, Bhaflau.npcs.DOOR._23b)
            doorUtil.unsealDoors(instance, { Bhaflau.npcs.DOOR._23g, Bhaflau.npcs.DOOR._23f })

            local mobs = {
                doorUtil.slice(Bhaflau.mobs.SULFUR_SCORPION, 4, 12),
                doorUtil.slice(Bhaflau.mobs.TROLL_SMELTER, 1, 3),
                doorUtil.slice(Bhaflau.mobs.TROLL_IRONWORKER, 3, 5),
            }
            doorUtil.spawnGroup(instance, mobs)

            if math.random(1, 100) >= 50 then
                local socket = instance:getEntity(bit.band(Bhaflau.npcs.SOCKET, 0xFFF), TYPE_NPC)
                local flan = GetMobByID(Bhaflau.mobs.FLUX_FLAN, instance)
                if socket then
                    socket:setPos(458, 0, 260, 0)
                end
                if flan then
                    flan:setSpawn(455, -0.5, 260, 0)
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

