-----------------------------------
-- EFFECT_GEO_ACCURACY_DOWN (slice run-geo-jobs) - granted by an Indi/Geo aura
-----------------------------------

require("scripts/globals/status");

function onEffectGain(target,effect)
    effect:addMod(MOD_ACC, -effect:getPower());
    effect:addMod(MOD_RACC, -effect:getPower());
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
end;
