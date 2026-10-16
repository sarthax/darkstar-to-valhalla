-----------------------------------
-- Rune Fencer helpers (slice run-geo-jobs)
-- Ported from LSB job_utils/rune_fencer.lua; xi.* namespace stripped.
-- Job points and merits are not wired in this tree (treated as 0).
-----------------------------------

require("scripts/globals/status");

RUNEFENCER = {};

-- resist mod granted by each rune (LSB MEVA -> DSP *RES; scale unverified)
RUNEFENCER.runeResistMod =
{
    [EFFECT_IGNIS]    = MOD_ICERES,
    [EFFECT_GELUS]    = MOD_WINDRES,
    [EFFECT_FLABRA]   = MOD_EARTHRES,
    [EFFECT_TELLUS]   = MOD_THUNDERRES,
    [EFFECT_SULPOR]   = MOD_WATERRES,
    [EFFECT_UNDA]     = MOD_FIRERES,
    [EFFECT_LUX]      = MOD_DARKRES,
    [EFFECT_TENEBRAE] = MOD_LIGHTRES,
};

function RUNEFENCER.getRUNLevel(player)
    if (player:getMainJob() == JOBS.RUN) then
        return player:getMainLvl();
    end
    return player:getSubLvl();
end

function RUNEFENCER.enforceRuneCounts(target)
    local runLevel = RUNEFENCER.getRUNLevel(target);
    local maxRunes = 1;
    if (runLevel >= 65) then
        maxRunes = 3;
    elseif (runLevel >= 35) then
        maxRunes = 2;
    end
    if (target:getActiveRuneCount() >= maxRunes) then
        target:removeOldestRune(); -- delete the rune with the least duration
    end
end

function RUNEFENCER.useRuneEnchantment(player, target, ability, effect)
    RUNEFENCER.enforceRuneCounts(target);
    local power = math.floor((49 * RUNEFENCER.getRUNLevel(target) / 99) + 5.5); -- merit/job point bonus TODO
    target:addStatusEffect(effect, power, 0, 300);
end

function RUNEFENCER.onRuneGain(target, effect)
    target:addMod(RUNEFENCER.runeResistMod[effect:getType()], effect:getPower());
end

function RUNEFENCER.onRuneLose(target, effect)
    target:delMod(RUNEFENCER.runeResistMod[effect:getType()], effect:getPower());
end

function RUNEFENCER.checkHaveRunes(player)
    if (player:getActiveRuneCount() > 0) then
        return 0, 0;
    end
    return 660, 0; -- REQUIRE_RUNE: message id UNVERIFIED against client
end

function RUNEFENCER.useSwordplay(player, target, ability)
    local power = 3;
    power = power + power * player:getMod(MOD_SWORDPLAY);
    local subPower = 0; -- Sleight of Sword merit TODO
    player:addStatusEffect(EFFECT_SWORDPLAY, power, 3, 120, 0, subPower);
    return EFFECT_SWORDPLAY;
end

function RUNEFENCER.onSwordplayGain(target, effect)
    local power = effect:getPower();
    local subPower = effect:getSubPower();
    if (power > 0) then
        target:addMod(MOD_ACC, power);
        target:addMod(MOD_EVA, power);
    end
    if (subPower > 0) then
        target:addMod(MOD_SUBTLE_BLOW, subPower);
    end
end

function RUNEFENCER.onSwordplayTick(target, effect)
    local power = effect:getPower();
    local tickPower = 3;
    local maxPower = 60;
    if (power < maxPower) then
        if (power + tickPower > maxPower) then
            tickPower = maxPower - power;
        end
        if (tickPower > 0) then
            target:addMod(MOD_ACC, tickPower);
            target:addMod(MOD_EVA, tickPower);
        end
        effect:setPower(math.min(power + tickPower, maxPower));
    end
end

function RUNEFENCER.onSwordplayLose(target, effect)
    local power = effect:getPower();
    local subPower = effect:getSubPower();
    target:delMod(MOD_ACC, power);
    target:delMod(MOD_EVA, power);
    if (subPower > 0) then
        target:delMod(MOD_SUBTLE_BLOW, subPower);
    end
end

-----------------------------------
-- Vallation / Valiance (slice run-geo-jobs)
-- LSB applies *_SDT (-15% damage per rune element). DSP has no SDT mods, so the
-- ward grants *RES (magic-evasion points). RES_PER_PERCENT is the tuning knob:
-- ~2 evasion points per 1% LSB reduction (see docs/slices/run-geo-jobs resist_curves.py).
-----------------------------------
RUNEFENCER.RES_PER_PERCENT = 2;

