-----------------------------------
-- Assault: Preemptive Strike
-----------------------------------
-- Validated 2026-08-18 by a real Thris Nov 2025 capture, real WIN (1100 Assault points) --
-- exactly 13 "Mamool Ja Executioner" kills observed (6 "Puk Executioner" kills also happened,
-- ambient, don't count), confirming kill-all-13 exactly right. Entrance corrected (was a ~15-
-- unit-off guess); Assault points corrected from a 1000 guess to the real 1100; Lockbox reward
-- table extended with a real hi-potion +2 drop.
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
require("scripts/globals/status")
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ASSAULT_12_START, 12)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- 2026-08-21: this mission's own door/wall prop family (_1u9 through _1uj, 9 real props) was
-- never registered in sql/instance_entities.sql, and this function never referenced any of them --
-- found via a full capture/SQL/instance_entities cross-reference, not a live-test symptom trace.
-- All 9 default hidden (npc_list status=0) with no animation override ever applied, so nothing
-- ever revealed them in any live instance since this mission was first built. Likely the real
-- explanation for the user-reported "door in closed state" -- not a shared/global regression, this
-- mission's props were simply never wired at all. Revealed here with each prop's own npc_list
-- default animation (not overridden) -- which animation value means "open" vs "closed" for this
-- specific prop family hasn't been independently verified; needs a live retest.
local DOOR_PROPS = {
    17047868, 17047869, 17047870, 17047871,
    17047874, 17047875, 17047876, 17047877, 17047878,
}

-- Real 7 Puk Executioner + 13 Mamool Ja Executioner ids (were ID.mob[1] under the old
-- LandSandBoat-targeted IDs.lua; that per-instance mob-group shape has no old-dsp-reference
-- equivalent -- see TextIDs.lua's own header -- so hardcoded directly here instead, same
-- convention as old-dsp-reference's own Rune_of_Release.lua/Ancient_Lockbox.lua).
local MOB_GROUP_1 = {
    17047570, 17047571, 17047572, 17047573, 17047574, 17047575, 17047576,
    17047577, 17047578, 17047579, 17047580, 17047581, 17047582, 17047583,
    17047584, 17047585, 17047586, 17047587, 17047588, 17047589,
}

-- Same fix as Leujaoam_Sanctum / Lebros_Cavern: without MOBMOD_ALWAYS_AGGRO a mob only aggros a
-- player when the exp gain is > 50 (zone_entities.cpp), so low-level instance mobs never aggro
-- high-level players. Only takes effect for mobs whose pool has aggro=1 (m_Aggro gate).
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

function onInstanceCreated(instance)

    for _, v in ipairs(MOB_GROUP_1) do
        forceAggro(SpawnMob(v, instance))
    end

    for i, propId in ipairs(DOOR_PROPS) do
        local prop = instance:getEntity(bit.band(propId, 0xFFF), TYPE_NPC)
        if prop then
            prop:setStatus(STATUS_NORMAL)
        end
    end

    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setPos(-57, 1, -101, 49)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setPos(-57, 1, -104, 49)

end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, { PARTY_FALLEN = PARTY_FALLEN, TIME_REMAINING_MINUTES = TIME_REMAINING_MINUTES, TIME_REMAINING_SECONDS = TIME_REMAINING_SECONDS })
end

function onInstanceFailure(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)

    if (progress >= 13) then
        instance:complete()
    end

end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(RUNE_UNLOCKED_POS, 8, 7) -- I-7 (user-verified in-game; Topaz source has 8,8 placeholder)
    end

    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

