-----------------------------------
-- EFFECT_GEO_MAGIC_ATK_DOWN (slice run-geo-jobs) - granted by an Indi/Geo aura
-----------------------------------

require("scripts/globals/status");

function onEffectGain(target,effect)
    effect:addMod(MOD_MATT, -effect:getPower());
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
end;
