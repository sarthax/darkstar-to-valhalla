-----------------------------------
-- Geomancer helpers (slice run-geo-jobs)
-- Ported from LSB job_utils/geomancer.lua (Indi/Geo aura model).
-- Spell ids: Indi 768-797, Geo 798-827 (same order as GEOMANCER.spells).
-- The aura engine lives in C++ (CStatusEffectContainer::HandleAura); this file places the
-- COLURE_ACTIVE effect and computes potency. Merits / job points are not wired (treated as 0).
-----------------------------------

require("scripts/globals/status");

GEOMANCER = {};

GEOMANCER.LUOPAN_PETID       = 75;   -- pet_list row (geo_luopan_pet.sql)
GEOMANCER.SKILL_HANDBELL     = 45;   -- client skill id, unused slot in DSP status.lua
GEOMANCER.INDI_BASE_DURATION = 180;  -- seconds
GEOMANCER.LUOPAN_LIFETIME    = 600;  -- seconds
GEOMANCER.WIDENED_AURA_SIZE  = 625;  -- AURA_SIZE mod while Widened Compass is up
GEOMANCER.POTENCY_SCALE      = 1.0;  -- tunable, 1.0 = LSB values

-- basic message ids (src/map/packets/message_basic.h)
GEOMANCER.MSG_UNABLE_TO_CAST = 18;
GEOMANCER.MSG_UNABLE_JA      = 87;
GEOMANCER.MSG_CANNOT_CAST    = 47;

local visualElement = { FIRE = 0, ICE = 1, WIND = 2, EARTH = 3, THUNDER = 4, WATER = 5, LIGHT = 6, DARK = 7 };
local luopanModel   = { FIRE = 2850, ICE = 2851, WIND = 2852, EARTH = 2853, THUNDER = 2854, WATER = 2855, LIGHT = 2856, DARK = 2865 };

-- effect ids (geo_effects.sql)

GEOMANCER.effect =
{
    GEO_REGEN = 539,
    GEO_POISON = 540,
    GEO_REFRESH = 541,
    GEO_STR_BOOST = 542,
    GEO_DEX_BOOST = 543,
    GEO_VIT_BOOST = 544,
    GEO_AGI_BOOST = 545,
    GEO_INT_BOOST = 546,
    GEO_MND_BOOST = 547,
    GEO_CHR_BOOST = 548,
    GEO_ATTACK_BOOST = 549,
    GEO_DEFENSE_BOOST = 550,
    GEO_MAGIC_ATK_BOOST = 551,
    GEO_MAGIC_DEF_BOOST = 552,
    GEO_ACCURACY_BOOST = 553,
    GEO_EVASION_BOOST = 554,
    GEO_MAGIC_ACC_BOOST = 555,
    GEO_MAGIC_EVASION_BOOST = 556,
    GEO_ATTACK_DOWN = 557,
    GEO_DEFENSE_DOWN = 558,
    GEO_MAGIC_ATK_DOWN = 559,
    GEO_MAGIC_DEF_DOWN = 560,
    GEO_ACCURACY_DOWN = 561,
    GEO_EVASION_DOWN = 562,
    GEO_MAGIC_ACC_DOWN = 563,
    GEO_MAGIC_EVASION_DOWN = 564,
    GEO_SLOW = 565,
    GEO_PARALYSIS = 566,
    GEO_WEIGHT = 567,
    GEO_HASTE = 580,
};

-- {maxSkill, minPotency, maxPotency, geoModMultiplier}
local potencyData =
{
    [539] = { 600, 1, 30, 2 }, -- regen
    [540] = { 600, 1, 30, 3 }, -- poison
    [541] = { 900, 1, 6, 1 }, -- refresh
    [542] = { 900, 1, 25, 2 }, -- str_boost
    [543] = { 900, 1, 25, 2 }, -- dex_boost
    [544] = { 900, 1, 25, 2 }, -- vit_boost
    [545] = { 900, 1, 25, 2 }, -- agi_boost
    [546] = { 900, 1, 25, 2 }, -- int_boost
    [547] = { 900, 1, 25, 2 }, -- mnd_boost
    [548] = { 900, 1, 25, 2 }, -- chr_boost
    [549] = { 900, 4.6, 34.7, 2.7 }, -- attack_boost
    [550] = { 900, 9.7, 39.8, 4.6 }, -- defense_boost
    [551] = { 900, 3, 15, 3 }, -- magic_atk_boost
    [552] = { 900, 5, 20, 4 }, -- magic_def_boost
    [553] = { 900, 1, 50, 5 }, -- accuracy_boost
    [554] = { 900, 1, 65, 5 }, -- evasion_boost
    [555] = { 900, 1, 50, 5 }, -- magic_acc_boost
    [556] = { 900, 1, 65, 6 }, -- magic_evasion_boost
    [557] = { 900, 4.6, 25, 4.6 }, -- attack_down
    [558] = { 900, 2.7, 14.8, 2.7 }, -- defense_down
    [559] = { 900, 5, 20, 4 }, -- magic_atk_down
    [560] = { 900, 3, 15, 3 }, -- magic_def_down
    [561] = { 900, 1, 65, 6 }, -- accuracy_down
    [562] = { 900, 1, 50, 5 }, -- evasion_down
    [563] = { 900, 1, 65, 6 }, -- magic_acc_down
    [564] = { 900, 1, 50, 5 }, -- magic_evasion_down
    [565] = { 900, 0.9, 14.9, 0.5 }, -- slow
    [566] = { 900, 1, 15, 1 }, -- paralysis
    [567] = { 900, 3.9, 19.9, 1.1 }, -- weight
    [580] = { 900, 2.4, 29.9, 1.1 }, -- haste
};

