-----------------------------------
-- Assault: Shanarha Grass Conservation
-----------------------------------
-- Built 2026-08-18 from data found sitting unwired in this repo's own SQL: 20 real Coney
-- entries, comment-labeled "-- Shanarha Grass Conservation" in sql/mob_spawn_points.sql,
-- directly after Escort Professor Chanoix's block. Modeled as kill-all-20 (see IDs.lua and
-- mobs/Coney.lua for why -- real objective text says "Protect the vegetation" but no
-- protectable prop was found).
-- 2026-08-23 REBUILT from 2 independent real captures (Thris Nov2025 + LC), cross-confirmed
-- identical on every entity: all 20 Coney had (0,0,0,0) placeholder positions -- corrected, plus
-- a 20th row that was missing outright. 27 more real Vegetation props recovered from
-- NOT_CAPTURED placeholders (2 already existed). Real mission mechanic, per user description of
-- direct in-game observation:
--   - Start at (I-9), Rune of Release also appears there on completion.
--   - All 20 Coney spawn in the first room, then 9-11 run south and 9-11 run north.
--   - Coney do not show up on Wide Scan (namevis fixed in mob_pools.sql).
--   - They link (mob_pools links=1 already correct) -- Sleepga matters since they start grouped.
--   - Real stats: /check DC to a level 75 player (uncapped), ~2200 HP each (mob_groups.sql).
--   - If disengaged mid-fight they flee, then de-aggro and heal back to full if not chased down --
--     this is native engine behavior (CMobController::DoRoamTick's Rest()-on-disengage), not
--     scripted here.
--   - Coney eat Vegetation over the course of the fight; more Vegetation remaining at the end
--     means more points, and eating too much can fail the mission outright.
-- 2026-08-30, real AI behavior built in mobs/Coney.lua (see that file's own header for the full
-- writeup): each Coney now really spawns together in the first room, dashes toward a real
-- north/south hub, and actively seeks + paths to its nearest live Vegetation, channeling a real
-- 10-second eat before consuming it (interrupted by combat). The instance script's job is now
-- just tracking `vegetation_remaining`/`vegetation_failed` (set by Coney.lua) and the completion/
-- Assault-points math -- the old blind per-tick dice-roll "eat" check (no real movement at all)
-- is gone. Fail threshold: user-specified "more than 20 of 29 eaten" -- remaining <= 8 (Coney.lua
-- enforces this itself). North/south hub coordinates and the exact eat duration are still
-- DERIVED/estimated, not capture-confirmed -- see Coney.lua for detail.
-----------------------------------
require("scripts/globals/instance")
require("scripts/globals/status")
local ID = Leujaoam
-----------------------------------
local VEGETATION_IDS =
{
    ID.npc.VEGETATION1,  ID.npc.VEGETATION2,  ID.npc.VEGETATION3,  ID.npc.VEGETATION4,
    ID.npc.VEGETATION5,  ID.npc.VEGETATION6,  ID.npc.VEGETATION7,  ID.npc.VEGETATION8,
    ID.npc.VEGETATION9,  ID.npc.VEGETATION10, ID.npc.VEGETATION11, ID.npc.VEGETATION12,
    ID.npc.VEGETATION13, ID.npc.VEGETATION14, ID.npc.VEGETATION15, ID.npc.VEGETATION16,
    ID.npc.VEGETATION17, ID.npc.VEGETATION18, ID.npc.VEGETATION19, ID.npc.VEGETATION20,
    ID.npc.VEGETATION21, ID.npc.VEGETATION22, ID.npc.VEGETATION23, ID.npc.VEGETATION24,
    ID.npc.VEGETATION25, ID.npc.VEGETATION26, ID.npc.VEGETATION27, ID.npc.VEGETATION28,
    ID.npc.VEGETATION29,
}

function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_04_START, 4)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- 2026-09-17: applying the DSP aggro-gate fix confirmed live in Nyzul Isle (see
-- Nyzul_Isle/instances/nyzul_isle_investigation.lua's forceAggro/MOBMOD_ALWAYS_AGGRO writeup,
-- 2026-09-16). DSP's CZoneEntities::SpawnMOBs gates CanAggroTarget() on expGain > 50
-- (charutils::GetRealExp()); Assault-tier mobs give ~0 exp against endgame characters, so they
-- never validate to aggro at all (only direct-engage combat works) even though the same Lua/SQL
-- aggroes correctly on Topaz. Forcing MOBMOD_ALWAYS_AGGRO on every mob this instance spawns
-- restores real aggro behavior without touching DSP's global exp-gap formula.
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