-- ward resist element: opposing element of the rune (matches LSB getVallationValianceSDTType)
RUNEFENCER.wardResistMod =
{
    [EFFECT_IGNIS]    = MOD_ICERES,
    [EFFECT_GELUS]    = MOD_WINDRES,
    [EFFECT_FLABRA]   = MOD_EARTHRES,
    [EFFECT_TELLUS]   = MOD_THUNDERRES,
    [EFFECT_SULPOR]   = MOD_WATERRES,
    [EFFECT_UNDA]     = MOD_FIRERES,
    [EFFECT_LUX]      = MOD_DARKRES,
    [EFFECT_TENEBRAE] = MOD_LIGHTRES,
};

-- pack up to 3 rune effect ids as (id - EFFECT_IGNIS + 1) nibbles into subpower
local function packRunes(runes)
    local packed = 0;
    for i, rune in ipairs(runes) do
        packed = packed + (rune - EFFECT_IGNIS + 1) * (16 ^ (i - 1));
    end
    return packed;
end

local function forEachPackedRune(subpower, fn)
    local v = subpower;
    while (v > 0) do
        local nib = v % 16;
        if (nib > 0) then
            fn(EFFECT_IGNIS + nib - 1);
        end
        v = math.floor(v / 16);
    end
end

function RUNEFENCER.onWardGain(target, effect)
    local power = effect:getPower() * RUNEFENCER.RES_PER_PERCENT;
    forEachPackedRune(effect:getSubPower(), function(rune)
        target:addMod(RUNEFENCER.wardResistMod[rune], power);
    end);
end

function RUNEFENCER.onWardLose(target, effect)
    local power = effect:getPower() * RUNEFENCER.RES_PER_PERCENT;
    forEachPackedRune(effect:getSubPower(), function(rune)
        target:delMod(RUNEFENCER.wardResistMod[rune], power);
    end);
end

local function applyWard(target, effectId, power, duration, runes)
    target:delStatusEffectSilent(EFFECT_VALIANCE);
    if (effectId == EFFECT_VALIANCE) then
        target:delStatusEffectSilent(EFFECT_VALLATION);
    end
    target:addStatusEffect(effectId, power, 0, duration, 0, packRunes(runes));
end

