-----------------------------------
-- Area: Ilrusi Atoll (Demolition Duty)
--  Mob: Demolition Automaton
-----------------------------------
-- DSP port of the Topaz mobs/Demolition_Automaton.lua (same mission). This file did not exist in
-- old-dsp-reference: the automaton never had any AI, so even with an NPC to issue it, it would
-- neither follow its master nor attack Wreckage. Behavior matches Topaz: follow the master, engage
-- a live Wreckage once the master has led it near, leash-shutdown countdown, Imp/Crab hate pulses,
-- Slapstick/Knockout/Magic Mortar spawn the paired Carrion Crab.
-- Topaz ID.mob[44].* tables are replaced with the real literal ids (same values as Topaz IDs.lua).
-----------------------------------
package.loaded["scripts/zones/Ilrusi_Atoll/TextIDs"] = nil;
require("scripts/zones/Ilrusi_Atoll/TextIDs");
require("scripts/globals/status")
-----------------------------------
local AI_TICK_MS = 3000
local LEASH_RANGE = 25
local LEASH_COUNTDOWN_SEC = 5
local WRECKAGE_ENGAGE_RANGE = 8
local WRECKAGE_APPROACH_STANDOFF = 4
local MASTER_WRECKAGE_RANGE = 10

local WRECKAGE_IDS = { 17002546, 17002547, 17002548, 17002549, 17002550 }
local IMP_IDS = { 17002556, 17002557, 17002558, 17002559, 17002560, 17002561, 17002562, 17002563 }
local CRAB_IDS = { 17002551, 17002552, 17002553, 17002554, 17002555 }
local CRAB_FOR_WRECKAGE =
{
    [17002546] = 17002551, [17002547] = 17002552, [17002548] = 17002553,
    [17002549] = 17002554, [17002550] = 17002555,
}
local AUTOMATON_MOB_SKILL_IDS = { [1943] = true, [2067] = true, [2301] = true }

local THREAT_HATE_RANGE = 20.0
local THREAT_HATE_CE = 1000
local THREAT_HATE_VE = 3000
local THREAT_HATE_PULSE_MS = 1500

-- Crabs are dormant until a skill connects; GetMobByID on a never-spawned mob logs a warning.
local spawnedCrabIds = {}

local function pulseThreatHate(mob, instance)
    for _, threatId in ipairs(IMP_IDS) do
        local threat = GetMobByID(threatId, instance)
        if threat and threat:isAlive() and mob:checkDistance(threat) <= THREAT_HATE_RANGE then
            threat:addEnmity(mob, THREAT_HATE_CE, THREAT_HATE_VE)
        end
    end
    for _, crabId in ipairs(CRAB_IDS) do
        if spawnedCrabIds[crabId] then
            local threat = GetMobByID(crabId, instance)
            if threat and threat:isAlive() and mob:checkDistance(threat) <= THREAT_HATE_RANGE then
                threat:addEnmity(mob, THREAT_HATE_CE, THREAT_HATE_VE)
            end
        end
    end
end

local function pulseThreatHateLoop(mob)
    if not mob:isAlive() then
        return
    end
    local instance = mob:getInstance()
    if not instance or instance:completed() then
        return
    end
    pulseThreatHate(mob, instance)
end

local function findNearestLiveWreckage(fromEntity, instance, maxRange)
    local nearest, nearestDist
    for _, wId in ipairs(WRECKAGE_IDS) do
        local w = GetMobByID(wId, instance)
        if w and w:isAlive() then
            local dist = fromEntity:checkDistance(w)
            if (not maxRange or dist <= maxRange) and (not nearestDist or dist < nearestDist) then
                nearest, nearestDist = w, dist
            end
        end
    end
    return nearest
end

-- Point WRECKAGE_APPROACH_STANDOFF short of the target, so the walk never carries the automaton through it.
local function approachPoint(mob, target, standoff)
    local dx = mob:getXPos() - target:getXPos()
    local dz = mob:getZPos() - target:getZPos()
    local dist = math.sqrt(dx * dx + dz * dz)
    if dist < 0.01 then
        return target:getXPos(), target:getYPos(), target:getZPos()
    end
    local scale = standoff / dist
    return target:getXPos() + dx * scale, target:getYPos(), target:getZPos() + dz * scale
end

