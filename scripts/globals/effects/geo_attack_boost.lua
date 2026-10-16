-----------------------------------
-- EFFECT_GEO_ATTACK_BOOST (slice run-geo-jobs) - granted by an Indi/Geo aura
-----------------------------------

require("scripts/globals/status");

function onEffectGain(target,effect)
    effect:addMod(MOD_ATTP, effect:getPower());
    effect:addMod(MOD_RATTP, effect:getPower());
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
end;
