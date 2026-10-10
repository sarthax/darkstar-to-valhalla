-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23r, LSB: DOOR_3_SOUTH_CENTER)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23r.lua
-- ("3rd Floor South Central Entry"). Opening this unseals both Floor 4 exits (_23t/_23u), spawns
-- the real Archaic Gear/Gears roster, and reveals the Slot NM trigger.
-- 2026-09-09: real fix -- was spawning FLOOR 4's own Archaic Gear/Gears ids (ARCHAIC_GEAR/
-- ARCHAIC_GEARS), a real cross-floor mixup discovered once the user's own Floor 3 wiki text
-- revealed these are two genuinely different real mobs sharing one name (see IDs.lua's own
-- ARCHAIC_GEAR_F3 writeup). Fixed to spawn this floor's own real West+East ids instead.
-- 2026-09-09 (also): real fix -- the wiki's own "South Central Area" (12 Black Pudding, its own
-- large room) was never spawned anywhere -- only 20 of the 34 real BLACK_PUDDING ids were used
-- (_23l/_23q's own 10-each room2 spawns, indices 15-34). This is the real doorway into that same
-- South Central area (matches its own LSB name), so the missing 12 (indices 1-12) are spawned
-- here alongside the Gears/Slot reveal.
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
            doorUtil.unsealDoors(instance, { Bhaflau.npcs.DOOR._23u, Bhaflau.npcs.DOOR._23t })
            -- 2026-09-09: real fix -- _23m/_23p (the real doors INSIDE the West/East Gear rooms
            -- leading to the 4F teleporter) only ever sealed each OTHER on open -- nothing
            -- anywhere ever unsealed either one first, so both were permanently stuck reporting
            -- sealed (live-confirmed). This is the real doorway into that same Gear-room area, so
            -- both get unsealed here alongside the Gears/Pudding/Slot reveal.
            doorUtil.unsealDoors(instance, { Bhaflau.npcs.DOOR._23m, Bhaflau.npcs.DOOR._23p })

            local mobs = {
                Bhaflau.mobs.ARCHAIC_GEARS_F3.WEST,
                Bhaflau.mobs.ARCHAIC_GEARS_F3.EAST,
                Bhaflau.mobs.ARCHAIC_GEAR_F3.WEST,
                Bhaflau.mobs.ARCHAIC_GEAR_F3.EAST,
                doorUtil.slice(Bhaflau.mobs.BLACK_PUDDING, 1, 12),
            }
            doorUtil.spawnGroup(instance, mobs)

            local slot = instance:getEntity(bit.band(Bhaflau.npcs.SLOT, 0xFFF), TYPE_NPC)
            if slot then
                slot:setStatus(STATUS_NORMAL)
            end
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