local function aiTick(mob)
    if not mob:isAlive() then
        return
    end
    -- Two drivers (own mob:timer chain + the instance's onInstanceTimeUpdate, see below): rate-limit so
    -- they never double-tick. mob:timer alone was not reliably keeping the follow loop alive.
    local now = os.time()
    if now - mob:getLocalVar("lastAiTick") < 2 then
        return
    end
    mob:setLocalVar("lastAiTick", now)
    local instance = mob:getInstance()
    if not instance or instance:completed() then
        return
    end

    pulseThreatHate(mob, instance) -- was its own mob:timer loop; now rides the instance tick
    local function again()
        -- no self-timer: a mob:timer callback firing after despawn/completion derefs a freed mob
        -- (map-server crash in getInstance). The instance's onInstanceTimeUpdate drives the tick.
    end

    local masterId = mob:getLocalVar("master")
    local master = nil
    if masterId ~= 0 then
        master = GetPlayerByID(masterId)
    end
    if not master then
        again()
        return
    end

    if mob:getLocalVar("repairing") == 1 then
        -- repair is cancelled if the automaton takes damage during it (polled; no per-hit hook)
        if mob:getHP() < mob:getLocalVar("repairHpAtStart") then
            mob:setLocalVar("repairing", 0)
            master:PrintToPlayer("The repair was interrupted!")
        else
            again()
            return
        end
    end

    local dist = mob:checkDistance(master)
    if dist > LEASH_RANGE then
        if mob:getLocalVar("leashCounting") == 0 then
            mob:setLocalVar("leashCounting", 1)
            master:messageText(mob, AUTOMATON_MASTER_NOT_FOUND)
            master:messageText(mob, AUTOMATON_SHUTDOWN_COUNTDOWN)
            local countdownTexts =
            {
                AUTOMATON_COUNTDOWN_5, AUTOMATON_COUNTDOWN_4, AUTOMATON_COUNTDOWN_3,
                AUTOMATON_COUNTDOWN_2, AUTOMATON_COUNTDOWN_1,
            }
            for i, textId in ipairs(countdownTexts) do
                mob:timer((i - 1) * 1000, function()
                    if mob:isAlive() and mob:getLocalVar("leashCounting") == 1 then
                        local m = GetPlayerByID(mob:getLocalVar("master"))
                        if m then
                            m:messageText(mob, textId)
                        end
                    end
                end)
            end
            mob:timer(LEASH_COUNTDOWN_SEC * 1000, function()
                if mob:isAlive() and mob:getLocalVar("leashCounting") == 1 then
                    local m = GetPlayerByID(mob:getLocalVar("master"))
                    if m then
                        m:messageText(mob, AUTOMATON_DELETE)
                        m:messageText(mob, AUTOMATON_MALFUNCTION)
                    end
                    local inst = mob:getInstance()
                    if inst then
                        inst:setLocalVar("automatonId", 0)
                        inst:setLocalVar("automatonLostToLeash", 1)
                    end
                    mob:setHP(0)
                    mob:setStatus(STATUS_DISAPPEAR)
                end
            end)
        end
        again()
        return
    elseif mob:getLocalVar("leashCounting") == 1 then
        mob:setLocalVar("leashCounting", 0)
        master:messageText(mob, AUTOMATON_SAFETY_SHUTDOWN)
    end

    if mob:isEngaged() then
        again()
        return
    end

    local wreckage = findNearestLiveWreckage(master, instance, MASTER_WRECKAGE_RANGE)
    if not wreckage then
        if mob:checkDistance(master) > WRECKAGE_ENGAGE_RANGE then
            mob:pathTo(master:getXPos(), master:getYPos(), master:getZPos(), 11) -- RUN|WALLHACK|SCRIPT
        end
        again()
        return
    end

    if mob:checkDistance(wreckage) <= WRECKAGE_ENGAGE_RANGE then
        if mob:getLocalVar("wreckageTargetId") ~= wreckage:getID() then
            mob:setLocalVar("wreckageTargetId", wreckage:getID())
            master:messageText(mob, AUTOMATON_TARGET_ACQUIRED)
        end
        mob:engage(wreckage:getShortID())
    else
        local ax, ay, az = approachPoint(mob, wreckage, WRECKAGE_APPROACH_STANDOFF)
        mob:pathTo(ax, ay, az, 11)
    end

    again()
end

function onMobSpawn(mob)
    mob:setAllegiance(1) -- friendly ally
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
    mob:setMod(MOD_ATTP, -40)
    mob:setMobMod(MOBMOD_TP_USE_CHANCE, 50)
    mob:addStatusEffect(EFFECT_REGAIN, 5, 3, 0) -- +50 TP every 3s
end

-- Slapstick / Knockout / Magic Mortar spawn (and aggro) the Carrion Crab paired with the Wreckage hit.
function onMobWeaponSkill(target, mob, skill)
    if not AUTOMATON_MOB_SKILL_IDS[skill:getID()] then
        return
    end
    local instance = mob:getInstance()
    if not instance then
        return
    end
    local crabId = CRAB_FOR_WRECKAGE[target:getID()]
    if not crabId then
        return
    end
    if spawnedCrabIds[crabId] then
        local crab = GetMobByID(crabId, instance)
        if crab and crab:isAlive() then
            return
        end
    end
    GetMobByID(crabId, instance):setSpawn(target:getXPos(), target:getYPos(), target:getZPos(), 0)
    SpawnMob(crabId, instance)
    spawnedCrabIds[crabId] = true
    local liveCrab = GetMobByID(crabId, instance)
    if liveCrab then
        liveCrab:addEnmity(mob, THREAT_HATE_CE, THREAT_HATE_VE)
    end
end

function onMobDeath(mob, player, isKiller)
    local instance = mob:getInstance()
    if instance then
        instance:setLocalVar("automatonId", 0)
        instance:setLocalVar("automatonLostToLeash", 0)
    end
end

-- Called every instance tick from instances/demolition_duty.lua's onInstanceTimeUpdate.
function DemolitionAutomatonTick(mob)
    aiTick(mob)
end