-- spells in id order: {name, effect, targetType, indi element, geo luopan element}
GEOMANCER.spells =
{
    { "regen", 539, 0, "LIGHT", "LIGHT" },
    { "poison", 540, 1, "WATER", "WATER" },
    { "refresh", 541, 0, "LIGHT", "LIGHT" },
    { "haste", 580, 0, "WIND", "WIND" },
    { "str", 542, 0, "FIRE", "FIRE" },
    { "dex", 543, 0, "THUNDER", "THUNDER" },
    { "vit", 544, 0, "EARTH", "EARTH" },
    { "agi", 545, 0, "WIND", "WIND" },
    { "int", 546, 0, "ICE", "ICE" },
    { "mnd", 547, 0, "WATER", "WATER" },
    { "chr", 548, 0, "LIGHT", "LIGHT" },
    { "fury", 549, 0, "FIRE", "FIRE" },
    { "barrier", 550, 0, "EARTH", "EARTH" },
    { "acumen", 551, 0, "ICE", "ICE" },
    { "fend", 552, 0, "WATER", "WATER" },
    { "precision", 553, 0, "THUNDER", "THUNDER" },
    { "voidance", 554, 0, "WIND", "WIND" },
    { "focus", 555, 0, "DARK", "DARK" },
    { "attunement", 556, 0, "LIGHT", "LIGHT" },
    { "wilt", 557, 1, "WATER", "WATER" },
    { "frailty", 558, 1, "WIND", "WIND" },
    { "fade", 559, 1, "FIRE", "FIRE" },
    { "malaise", 560, 1, "THUNDER", "THUNDER" },
    { "slip", 561, 1, "EARTH", "EARTH" },
    { "torpor", 562, 1, "ICE", "ICE" },
    { "vex", 563, 1, "LIGHT", "LIGHT" },
    { "languor", 564, 1, "DARK", "DARK" },
    { "slow", 565, 1, "EARTH", "EARTH" },
    { "paralysis", 566, 1, "ICE", "ICE" },
    { "gravity", 567, 1, "WIND", "WIND" },
};

local function getLuopan(player)
    local pet = player:getPet();
    if (pet ~= nil and pet:getPetID() == GEOMANCER.LUOPAN_PETID) then
        return pet;
    end
    return nil;
end
GEOMANCER.getLuopan = getLuopan;

local function clamp(v, lo, hi)
    if (v < lo) then return lo; end
    if (v > hi) then return hi; end
    return v;
end

function GEOMANCER.getPotency(player, effect)
    local d = potencyData[effect];
    local geoSkill = player:getSkillLevel(SKILL_GEO);
    local handbell = 0;
    if (player:getEquipID(SLOT_RANGED) ~= 0) then
        handbell = player:getSkillLevel(GEOMANCER.SKILL_HANDBELL);
    end
    local geomancyMod = player:getMod(MOD_GEOMANCY_BONUS);
    if (player:getObjType() ~= TYPE_PC) then
        geoSkill = player:getMod(MOD_GEOMANCY_SKILL);
    end
    local combined = clamp(handbell + geoSkill, 0, 900);
    local divisor  = d[1] / (d[3] - d[2]);
    local potency  = clamp(d[2] + combined / divisor, d[2], d[3]);
    if (geomancyMod > 0 and not player:hasStatusEffect(EFFECT_ENTRUST)) then
        potency = potency + geomancyMod * d[4];
    end
    potency = potency * GEOMANCER.POTENCY_SCALE;
    -- Haste/Slow power is x100 (LSB); the effect scripts convert to the 1024 base
    if (effect == GEOMANCER.effect.GEO_HASTE or effect == GEOMANCER.effect.GEO_SLOW) then
        potency = math.floor(potency * 100);
    end
    return potency;
end

local function widenedCompassCheck(player)
    if (player:hasStatusEffect(EFFECT_WIDENED_COMPASS)) then
        player:setMod(MOD_AURA_SIZE, GEOMANCER.WIDENED_AURA_SIZE);
    else
        player:setMod(MOD_AURA_SIZE, 0);
    end
