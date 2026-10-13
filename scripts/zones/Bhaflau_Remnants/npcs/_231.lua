-----------------------------------
-- Area: Bhaflau Remnants
-- Door: Gilded Doors (_231, LSB: DOOR_1_EAST_ENTRANCE)
-----------------------------------
-- 2026-09-07: real, video-confirmed branch choice from _230 -- taking EAST locks the whole
-- BRANCH group (itself and the WEST door, _232) and reveals the East exit group (WEST_EXIT/
-- EAST_EXIT grouping itself is LSB-role-label-inferred, not independently video-confirmed -- see
-- IDs.lua's FLOOR1_GROUPS comment).
-----------------------------------
require("scripts/zones/Bhaflau_Remnants/IDs")
local doorUtil = require("scripts/zones/Bhaflau_Remnants/door_util")
-----------------------------------
function onTrigger(player, npc)
    local instance = npc:getInstance()
    if instance and instance:getLocalVar("BhaflauFloor1Branch") ~= 0 then
        player:messageSpecial(Bhaflau.text.DOOR_IS_SEALED)
    else
        player:startEvent(300)
    end
end

function onEventUpdate(player, csid, option)
end

-- 2026-09-08: real mechanic (BG Wiki) -- Mad Bomber has one real SQL row (IDs.lua's own
-- MAD_BOMBER comment) but "has the potential to spawn in the room at the end of the West or East
-- branches" -- repositioned here to one of this branch's own 2 real candidate spots
-- (ID.pos.MAD_BOMBER.EAST, user-logged via !logpos) rather than always using its SQL default
-- position, which only covers the West branch's own 2nd spot.
-- 2026-09-08: real fix -- records which of the 2 candidate spots was actually chosen
-- (mob:setLocalVar("popIndex", i)) so onMobDeath (Mad_Bomber.lua) can look up the exact matching
-- Dormant Rampart position by the same index instead of guessing/re-detecting by proximity.
--
-- 2026-09-08 (later): real fix -- live-confirmed (debug log) popIndex always read back 0. Root
-- cause: setLocalVar was called BEFORE spawn(), but CBaseEntity::Spawn() (src/map/entities/
-- baseentity.cpp) unconditionally calls ResetLocalVars() -- wiping it immediately. Reordered to
-- set popIndex AFTER spawn() so it actually survives.
local function popMadBomber(instance, branchPositions)
    local mob = GetMobByID(Bhaflau.mobs.MAD_BOMBER, instance)
    if mob and not mob:isSpawned() then
        local i = math.random(1, #branchPositions)
        local pos = branchPositions[i]
        mob:setSpawn(pos[1], pos[2], pos[3], pos[4])
        mob:spawn()
        mob:setLocalVar("popIndex", i)
    end
end

-- 2026-09-08: real fix -- trash mobs for this branch were never actually spawned anywhere. Ported
-- directly from LandSandBoat's own real _231.lua: full CARMINE_ERUCA (East-only, per IDs.lua's own
-- header), BIFRONS[1..7] (position-verified this session: all 7 real x>340/East), and
-- TROLL_GEMOLOGIST[1..2] (position-verified: both real x>410/East).
--
-- 2026-09-08 (later): real fix -- LSB's own 50% Mad Bomber spawn chance reflects PRE-April-8-2009
-- behavior. Per BG-wiki/FFXIclopedia (user-supplied): "as of the April 8th, 2009 update, Mad Bomber
-- will always be up on whichever path the party takes" -- guaranteed, not a coin flip. Removed the
-- chance check.
function onEventFinish(player, csid, option, door)
    if csid == 300 and option == 1 then
        doorUtil.openAndAdvance(door, Bhaflau.npcs.FLOOR1_GROUPS.BRANCH, Bhaflau.npcs.FLOOR1_GROUPS.EAST_EXIT, function(instance)
            instance:setLocalVar("BhaflauFloor1Branch", 1) -- 1 = east

            local mobs = {
                Bhaflau.mobs.CARMINE_ERUCA,
                doorUtil.slice(Bhaflau.mobs.BIFRONS, 1, 7),
                doorUtil.slice(Bhaflau.mobs.TROLL_GEMOLOGIST, 1, 2),
            }
            doorUtil.spawnGroup(instance, mobs)

            popMadBomber(instance, ID.pos.MAD_BOMBER.EAST)
        end)
    end
end