-- returns true if the ward was applied to the caster/target
function RUNEFENCER.useVallationValiance(player, target, ability, isValiance)
    local runes = player:getAllRuneEffects();
    if (#runes == 0) then
        return nil;
    end
    local power = 15; -- percent per rune element (merits not wired)
    if (isValiance) then
        for _, member in pairs(player:getParty()) do
            if (not member:hasStatusEffect(EFFECT_VALLATION)) then
                applyWard(member, EFFECT_VALIANCE, power, 180, runes);
            end
        end
    else
        target:delStatusEffectSilent(EFFECT_VALIANCE);
        target:addStatusEffect(EFFECT_VALLATION, power, 0, 120, 0, packRunes(runes));
    end
    return isValiance and EFFECT_VALIANCE or EFFECT_VALLATION;
end

-----------------------------------
-- Pflug (slice run-geo-jobs): status resist per held rune; merits not wired
-----------------------------------
RUNEFENCER.pflugResistMods =
{
    [EFFECT_IGNIS]    = { MOD_PARALYZERES, MOD_BINDRES },
    [EFFECT_GELUS]    = { MOD_SILENCERES, MOD_GRAVITYRES },
    [EFFECT_FLABRA]   = { MOD_PETRIFYRES, MOD_SLOWRES },
    [EFFECT_TELLUS]   = { MOD_STUNRES },
    [EFFECT_SULPOR]   = { MOD_POISONRES },
    [EFFECT_UNDA]     = { MOD_AMNESIARES, MOD_VIRUSRES },
    [EFFECT_LUX]      = { MOD_SLEEPRES, MOD_BLINDRES, MOD_CURSERES },
    [EFFECT_TENEBRAE] = { MOD_CHARMRES },
};

-- runes are packed into subpower (merit bonus is 0 in this tree)
function RUNEFENCER.usePflug(player, target, ability)
    local runes = player:getAllRuneEffects();
    local power = 10;
    if (player:getMainJob() == JOBS.RUN) then
        power = 15;
    end
    player:addStatusEffect(EFFECT_PFLUG, power, 0, 120, 0, packRunes(runes));
    return EFFECT_PFLUG;
end

function RUNEFENCER.onPflugGain(target, effect)
    forEachPackedRune(effect:getSubPower(), function(rune)
        for _, m in ipairs(RUNEFENCER.pflugResistMods[rune]) do
            target:addMod(m, effect:getPower());
        end
    end);
end

function RUNEFENCER.onPflugLose(target, effect)
    forEachPackedRune(effect:getSubPower(), function(rune)
        for _, m in ipairs(RUNEFENCER.pflugResistMods[rune]) do
            target:delMod(m, effect:getPower());
        end
    end);
end

-----------------------------------
-- Gambit: enemy loses -10% (as RES points) in each held rune's element
-----------------------------------
RUNEFENCER.gambitResistMod =
{
    [EFFECT_IGNIS]    = MOD_FIRERES,
    [EFFECT_GELUS]    = MOD_ICERES,
    [EFFECT_FLABRA]   = MOD_WINDRES,
    [EFFECT_TELLUS]   = MOD_EARTHRES,
    [EFFECT_SULPOR]   = MOD_THUNDERRES,
    [EFFECT_UNDA]     = MOD_WATERRES,
    [EFFECT_LUX]      = MOD_LIGHTRES,
    [EFFECT_TENEBRAE] = MOD_DARKRES,
};

function RUNEFENCER.useGambit(player, target, ability)
    local runes = player:getAllRuneEffects();
    if (#runes == 0) then
        return nil;
    end
    target:delStatusEffectSilent(EFFECT_GAMBIT);
    target:addStatusEffect(EFFECT_GAMBIT, 10, 0, 60, 0, packRunes(runes));
    player:removeAllRunes();
    return EFFECT_GAMBIT;
end

function RUNEFENCER.onGambitGain(target, effect)
    local power = effect:getPower() * RUNEFENCER.RES_PER_PERCENT;
    forEachPackedRune(effect:getSubPower(), function(rune)
        target:delMod(RUNEFENCER.gambitResistMod[rune], power);
    end);
end

function RUNEFENCER.onGambitLose(target, effect)
    local power = effect:getPower() * RUNEFENCER.RES_PER_PERCENT;
    forEachPackedRune(effect:getSubPower(), function(rune)
        target:addMod(RUNEFENCER.gambitResistMod[rune], power);
    end);
end

-----------------------------------
-- One for All: party-wide flat magic damage cut = 20% max HP, 30s (job points not wired)
-- Consumed in magic.lua finalMagicAdjustments.
-----------------------------------
function RUNEFENCER.useOneForAll(player, target, ability)
    if (player:getID() ~= target:getID()) then
        return nil;
    end
    local power = math.floor(player:getMaxHP() * 0.2);
    for _, member in pairs(player:getParty()) do
        member:delStatusEffectSilent(EFFECT_ONE_FOR_ALL);
        member:addStatusEffect(EFFECT_ONE_FOR_ALL, power, 0, 30);
    end
    return EFFECT_ONE_FOR_ALL;
end

-----------------------------------
-- Swipe / Lunge (slice run-geo-jobs)
-- LSB computes a long multiplier chain; here DSP's addBonusesAbility (affinity,
-- weather/day, MDT), applyResistanceAbility and adjustForTarget stand in for it.
-- Not ported: magic burst, Rune Enhance merit macc, Swipe gear/jp bonus,
-- Phalanx/Stoneskin interplay beyond what takeAbilityDamage does, absorb healing.
-----------------------------------
RUNEFENCER.runeElement =
{
    [EFFECT_IGNIS]    = ELE_FIRE,
    [EFFECT_GELUS]    = ELE_ICE,
    [EFFECT_FLABRA]   = ELE_WIND,
    [EFFECT_TELLUS]   = ELE_EARTH,
    [EFFECT_SULPOR]   = ELE_THUNDER,
    [EFFECT_UNDA]     = ELE_WATER,
    [EFFECT_LUX]      = ELE_LIGHT,
    [EFFECT_TENEBRAE] = ELE_DARK,
};

local function countRune(runes, id)
    local n = 0;
    for _, r in ipairs(runes) do
        if (r == id) then n = n + 1; end
    end
    return n;
end

function RUNEFENCER.useSwipeLunge(player, target, ability, action, isLunge)
    local runes = player:getAllRuneEffects();
    if (#runes == 0) then
        return 0;
    end
    local highest = player:getHighestRuneEffect();
    local highestCount = countRune(runes, highest);
    local numHits = 1;
    if (isLunge) then
        numHits = #runes;
    end
    local weaponSkill = player:getWeaponSkillType(SLOT_MAIN);
    local skillMod = player:getSkillLevel(weaponSkill);

    target:updateClaim(player);
    local total, used = 0, 0;
    local shadowsAbsorbed = 0;

    for i = 1, numHits do
        local rune = player:getNewestRuneEffect();
        local ele = RUNEFENCER.runeElement[rune];
        player:removeNewestRune();
        used = used + 1;

        if (shadowAbsorb(target)) then
            shadowsAbsorbed = shadowsAbsorbed + 1;
        else
            local strength = 1;
            if (rune == highest) then
                strength = highestCount;
            end
            local dmg = math.floor(skillMod * (0.50 + 0.25 * strength));
            dmg = dmg + player:getMod(MOD_MAGIC_DAMAGE);
            dmg = addBonusesAbility(player, ele, target, dmg, {});
            dmg = dmg * applyResistanceAbility(player, target, ele, 0, 0);
            dmg = adjustForTarget(target, dmg, ele);
            if (dmg > 0) then
                total = total + dmg;
                if (target:getHP() - total <= 0) then
                    break;
                end
            end
        end
    end

    total = takeAbilityDamage(target, player, {}, true, total, SLOT_MAIN, (total > 0) and 1 or 0, 0, shadowsAbsorbed, 0, action, nil);
    return total;
end

-----------------------------------
-- Vivacious Pulse (slice run-geo-jobs)
-- Job points, potency mod and AF3 debuff-removal augment are not ported.
-----------------------------------
RUNEFENCER.runeHealStat =
{
    [EFFECT_IGNIS]  = MOD_STR,
    [EFFECT_GELUS]  = MOD_DEX,
    [EFFECT_FLABRA] = MOD_VIT,
    [EFFECT_TELLUS] = MOD_AGI,
    [EFFECT_SULPOR] = MOD_INT,
    [EFFECT_UNDA]   = MOD_MND,
    [EFFECT_LUX]    = MOD_CHR,
};

function RUNEFENCER.useVivaciousPulse(player, target, ability)
    local divine = target:getSkillLevel(SKILL_DIV);
    local heal = 10 + math.floor(divine / 2);
    local tenebrae = 0;
    for _, rune in ipairs(target:getAllRuneEffects()) do
        local stat = RUNEFENCER.runeHealStat[rune];
        if (stat ~= nil) then
            heal = heal + math.floor(target:getStat(stat) * 0.5);
        elseif (rune == EFFECT_TENEBRAE) then
            tenebrae = tenebrae + 1;
        end
    end
    if (tenebrae > 0) then
        target:addMP(math.floor(divine / 10) * (tenebrae + 1));
    end
    heal = math.min(heal, target:getMaxHP() - target:getHP());
    target:restoreHP(heal);
    return heal;
end

-----------------------------------
-- Battuta (slice run-geo-jobs)
-- Engine side: INQUARTATA adds to parry rate; PARRY_SPIKES/_DMG fire on a parry
-- (battleutils.cpp HandleParrySpikesDamage). Merits and ENHANCES_BATTUTA not wired.
-----------------------------------
RUNEFENCER.battutaSpikes =
{
    [EFFECT_IGNIS]    = SUBEFFECT_BLAZE_SPIKES,
    [EFFECT_GELUS]    = SUBEFFECT_ICE_SPIKES,
    [EFFECT_FLABRA]   = SUBEFFECT_GALE_SPIKES,
    [EFFECT_TELLUS]   = SUBEFFECT_CLOD_SPIKES,
    [EFFECT_SULPOR]   = SUBEFFECT_SHOCK_SPIKES,
    [EFFECT_UNDA]     = SUBEFFECT_DELUGE_SPIKES,
    [EFFECT_LUX]      = SUBEFFECT_REPRISAL,
    [EFFECT_TENEBRAE] = SUBEFFECT_DEATH_SPIKES,
};

function RUNEFENCER.useBattuta(player, target, ability)
    local spikesPower = 6 * target:getActiveRuneCount();
    target:addStatusEffect(EFFECT_BATTUTA, 36, 0, 90, 0, spikesPower);
    return EFFECT_BATTUTA;
end

function RUNEFENCER.onBattutaGain(target, effect)
    effect:addMod(MOD_INQUARTATA, effect:getPower());
    if (effect:getSubPower() > 0) then
        effect:addMod(MOD_PARRY_SPIKES, RUNEFENCER.battutaSpikes[target:getHighestRuneEffect()]);
        effect:addMod(MOD_PARRY_SPIKES_DMG, effect:getSubPower());
    end
end
