-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_23f, LSB: DOOR_2_NE_ENTRANCE)
-----------------------------------
-- 2026-09-09: real fix -- this door didn't exist at all. Confirmed real and missing purely from
-- Topaz's own SQL (npc_list.sql had a commented-out NOT_CAPTURED placeholder at this exact id,
-- 17084920) via FFXI-DATS' client dat-extraction (Info/Door or Objects.json, ZoneId 75) -- real
-- position (500,-2.012,320) mirrors _23d (180,-2.012,320) exactly around this floor's real x=340
-- center. This is LSB's own DOOR_2_NE_ENTRANCE role, matching _23d's real structure exactly:
-- "2nd Floor 2nd Door East Wing, opens NE section, locks SE Wing." Seals the SE entrance (_23g),
-- unseals the NE exit (_23j), spawns this room's real mob roster. Mirrors _23d's own real mob
-- pattern (2 Engraver/Stoneworker/Cameist + 4 of the branch's own trash type) using East-side
-- fauna (Sulfur Scorpion in place of Wandering Wamoura, Troll Gemologist in place of Troll
-- Ironworker, per BG Wiki's own real Eastern Area roster) at array indices not already claimed by
-- _23g's own roster.
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
            doorUtil.sealDoors(instance, Bhaflau.npcs.DOOR._23g)
            doorUtil.unsealDoors(instance, Bhaflau.npcs.DOOR._23j)

            local mobs = {
                doorUtil.slice(Bhaflau.mobs.TROLL_GEMOLOGIST, 3, 4),
                doorUtil.slice(Bhaflau.mobs.SULFUR_SCORPION, 13, 15),
            }
            doorUtil.spawnGroup(instance, mobs)
        else
            player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
        end
    end
end

