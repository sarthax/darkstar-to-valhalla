-----------------------------------
--
-- EFFECT_FOIL
-- Power = special attack evasion, decays by 3 each 3s tick (LSB foil.lua)
--
-----------------------------------

require("scripts/globals/status");

function onEffectGain(target,effect)
    target:addMod(MOD_SPECIAL_ATTACK_EVASION, effect:getPower());
end;

function onEffectTick(target,effect)
    local decay = math.min(3, effect:getPower());
    if (decay > 0) then
        effect:setPower(effect:getPower() - decay);
        target:delMod(MOD_SPECIAL_ATTACK_EVASION, decay);
    end
end;

function onEffectLose(target,effect)
    target:delMod(MOD_SPECIAL_ATTACK_EVASION, effect:getPower());
end;
