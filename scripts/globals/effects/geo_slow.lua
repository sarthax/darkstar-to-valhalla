-----------------------------------
-- EFFECT_GEO_SLOW (slice run-geo-jobs) - granted by an Indi/Geo aura
-----------------------------------
-- power is x100 of the percent (LSB convention); HASTE_MAGIC is /1024 in DSP

require("scripts/globals/status");

function onEffectGain(target,effect)
    effect:addMod(MOD_HASTE_MAGIC, -math.floor(effect:getPower() * 1024 / 10000));
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
end;
