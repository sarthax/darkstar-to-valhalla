-----------------------------------
-- Nyzul Isle: Pathos (floor-transition status effects / secondary-objective penalties)
-----------------------------------
-- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
-- 2026-09-02: ported from LandSandBoat's scripts/globals/nyzul/pathos.lua. Effect ids (tpz.effect.*)
-- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
-- and effect-flag ids (tpz.effectFlag.*) below are all real, confirmed against our own
-- scripts/globals/status.lua -- not fabricated. Power values are carried over from LSB verbatim,
-- several of which LSB itself marks "confirmed" (REGAIN 50 -> ported as 5 per LSB's own /50 scale
-- note, REGEN 15, REFRESH 10, STR_BOOST 30); SLOW's power is LSB's own placeholder, flagged by LSB
-- as "needs retail data" -- not independently verified here either.
--
-- Real client text ids (RESTRICTION_*/AFFLICTION_*/RECEIVED_*/MALFUNCTION/TIME_LOSS/TOKEN_LOSS) are
-- NOT in our own Nyzul_Isle/IDs.lua and are not fabricated here -- Nyzul.pathosName below is a
-- plain-text placeholder (same pattern as Nyzul.objectiveName), not a real client message.
--
-- Not ported: xi.effectFlag.ON_ZONE_PATHOS -- this flag doesn't exist in Topaz's effectFlag table
-- (a real gap, already noted in documentation/research/Nyzul_Isle_Salvage_Scoping.md's C3 item).
-- DISPELABLE/ERASABLE are still cleared below (both real, confirmed) -- only the "this is a Nyzul
-- pathos" bookkeeping tag is missing, which just means a generic dispel/erase could remove one of
-- these where retail wouldn't allow it. Removal here is otherwise fully explicit
-- (xi.nyzul.removePathos/onGearDeath/onGearEngage), not flag-dependent, so this doesn't block
-- anything in this pass.
-----------------------------------
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
tpz = tpz or {}
Nyzul = Nyzul or {}

-- Duration is LSB's own real behavior ("automatically wear off when advancing to the next floor")
-- -- i.e. removal-driven (xi.nyzul.removePathos), not expiry-driven. A long fixed duration here is
-- just a safety net in case removal is ever missed; 3600s comfortably outlasts any single floor.
local PATHOS_DURATION = 3600

Nyzul.pathos =
{
    -- Negative effects
    [ 1] = { effect = EFFECT_IMPAIRMENT,    power = 0x01  }, -- Job Abilities restricted
    [ 2] = { effect = EFFECT_IMPAIRMENT,    power = 0x02  }, -- Weapon Skills restricted
    [ 3] = { effect = EFFECT_OMERTA,        power = 0x01  }, -- Songs restricted
    [ 4] = { effect = EFFECT_OMERTA,        power = 0x02  }, -- Black Magic restricted
    [ 5] = { effect = EFFECT_OMERTA,        power = 0x04  }, -- Blue Magic restricted
    [ 6] = { effect = EFFECT_OMERTA,        power = 0x08  }, -- Ninjutsu restricted
    [ 7] = { effect = EFFECT_OMERTA,        power = 0x10  }, -- Summoning Magic restricted
    [ 8] = { effect = EFFECT_OMERTA,        power = 0x20  }, -- White Magic restricted
    [ 9] = { effect = EFFECT_SLOW,          power = 2000  }, -- Attack speed down -- LSB: needs retail data
    [10] = { effect = EFFECT_FAST_CAST,     power = -30   }, -- Casting speed down
    [11] = { effect = EFFECT_DEBILITATION,  power = 0x001 }, -- STR down
    [12] = { effect = EFFECT_DEBILITATION,  power = 0x002 }, -- DEX down
    [13] = { effect = EFFECT_DEBILITATION,  power = 0x004 }, -- VIT down
    [14] = { effect = EFFECT_DEBILITATION,  power = 0x008 }, -- AGI down
    [15] = { effect = EFFECT_DEBILITATION,  power = 0x010 }, -- INT down
    [16] = { effect = EFFECT_DEBILITATION,  power = 0x020 }, -- MND down
    [17] = { effect = EFFECT_DEBILITATION,  power = 0x040 }, -- CHR down

    -- Positive effects
    [18] = { effect = EFFECT_REGAIN,        power = 5     }, -- LSB: confirmed 50 (their /10 power scale)
    [19] = { effect = EFFECT_REGEN,         power = 15    }, -- LSB: confirmed 15
    [20] = { effect = EFFECT_REFRESH,       power = 10    }, -- LSB: confirmed 10
    [21] = { effect = EFFECT_FLURRY,        power = 15    },
    [22] = { effect = EFFECT_CONCENTRATION, power = 30    },
    [23] = { effect = EFFECT_STR_BOOST_II,  power = 30    }, -- LSB: confirmed 30
    [24] = { effect = EFFECT_DEX_BOOST_II,  power = 30    },
    [25] = { effect = EFFECT_VIT_BOOST_II,  power = 30    },
    [26] = { effect = EFFECT_AGI_BOOST_II,  power = 30    },
    [27] = { effect = EFFECT_INT_BOOST_II,  power = 30    },
    [28] = { effect = EFFECT_MND_BOOST_II,  power = 30    },
    [29] = { effect = EFFECT_CHR_BOOST_II,  power = 30    },
}

-- Placeholder names for PrintToPlayer feedback -- NOT real client text (see header note).
Nyzul.pathosName =
{
    [ 1] = "Job Abilities restricted",   [ 2] = "Weapon Skills restricted",
    [ 3] = "Songs restricted",           [ 4] = "Black Magic restricted",
    [ 5] = "Blue Magic restricted",      [ 6] = "Ninjutsu restricted",
    [ 7] = "Summoning Magic restricted", [ 8] = "White Magic restricted",
    [ 9] = "Attack speed down",          [10] = "Casting speed down",
    [11] = "STR down",                   [12] = "DEX down",
    [13] = "VIT down",                   [14] = "AGI down",
    [15] = "INT down",                   [16] = "MND down",
    [17] = "CHR down",                   [18] = "Regain",
    [19] = "Regen",                      [20] = "Refresh",
    [21] = "Flurry",                     [22] = "Concentration",
    [23] = "STR up",                     [24] = "DEX up",
    [25] = "VIT up",                     [26] = "AGI up",
    [27] = "INT up",                     [28] = "MND up",
    [29] = "CHR up",
}

local function handlePathosEffectFlags(entity, effect)
    entity:getStatusEffect(effect):unsetFlag(EFFECTFLAG_DISPELABLE)
    entity:getStatusEffect(effect):unsetFlag(EFFECTFLAG_ERASABLE)
    -- EFFECTFLAG_ON_ZONE_PATHOS doesn't exist -- see file header.
end

-- Negative pathos/penalty applied when a secondary (Archaic Gear) objective is failed.
local function addGearPenalty(mob)
    local instance = mob:getInstance()
    local pathos = instance:getLocalVar("floorPathos")
    local penalty = instance:getLocalVar("gearPenalty")
    local chars = instance:getChars()

    if penalty == Nyzul.penalty.TIME then
        -- 2026-09-03: real bug fixed -- this called instance:setTimeLimit(...), which doesn't
        -- exist on CLuaInstance (only CLuaBattlefield has it -- confirmed via
        -- src/map/lua/lua_instance.cpp's real SOL_REGISTER list, getTimeLimit is read-only there,
        -- no setter of any kind). Would have thrown a real Lua error every time this branch fired.
        -- Actually reducing the instance's time limit needs a new C++ binding (same category of
        -- gap as the addAssaultPoint region-5 fix earlier this session) -- not done here. The
        -- messages still fire (real ids) so the penalty is at least communicated even though the
        -- actual time reduction isn't applied yet.
        for _, player in pairs(chars) do
            player:messageText(player, NyzulIsle.text.GEAR_PENALTY_MALFUNCTION)
            player:messageSpecial(NyzulIsle.text.GEAR_PENALTY_TIME, 1)
        end
    elseif penalty == Nyzul.penalty.TOKENS then
        instance:setLocalVar("tokenPenalty", instance:getLocalVar("tokenPenalty") + 1)
        for _, player in pairs(chars) do
            player:messageText(player, NyzulIsle.text.GEAR_PENALTY_MALFUNCTION)
            player:messageText(player, NyzulIsle.text.GEAR_PENALTY_TOKENS)
        end
    else
        local availablePathos = {}
        for i = 1, 17 do
            if not utils.mask.getBit(pathos, i) then
                table.insert(availablePathos, i)
            end
        end

        if #availablePathos > 0 then
            local randomEffect = availablePathos[math.random(1, #availablePathos)]
            instance:setLocalVar("floorPathos", utils.mask.setBit(pathos, randomEffect, true))

            local entry = Nyzul.pathos[randomEffect]
            local effect = entry.effect
            local power = entry.power

            for _, player in pairs(chars) do
                if
                    effect == EFFECT_IMPAIRMENT or
                    effect == EFFECT_OMERTA or
                    effect == EFFECT_DEBILITATION
                then
                    if player:hasStatusEffect(effect) then
                        power = bit.bor(player:getStatusEffect(effect):getPower(), power)
                    end
                end

                player:addStatusEffect(effect, power, 0, PATHOS_DURATION)
                handlePathosEffectFlags(player, effect)
                -- Real per-effect id (NyzulIsle.text.PATHOS_APPLIED, matched by meaning to
                -- Nyzul.pathos's own 29 entries) plus the generic "you feel an incredible
                -- pressure..." flavor text (PATHOS_RECEIVED, 7346) both real, both shown.
                player:messageText(player, NyzulIsle.text.PATHOS_RECEIVED)
                if NyzulIsle.text.PATHOS_APPLIED[randomEffect] then
                    player:messageText(player, NyzulIsle.text.PATHOS_APPLIED[randomEffect])
                end

                if player:hasPet() then
                    local pet = player:getPet()
                    pet:addStatusEffect(effect, power, 0, PATHOS_DURATION)
                    handlePathosEffectFlags(pet, effect)
                end
            end
        end
    end
end

Nyzul.removePathos = function(instance)
    if instance:getLocalVar("floorPathos") > 0 then
        for i = 1, #Nyzul.pathos do
            if utils.mask.getBit(instance:getLocalVar("floorPathos"), i) then
                local chars = instance:getChars()

                for _, players in pairs(chars) do
                    players:delStatusEffectSilent(Nyzul.pathos[i].effect)
                    -- Real per-effect removal id (NyzulIsle.text.PATHOS_REMOVED), sent separately since
                    -- delStatusEffectSilent deliberately skips the engine's own generic
                    -- effect-wore-off message.
                    if NyzulIsle.text.PATHOS_REMOVED[i] then
                        players:messageText(players, NyzulIsle.text.PATHOS_REMOVED[i])
                    end

                    if players:hasPet() then
                        players:getPet():delStatusEffectSilent(Nyzul.pathos[i].effect)
                    end
                end

                instance:setLocalVar("floorPathos", utils.mask.setBit(instance:getLocalVar("floorPathos"), i, false))
            end
        end
    end
end

-- 2026-09-12, user-requested: two independent pathos sources now exist -- the per-floor 30% roll
-- (nyzul.lua's handleProgress) and the real left/right rune-choice roll (Rune_of_Transfer.lua) --
-- and the user wants BOTH to be able to land on the same floor and STACK, rather than one silently
-- blocking the other. `randomPathos` (a single scalar id) can't represent "two different pending
-- effects" at once, so it's replaced with `pendingPathos`, a bitmask queued the same way
-- `floorPathos` already tracks currently-ACTIVE ones -- each caller ORs its own pick in via
-- `Nyzul.queuePathos()` instead of clobbering a shared scalar.
--
-- Picks one pathos id that is neither already active on the floor (`floorPathos`) nor already
-- queued for the next one (`pendingPathos`) -- user-requested: "the effect chosen should not be one
-- that is already in effect on the players." Same exclusion-list pattern `addGearPenalty` above
-- already uses for its own 1-17 subset, generalized here to the full 1-29 range. Returns nil (and
-- queues nothing) on the practically-impossible case that all 29 are already active/queued.
local function pickAvailablePathos(instance)
    local combined = bit.bor(instance:getLocalVar("floorPathos"), instance:getLocalVar("pendingPathos"))
    local available = {}

    for i = 1, #Nyzul.pathos do
        if not utils.mask.getBit(combined, i) then
            table.insert(available, i)
        end
    end

    if #available == 0 then
        return nil
    end

    return available[math.random(1, #available)]
end

-- Called by any real source of a floor-transition pathos (the per-floor 30% roll, the real
-- left/right rune choice) to queue ONE additional effect for the next floor. Safe to call from
-- both in the same floor-clear -- each call excludes whatever the other already queued, so they
-- stack as two distinct effects rather than one overwriting the other.
Nyzul.queuePathos = function(instance)
    local id = pickAvailablePathos(instance)
    if id then
        instance:setLocalVar("pendingPathos", utils.mask.setBit(instance:getLocalVar("pendingPathos"), id, true))
    end
end

-- Pathos received on floor entry -- applies every effect queued via queuePathos() since the last
-- floor transition (there may be more than one, see header above).
Nyzul.addFloorPathos = function(instance)
    local pending = instance:getLocalVar("pendingPathos")
    if pending <= 0 then
        return
    end

    local chars = instance:getChars()

    for i = 1, #Nyzul.pathos do
        if utils.mask.getBit(pending, i) then
            instance:setLocalVar("floorPathos", utils.mask.setBit(instance:getLocalVar("floorPathos"), i, true))

            local entry = Nyzul.pathos[i]
            for _, player in pairs(chars) do
                player:addStatusEffect(entry.effect, entry.power, 0, PATHOS_DURATION)
                handlePathosEffectFlags(player, entry.effect)
                -- Real ids -- generic pathos-received flavor text (7346) plus the specific
                -- per-effect applied message, same treatment as addGearPenalty above.
                player:messageText(player, NyzulIsle.text.PATHOS_RECEIVED)
                if NyzulIsle.text.PATHOS_APPLIED[i] then
                    player:messageText(player, NyzulIsle.text.PATHOS_APPLIED[i])
                end

                if player:hasPet() then
                    local pet = player:getPet()
                    pet:addStatusEffect(entry.effect, entry.power, 0, PATHOS_DURATION)
                    handlePathosEffectFlags(pet, entry.effect)
                end
            end
        end
    end

    instance:setLocalVar("pendingPathos", 0)
end

-- Apply currently-active floor pathos to a pet spawned mid-floor (e.g. summoned after the pathos
-- was already applied to the rest of the party).
Nyzul.addPetSpawnPathos = function(player)
    local pet = player:getPet()
    local floorPathos = player:getInstance():getLocalVar("floorPathos")

    for i = 1, #Nyzul.pathos do
        if utils.mask.getBit(floorPathos, i) then
            local entry = Nyzul.pathos[i]
            pet:addStatusEffect(entry.effect, entry.power, 0, PATHOS_DURATION)
            handlePathosEffectFlags(pet, entry.effect)
        end
    end
end

-- Archaic Gear secondary-objective hooks -- call from a gear mob's onMobEngaged/onMobDeath.
Nyzul.onGearEngage = function(mob, target)
    local instance = mob:getInstance()

    if
        instance:getLocalVar("gearObjective") == Nyzul.gearObjective.AVOID_AGRO and
        mob:getCE(target) == 0 and
        mob:getVE(target) == 0 and
        mob:getLocalVar("initialAgro") == 0
    then
        mob:setLocalVar("initialAgro", 1)
        addGearPenalty(mob)
    end
end

-- 2026-09-03: signature fixed to this codebase's real onMobDeath convention (positional
-- isKiller/noKiller args, e.g. scripts/zones/Apollyon/mobs/*.lua) -- was LSB's own table-style
-- `optParams.isKiller`, which doesn't match how Topaz actually calls onMobDeath.
Nyzul.onGearDeath = function(mob, player, isKiller, noKiller)
    if isKiller or noKiller then
        local instance = mob:getInstance()
        if instance:getLocalVar("gearObjective") == Nyzul.gearObjective.DO_NOT_DESTROY then
            addGearPenalty(mob)
        end
    end
end

return Nyzul
