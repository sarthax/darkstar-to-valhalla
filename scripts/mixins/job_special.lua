--[[ -----------------------------
Mobs that use their main job's 2-hour ability sometime under 40-60% HP.

DSP-PORT (2026-09-14): ported from Topaz's scripts/mixins/job_special.lua, but with a genuinely
different integration mechanism, not just renamed constants -- confirmed old-dsp-reference has NO
event-listener/mixin-auto-apply system at all (the `mixins = {...}` global Topaz's own C++
(luautils.cpp:2360, applyMixins) reads and auto-invokes after spawn has no equivalent anywhere in
old-dsp-reference's C++ -- confirmed by grep, zero native scripts even use it). old-dsp-reference's
real, idiomatic mechanism instead is a set of DIRECT per-mob-script callback functions the engine
calls itself (luautils.h): onMobSpawn, onMobEngaged, onMobFight (called every 3 sec during
combat -- this codebase's real equivalent of Topaz's "COMBAT_TICK" listener), onMobDisengage.
So this module is a plain function library, not an addListener-based mixin -- a mob script that
wants this behavior calls JobSpecialMix.onSpawn/onEngage/onFight directly from its own real
onMobSpawn/onMobEngaged/onMobFight functions (see Broken_Troll_Soldier.lua for the reference
integration).

This can be modified by calling JobSpecialMix.config(mob, params) from within the mob's own
onMobSpawn, AFTER calling JobSpecialMix.onSpawn(mob) (config overrides the defaults onSpawn sets).

params is a table that can contain the following keys:
    between    : Number of seconds between using any specials. Only matters if mob has multiple specials.
    chance     : Percent chance that a mob will use a special at all during engagement. (0 to 100)
    delay      : Grace period at start of fight, during which mob will not use any special, regardless of HPP. Min-clamped at 2. (2 to any)
    specials   : Table of job specials, each entry a table that can contain:
      id       : real mob_skills.sql id for the 2hr mob-skill (see JOB_2HR_MOBSKILL below). Required.
      cooldown : cooldown in seconds for this special. Optional. Default 7200.
      hpp      : mob must be below this HP percent to use this special. Optional. Default random 40-60.

NOT ported from Topaz's version: per-special begCode/endCode callbacks (fired via
addListener("JOB_SPECIAL_BEG_i"/"JOB_SPECIAL_END_i", ...) in Topaz) and per-special custom
`duration` overrides (via getStatusEffect(effect):setDuration(...), which needs an
ability-id -> effect-id map (effectByAbility) this port doesn't build since nothing in this
project's scope needs it yet) -- neither is used by this project's real, confirmed use case
(Broken_Troll_Soldier, default config, no overrides at all). Add both back the same way
`config()` is extended below if a future mob genuinely needs them.

Also NOT ported: Topaz's RNG-family Eagle Eye Shot table (familyEES) and SMN-in-Dynamis Astral
Flow (Maat) special-case -- neither is reachable by this project's real Assault content, and
porting either without a live capture/wiki source to verify against would mean guessing.
---------------------------------------------------------------- --]]
require("scripts/globals/status")
require("scripts/globals/utils")
-----------------------------------

JobSpecialMix = JobSpecialMix or {}

-- Real mob_skills.sql ids (2026-09-14, confirmed against sql/mob_skills.sql -- the same real
-- "job 2hr as a mob skill" cluster old-dsp-reference's own Attohwa_Chasm/mobs/Tiamat.lua already
-- uses live: `mob:useMobAbility(688)` there for WAR's Mighty Strikes is this exact same id).
-- Missing from this table entirely, not fabricated: RNG (its real 2hr is the family-based Eagle
-- Eye Shot mechanic, out of scope -- see header), and COR/PUP/DNC/SCH/GEO/RUN (Topaz's own
-- job_special.lua doesn't define these either -- "not yet defined on tpz.jsa").
local JOB_2HR_MOBSKILL =
{
    [JOBS.WAR] = 688, -- mighty_strikes
    [JOBS.MNK] = 690, -- hundred_fists
    [JOBS.WHM] = 689, -- benediction
    [JOBS.BLM] = 691, -- manafont
    [JOBS.RDM] = 692, -- chainspell
    [JOBS.THF] = 693, -- perfect_dodge
    [JOBS.PLD] = 694, -- invincible
    [JOBS.DRK] = 695, -- blood_weapon
    [JOBS.BST] = 740, -- familiar
    [JOBS.BRD] = 696, -- soul_voice
    [JOBS.SAM] = 730, -- meikyo_shisui
    [JOBS.NIN] = 731, -- mijin_gakure
    [JOBS.DRG] = 732, -- call_wyvern
    [JOBS.SMN] = 734, -- astral_flow
    [JOBS.BLU] = 2257, -- azure_lore
}

JobSpecialMix.config = function(mob, params)
    if params.between and type(params.between) == "number" then
        mob:setLocalVar("[jobSpecial]between", utils.clamp(params.between, 0))
    end

    if params.chance and type(params.chance) == "number" then
        mob:setLocalVar("[jobSpecial]chance", utils.clamp(params.chance, 0, 100))
    end

    if params.delay and type(params.delay) == "number" then
        mob:setLocalVar("[jobSpecial]delayInitial", utils.clamp(params.delay, 2))
    end

    if params.specials and type(params.specials) == "table" then
        local i = 0
        for _, v in pairs(params.specials) do
            if v.id and type(v.id) == "number" then
                i = i + 1
                mob:setLocalVar("[jobSpecial]ability_" .. i, v.id)
                mob:setLocalVar("[jobSpecial]between_" .. i,
                    (v.cooldown and type(v.cooldown) == "number") and utils.clamp(v.cooldown, 0) or 7200)
                mob:setLocalVar("[jobSpecial]hpp_" .. i,
                    (v.hpp and type(v.hpp) == "number") and utils.clamp(v.hpp, 0, 100) or math.random(40, 60))
            end
        end
        mob:setLocalVar("[jobSpecial]numAbilities", i)
    end
end

-- at spawn, give mob its default main job 2hr, which it'll use at 40-60% HP. Call
-- JobSpecialMix.config(mob, {...}) afterward (from the mob's own onMobSpawn) to override.
JobSpecialMix.onSpawn = function(mob)
    local ability = JOB_2HR_MOBSKILL[mob:getMainJob()]

    if ability then
        mob:setLocalVar("[jobSpecial]numAbilities", 1)
        mob:setLocalVar("[jobSpecial]ability_1", ability)
        mob:setLocalVar("[jobSpecial]hpp_1", math.random(40, 60))
        mob:setLocalVar("[jobSpecial]between_1", 7200)
    end

    mob:setLocalVar("[jobSpecial]chance", 100)     -- chance that mob will use any special at all during engagement
    mob:setLocalVar("[jobSpecial]delayInitial", 2) -- default wait until mob can use its first special (prevents insta-flow)
end

-- call from the mob's own real onMobEngaged(mob, target).
JobSpecialMix.onEngage = function(mob)
    if math.random(100) <= mob:getLocalVar("[jobSpecial]chance") then
        mob:setLocalVar("[jobSpecial]readyInitial", os.time() + mob:getLocalVar("[jobSpecial]delayInitial"))
    end
end

local function abilitiesReady(mob)
    local abilities = {}
    local now = os.time()
    local readyTime = mob:getLocalVar("[jobSpecial]readyInitial")

    if readyTime > 0 and now > readyTime and now > mob:getLocalVar("[jobSpecial]cooldown") then
        local numAbilities = mob:getLocalVar("[jobSpecial]numAbilities")
        for i = 1, numAbilities do
            if now > mob:getLocalVar("[jobSpecial]cooldown_" .. i) and mob:getHPP() <= mob:getLocalVar("[jobSpecial]hpp_" .. i) then
                table.insert(abilities, i)
            end
        end
    end

    return abilities
end

-- call from the mob's own real onMobFight(mob, target) -- old-dsp-reference calls this every
-- 3 seconds while the mob is fighting, this project's real equivalent of Topaz's "COMBAT_TICK".
JobSpecialMix.onFight = function(mob, target)
    local abilities = abilitiesReady(mob)
    if #abilities == 0 then
        return
    end

    local i = abilities[math.random(#abilities)]
    local ability = mob:getLocalVar("[jobSpecial]ability_" .. i)
    local now = os.time()

    mob:useMobAbility(ability)

    mob:setLocalVar("[jobSpecial]cooldown_" .. i, now + mob:getLocalVar("[jobSpecial]between_" .. i))
    mob:setLocalVar("[jobSpecial]cooldown", now + mob:getLocalVar("[jobSpecial]between"))
end

return JobSpecialMix
