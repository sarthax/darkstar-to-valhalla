-----------------------------------
-- EFFECT_ELEMENTAL_SFORZO (slice run-geo-jobs)
-- DSP's UDMGMAGIC is a percentage (battleutils.cpp ~4271), so -100 = no magic damage.
-- LSB stores -10000 (base 10000). Status resists are a TODO there as well.
-----------------------------------

require("scripts/globals/status");

function onEffectGain(target,effect)
    target:addMod(MOD_UDMGMAGIC,-100);
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
    target:delMod(MOD_UDMGMAGIC,-100);
end;
