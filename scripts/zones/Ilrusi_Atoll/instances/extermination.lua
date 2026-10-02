-----------------------------------
-- Assault: Extermination
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Ilrusi_Atoll/TextIDs"] = nil;
require("scripts/zones/Ilrusi_Atoll/TextIDs");
require("scripts/globals/status")
-----------------------------------
-- Real base "Carrion" mob ids (were ID.mob[43] under the old LandSandBoat-targeted IDs.lua; that
-- per-instance mob-group shape has no old-dsp-reference equivalent -- see TextIDs.lua's own
-- header -- so these 20 real mob ids are hardcoded directly here instead, same convention as
-- old-dsp-reference's own Rune_of_Release.lua/Ancient_Lockbox.lua). The 4 UNDEAD_* boss-chance
-- mobs (17002541-17002544) are intentionally excluded -- see onMobDespawn in mobs/Carrion_Crab.lua
-- etc. for their own 1-in-5 spawn trigger.
local BASE_CARRION_MOBS = {
    17002521, 17002522, 17002523, 17002524, 17002525, 17002526, 17002527, 17002528,
    17002529, 17002530, 17002531, 17002532, 17002533, 17002534, 17002535, 17002536,
    17002537, 17002538, 17002539, 17002540,
}
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()

    player:messageSpecial(ASSAULT_43_START, 43)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- Same fix as Leujaoam_Sanctum / Lebros_Cavern: without MOBMOD_ALWAYS_AGGRO a mob only aggros a
-- player when the exp gain is > 50 (zone_entities.cpp), so low-level instance mobs never aggro
-- high-level players. Only takes effect for mobs whose pool has aggro=1 (m_Aggro gate).
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

function onInstanceCreated(instance)

    -- 2026-08-20: only spawn the 20 base "Carrion" mobs here. The 4 UNDEAD_* mobs are an
    -- optional 1-in-5 boss-chance spawn triggered from within each family's own onMobDespawn
    -- (Carrion_Crab.lua/_Leech.lua/_Slime.lua/_Toad.lua) -- pre-spawning them here made them
    -- already alive from the start, so SpawnMob() inside that trigger became a no-op while the
    -- triggering Carrion kill's progress point was still silently skipped, permanently losing
    -- points and leaving progress short of the required 20 even after clearing the whole zone.
    for _, v in ipairs(BASE_CARRION_MOBS) do
        forceAggro(SpawnMob(v, instance))
    end

    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setPos(290.857, -3.424, 132.339, 148)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setPos(293.637, -3.376, 130.364, 148)
    -- Rune of Release npc_list row defaults to status 0 (visible/clickable). Hide it (and the Lockbox) until
    -- the mission completes; onInstanceComplete sets both back to STATUS_NORMAL.
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(17002730, 0xFFF), TYPE_NPC):setAnimation(8)
    instance:getEntity(bit.band(17002745, 0xFFF), TYPE_NPC):setAnimation(8)
    instance:getEntity(bit.band(17002747, 0xFFF), TYPE_NPC):setAnimation(8)
    instance:getEntity(bit.band(17002754, 0xFFF), TYPE_NPC):setAnimation(8)

    -- 2026-08-29 CORRECTED: previous _1jk wiring here was wrong -- it matched the user's LOGPOS
    -- against a raw NPCLogger capture id (17002726) without applying this zone's -1 id-shift
    -- correction. Properly shifted, that capture (216,-3,0) resolves to current id 17002725
    -- (_1jj), which the pristine pre-session instance_entities data already registered to this
    -- mission (just under old/pre-shift numbering) -- no SQL position change was ever needed,
    -- _1jj was already correctly positioned. _1jk (17002726) is not actually part of this mission.
    instance:getEntity(bit.band(17002725, 0xFFF), TYPE_NPC):setAnimation(8)

    -- _1jr registered to this instance (instance_entities) but never activated -- same
    -- missing-wiring pattern as the door props above.
    instance:getEntity(bit.band(17002733, 0xFFF), TYPE_NPC):setAnimation(9)
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

    -- print(string.format("[EXTERMINATION DEBUG] onInstanceProgressUpdate: progress=%d (need 20)", progress))

    -- 2026-08-20: was `progress == 20` (exact equality) -- if progress ever overshoots 20 even
    -- once (e.g. a double-fired despawn hook), it can never land back on exactly 20 again and the
    -- mission would never complete. Switched to >= to match every other similarly-structured
    -- instance (Excavation Duty, Escort Professor Chanoix, etc.) and to be safe against overshoot.
    if progress >= 20 then
        instance:complete()
    end
end

function onInstanceComplete(instance)

    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(RUNE_UNLOCKED_POS, 7, 8) -- H-8 (capture Thris Nov2025)
    end

    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):hideName(true)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)

end

function onEventUpdate(player, csid, option)
end