end

-- tick = 3 s; power = visual id, subid = granted effect, subpower = potency, tier = 0 allies / 1 enemies
function GEOMANCER.addAura(target, duration, visual, effect, potency, targetType)
    target:addStatusEffect(EFFECT_COLURE_ACTIVE, visual, 3, duration, effect, potency, targetType);
end

function GEOMANCER.indiCastingCheck(caster, target, spell)
    if (caster:getID() ~= target:getID() and not caster:hasStatusEffect(EFFECT_ENTRUST)) then
        return GEOMANCER.MSG_UNABLE_TO_CAST;
    end
    return 0;
end

function GEOMANCER.geoCastingCheck(caster, target, spell)
    if (caster:getPet() ~= nil) then
        return GEOMANCER.MSG_UNABLE_TO_CAST;
    end
    if (caster:getMainJob() ~= JOBS.GEO) then
        return GEOMANCER.MSG_CANNOT_CAST;
    end
    return 0;
end

function GEOMANCER.doIndi(caster, target, spell)
    local data    = GEOMANCER.spells[spell:getID() - 767];
    local effect  = data[2];
    local ttype   = data[3];
    local visual  = visualElement[data[4]] + (ttype == 1 and 8 or 0);
    local potency = GEOMANCER.getPotency(caster, effect);
    local dur     = GEOMANCER.INDI_BASE_DURATION + caster:getMod(MOD_INDI_DURATION);

    target:setLocalVar("INDI_POTENCY", potency);
    if (target:hasStatusEffect(EFFECT_BOLSTER)) then
        potency = potency * 2;
    end
    widenedCompassCheck(caster);
    GEOMANCER.addAura(target, dur, visual, effect, potency, ttype);
    if (caster:hasStatusEffect(EFFECT_ENTRUST)) then
        caster:delStatusEffectSilent(EFFECT_ENTRUST);
    end
    return effect;
end

function GEOMANCER.doGeo(caster, target, spell)
    local data    = GEOMANCER.spells[spell:getID() - 797];
    local effect  = data[2];
    local ttype   = data[3];
    local visual  = visualElement[data[4]] + (ttype == 1 and 8 or 0);
    local potency = GEOMANCER.getPotency(caster, effect);
    local final   = potency;

    caster:spawnPet(GEOMANCER.LUOPAN_PETID);
    local luopan = caster:getPet();
    if (luopan == nil) then
        return effect;
    end

    -- the pet spawns on the master; move it onto the cast target
    local pos = target:getPos();
    luopan:setPos(pos.x, pos.y, pos.z, pos.rot);

    luopan:setLocalVar("GEO_POTENCY", potency);
    if (caster:hasStatusEffect(EFFECT_BLAZE_OF_GLORY)) then
        final = potency * 1.5;
    end
    if (caster:hasStatusEffect(EFFECT_BOLSTER)) then
        final = potency * 2;
    end
    widenedCompassCheck(caster);

    luopan:setModelId(luopanModel[data[5]]);
    caster:setLocalVar("MP_COST", spell:getMPCost());

    if (caster:hasStatusEffect(EFFECT_BLAZE_OF_GLORY)) then
        caster:delStatusEffect(EFFECT_BLAZE_OF_GLORY);
        luopan:setHP(luopan:getMaxHP() / 2);
    end

    -- HP decay (drained per tick by colure_active) and innate -50% damage taken
    luopan:addMod(MOD_REGEN_DOWN, math.floor(luopan:getMainLvl() / 4));
    luopan:addMod(MOD_DMG, -5000);
    GEOMANCER.addAura(luopan, GEOMANCER.LUOPAN_LIFETIME, visual, effect, final, ttype);
    return effect;
end

function GEOMANCER.bolsterOnGain(target, effect)
    local aura = target:getStatusEffect(EFFECT_COLURE_ACTIVE);
    if (aura ~= nil) then
        aura:setSubPower(target:getLocalVar("INDI_POTENCY") * 2);
    end
end

function GEOMANCER.bolsterOnLose(target, effect)
    local pet = target:getPet();
    if (pet ~= nil and pet:getPetID() == GEOMANCER.LUOPAN_PETID) then
        local geo  = pet:getLocalVar("GEO_POTENCY");
        local aura = pet:getStatusEffect(EFFECT_COLURE_ACTIVE);
        if (aura ~= nil and aura:getSubPower() == geo * 2) then
            aura:setSubPower(geo);
        end
    end
    local aura = target:getStatusEffect(EFFECT_COLURE_ACTIVE);
    local indi = target:getLocalVar("INDI_POTENCY");
    if (aura ~= nil and aura:getSubPower() == indi * 2) then
        aura:setSubPower(indi);
    end
end