function onInstanceCreated(instance)
    for i, v in pairs(ID.mob[4]) do
        forceAggro(SpawnMob(v, instance))
    end

    -- Real captured position (258,-3,-239), same start/end room the Rune of Release appears at on
    -- completion. Previously left at the generic 7-Leujaoam-mission placeholder (476,8.479,39/40).
    local rune = instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC)
    local box = instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC)
    rune:setPos(258, -3, -239, 4)
    box:setPos(260, -2, -233, 235)
    rune:setStatus(STATUS_DISAPPEAR)
    box:setStatus(STATUS_DISAPPEAR)

    -- 2026-08-30 user-reported live: Vegetation was never visible/targetable at all, on widescan
    -- or in the client, but showed up under !navdebug -- real cause is npc_list's SQL default
    -- status=2 (DISAPPEAR) for all 29 Vegetation rows. This script only ever set Vegetation TO
    -- DISAPPEAR when Coney "eat" it (below), assuming it started NORMAL/visible -- it never did.
    -- Same visibility-bug class as the CUTSCENE_ONLY sweep found earlier this session, different
    -- status value.
    for _, vegId in ipairs(VEGETATION_IDS) do
        local veg = instance:getEntity(bit.band(vegId, 0xFFF), TYPE_NPC)
        veg:setStatus(STATUS_NORMAL)
        -- 2026-08-30: reset each patch's real 4-stage decay progress (mobs/Coney.lua) so a fresh
        -- run doesn't inherit stale grazing progress from whatever instance object last used
        -- this shared npc_list row.
        veg:setLocalVar("decayStage", 0)
    end

    instance:setLocalVar("vegetation_remaining", #VEGETATION_IDS)
    instance:setLocalVar("vegetation_failed", 0)

    -- Door/wall props need no special handling -- same finding already confirmed for this exact
    -- prop family in Leujaoam Cleansing's own onInstanceCreated (their default npc_list state is
    -- sufficient, no setAnimation()/open() call needed).
    -- 2026-08-29 CORRECTED: this comment previously listed
    -- "_1x9/_1xa/_1xb/_1xc/_1xd/_1xn/_1xw/_jx0/_jx7/_jx8" as this mission's door props -- that list
    -- does not match the live instance_entities table and appears to predate this zone's -1
    -- id-shift correction. The props actually registered to mission 4 right now are: _1x7
    -- (17060126), _1x8 (17060127), _1xa (17060129), _1xb (17060130), _1xc (17060131), _1xm
    -- (17060141), _1xz (17060154), _jx6 (17060161), _jx7 (17060162). None of these are wired
    -- via ID.npc here (SQL defaults only) -- flagged for review since no capture evidence was
    -- checked in this pass for whether that's correct for each of the 9.
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)
    -- Vegetation consumption/fail-check now lives in mobs/Coney.lua (real per-Coney seek/path/eat
    -- AI) -- nothing to do here anymore.
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

function onInstanceProgressUpdate(instance, progress)
    if progress >= 20 then
        instance:complete()
    end
end

function onInstanceComplete(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 8, 9) -- I-9, matches the real start position
    end

    instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(ID.npc.ANCIENT_LOCKBOX, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

function onEventUpdate(player, csid, option)
end

