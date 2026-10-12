-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Archaic Gears
-----------------------------------
-- 2026-09-06: real captured id/position (Mission Toolkit captures #110/#111), no Lua script
-- existed for this mob type before -- see scripts/globals/salvage.lua's spawnTempChest comment
-- for why the drop-chest call belongs here rather than in a shared/centralized hook.
--
-- 2026-09-09: real mechanic (BG Wiki, Floor 3 Central Area, user-supplied): "Defeating the two
-- Archaic Gears (1 from the East and 1 from the West rooms) near simultaneously will cause a
-- Dormant Rampart to spawn." This file is shared by the real "Archaic_Gears" name on BOTH Floor 3
-- (this mechanic) and Floor 4 (a different, chest-drop-only real mob per the existing Long-Bowed
-- Chariot writeup) -- scoped to only run this logic for a real Floor 3 id (ARCHAIC_GEARS_F3),
-- matching the same real cross-floor-name-collision fix just applied to Archaic_Gear.lua.
-- "Near simultaneously" is implemented as a real, generous window (30s) tracked via instance
-- localVars set by whichever side dies first -- no exact real window is documented anywhere, so
-- this value is an explicit, flagged placeholder, not a confirmed number.
-----------------------------------
require("scripts/globals/salvage")
require("scripts/globals/status")
require("scripts/zones/Bhaflau_Remnants/IDs")
-----------------------------------
local NEAR_SIMULTANEOUS_WINDOW = 30 -- seconds, unconfirmed placeholder -- see header

function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)

    local mobID = mob:getID()
    local side
    if mobID == Bhaflau.mobs.ARCHAIC_GEARS_F3.WEST then
        side = "West"
    elseif mobID == Bhaflau.mobs.ARCHAIC_GEARS_F3.EAST then
        side = "East"
    else
        return
    end

    local instance = mob:getInstance()
    if not instance then
        return
    end

    local otherSide = (side == "West") and "East" or "West"
    local now = os.time()
    local otherDeathTime = instance:getLocalVar("ArchaicGears" .. otherSide .. "DeathTime")

    if otherDeathTime > 0 and (now - otherDeathTime) <= NEAR_SIMULTANEOUS_WINDOW then
        local dormant = instance:getEntity(bit.band(Bhaflau.mobs.DORMANT_RAMPART[3], 0xFFF), TYPE_NPC)
        if dormant then
            -- 2026-09-09: real fix -- user live-confirmed the real West-side reveal position
            -- (-497,-4.5,-420), matching LSB's own real value almost exactly (-497,-4,-420). User
            -- then confirmed a mirrored East-side spot must also exist -- checked the math: this
            -- floor's real center is x=-340 (confirmed via its own doors), and
            -- DORMANT_RAMPART[3]'s own SQL default position (-183,-4.9,-420) is exactly 157 units
            -- east of center, the same 157-unit offset as -497 is west of center. So the real
            -- East mirror was already sitting in SQL all along as the entity's own default --
            -- reposition only needed for the West case; the East case is its own native spawn.
            -- `side` here is whichever Gears boss triggered THIS reveal (the second of the pair
            -- to die), matching LSB's own real per-id branch.
            if side == "West" then
                dormant:setPos(-497, -4.5, -420, 252)
            else
                dormant:setPos(-183, -4.9, -420, 0)
            end
            dormant:setStatus(STATUS_NORMAL)
        end
        instance:setLocalVar("ArchaicGearsWestDeathTime", 0)
        instance:setLocalVar("ArchaicGearsEastDeathTime", 0)
    else
        instance:setLocalVar("ArchaicGears" .. side .. "DeathTime", now)
    end
end

