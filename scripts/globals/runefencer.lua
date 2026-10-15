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
