-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23s, LSB: DOOR_3_NORTH_CENTER)
-----------------------------------
-- 2026-09-08: real mechanic, ported directly from LandSandBoat's own real, working _23s.lua
-- ("3rd Floor North to Central"). LSB's own file is functionally identical to _23r.lua (South
-- Center) -- both convergence points lead to the same Floor 4 reveal -- ported as-is, not
-- simplified, since that's the real confirmed behavior.
-- 2026-09-09: real fix -- same cross-floor Archaic Gear/Gears mixup fixed in _23r.lua -- see that
-- file's own writeup and IDs.lua's ARCHAIC_GEAR_F3 comment.
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
            -- 2026-09-09: real fix -- same as _23r.lua's own writeup -- _23m/_23p only ever
            -- sealed each OTHER on open, nothing ever unsealed either first (live-confirmed
            -- permanently sealed). Unsealed here too since this is the other real convergence
            -- point into the same Gear-room area.
            doorUtil.unsealDoors(instance, { Bhaflau.npcs.DOOR._23m, Bhaflau.npcs.DOOR._23p })

            local mobs = {
                Bhaflau.mobs.ARCHAIC_GEARS_F3.WEST,
                Bhaflau.mobs.ARCHAIC_GEARS_F3.EAST,
                Bhaflau.mobs.ARCHAIC_GEAR_F3.WEST,
                Bhaflau.mobs.ARCHAIC_GEAR_F3.EAST,
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

