-----------------------------------
-- Assault: Demolition Duty
-----------------------------------
-- 2026-08-30, real automaton-AI mechanic built (see mobs/Demolition_Automaton.lua and
-- npcs/Uzhahn.lua for the full writeup) -- previously a scaffold with
-- no objective content at all. Original 2026-08-19 capture analysis (Thris Nov2025):
--   - Uzhahn hands the player control of a "Demolition Automaton" pet/ally, which the player
--     leads to attack "Wreckage" scattered around the reef ("The Demolition Automaton hits
--     the Wreckage for N points of damage", hits observed ranging ~23-86, occasionally "readies
--     Slapstick"/"uses Slapstick" as a named TP move). 5 real Wreckage exist
--     (17002546-17002550, see IDs.lua mob[44].WRECKAGE1-5). 2026-08-31: converted from an
--     untargetable npc_list prop to a real mob (see sql/mob_pools.sql's own note) -- Wreckage
--     fundamentally couldn't receive real combat/TP/mob-skill interaction as an NPC, so the
--     automaton's Wreckage-fighting is genuine native combat now, not scripted.
--   - The automaton has a leash: if the player strays too far, it says "Master not found..." and
--     counts down "Initiating safety program shutdown in... 5...4...3...2...1... Delete." and is
--     destroyed -- Uzhahn then scolds the player and hands over a replacement. This happened
--     exactly 2 full times (both ending in "Delete.") in this ~25.5 minute capture without failing
--     the mission; 2 more leash triggers resolved as "Safety program has been shut down" instead
--     (player got back in range before the countdown finished) -- a real, forgiving mechanic, not
--     a hard failure.
--   - Completion is NOT a simple kill-count: Uzhahn gives a real score (real MesNum 7546,
--     dat-extractor-confirmed -- corrects this file's own earlier wrong guess of 7561, which
--     actually belongs to an unrelated Apkallu Seizure line) before the Rune of Release unlocks.
--     A score of 10 (one repair, no replacements) was worth 1000 AP each for a party of 3 -- see
--     npcs/Uzhahn.lua for the real formula/caveats. Real time limit is 30 minutes
--     (instance_list.sql already has this right).
--   - 2026-08-30 pipeline re-scan found 8 real Imp + 4 real Carrion Crab already sitting correctly
--     positioned in mob_spawn_points.sql and registered to this instance, just never given
--     IDs.lua constants or a SpawnMob() call -- fixed below. The 4 Carrion Crab are reused as real
--     spawn points for the Slapstick mechanic (renamed to avoid a real script-dispatch collision
--     with Extermination's own Carrion_Crab.lua -- see mob_spawn_points.sql's own note).
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Ilrusi_Atoll/TextIDs"] = nil;
require("scripts/zones/Ilrusi_Atoll/TextIDs");
require("scripts/globals/status")
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ASSAULT_44_START, 44)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())

    -- 2026-08-31 user-requested: the real spawn point (instance_list.sql) faces the player away
    -- from Uzhahn -- rotate 180 degrees (rotation is a byte, 0-255 = 360 degrees, so +128 mod 256
    -- is exactly half a turn) so they're facing him on zone-in instead.
    local pos = player:getPos()
    player:setPos(pos.x, pos.y, pos.z, (pos.rot + 128) % 256)
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
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)

    -- Real ambient hazard -- 8 Imps, spawned at instance start (not per-kill-tracked, per the
    -- wiki: "your party should be well equipped to handle imps", ambient obstacle not the
    -- objective). Imp.lua already respawns natively per mob_groups/mixins -- no extra Lua needed.
    -- The 4 SLAPSTICK_CRAB spawn points are NOT spawned here -- they're only real positions reused
    -- by mobs/Demolition_Automaton.lua's Slapstick mechanic, not ambient spawns of their own.
    for _, impId in ipairs({
        17002556, 17002557, 17002558, 17002559,
        17002560, 17002561, 17002562, 17002563,
    }) do
        forceAggro(SpawnMob(impId, instance))
    end

    -- The Demolition Automaton is NOT spawned here -- it's issued per-player by Uzhahn on first
    -- trigger (npcs/Uzhahn.lua), matching the real "one person talks to Uzhahn and is assigned an
    -- automaton" mechanic, not an unconditional instance-wide spawn.
    instance:setLocalVar("automatonId", 0)
    instance:setLocalVar("automatonEverIssued", 0)
    instance:setLocalVar("automatonLostToLeash", 0)
    instance:setLocalVar("demolitionScore", 0)
    instance:setLocalVar("wreckageDestroyed", 0)
    instance:setLocalVar("completeStage", 0)

    -- 2026-08-31: Wreckage is a real mob now (converted from an untargetable npc_list prop, see
    -- sql/mob_pools.sql's own note) -- needs a real SpawnMob() call like any other mob, unlike the
    -- old npc_list rows which just rendered by default. HP/destruction are now real native combat
    -- state (mob_groups groupid 37), no more localVar resets needed.
    for _, wId in ipairs({
        17002546, 17002547, 17002548,
        17002549, 17002550,
    }) do
        forceAggro(SpawnMob(wId, instance))
    end
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, { PARTY_FALLEN = PARTY_FALLEN, TIME_REMAINING_MINUTES = TIME_REMAINING_MINUTES, TIME_REMAINING_SECONDS = TIME_REMAINING_SECONDS })
    local stage = instance:getLocalVar("completeStage")
    if stage ~= 0 and os.time() >= instance:getLocalVar("completeAt") then
        if stage == 1 then
            local npc = instance:getEntity(bit.band(17002656, 0xFFF), TYPE_NPC)
            for i, v in pairs(instance:getChars()) do
                v:messageText(npc, UZHAHN_COMPLETE_OTHER)
            end
            instance:setLocalVar("completeStage", 2)
            instance:setLocalVar("completeAt", os.time() + 3)
        elseif stage == 2 then
            instance:setLocalVar("completeStage", 3)
            instance:complete()
            return
        end
    end
    local autoId = instance:getLocalVar("automatonId")
    if autoId ~= 0 and DemolitionAutomatonTick then
        local auto = GetMobByID(autoId, instance)
        if auto and auto:isAlive() then
            DemolitionAutomatonTick(auto)
        end
    end
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
    -- Completion is driven by npcs/Uzhahn.lua calling instance:complete() directly once all 5
    -- Wreckage are destroyed and the player reports back -- not a progress-threshold mechanic.
end

function onInstanceComplete(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(RUNE_UNLOCKED_POS, 7, 10) -- H-10 (capture Thris Nov2025)
    end

    -- 2026-08-31 user-reported: Rune of Release/Ancient Lockbox were spawning at the shared
    -- npc_list default (380, -7.894, 64.999), which belongs to a different mission's start area
    -- entirely (confirmed real per-instance setPos() precedent in this same zone folder --
    -- Extermination/Golden Salvage/Lamia No. 13/Searat Salvation all call real, distinct
    -- setPos() for these two here -- Demolition Duty never got one).
    -- PLACEHOLDER, NOT capture-confirmed: no real Rune/Lockbox position exists yet in any capture
    -- data this session has access to for this mission. Set near Uzhahn (365.200, -7.000,
    -- -463.000, real npc_list position) purely so it's at least in the right area instead of
    -- clear across the zone -- verify with !checknav/!logpos in-game and correct this once you
    -- have a real position, same as every other hand-placed position this session.
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setPos(368.000, -7.000, -463.000, 0)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setPos(371.000, -7.000, -463.000, 0)

    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17002655, 0xFFF), TYPE_NPC):hideName(true)
    instance:getEntity(bit.band(17002654, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

function onEventUpdate(player, csid, option)
end

