-----------------------------------
-- EFFECT_COLURE_ACTIVE (slice run-geo-jobs)
-- Owns an Indi/Geo aura. The area tick lives in C++ (CStatusEffectContainer::HandleAura).
-- power = visual effect id, subid = granted effect, subpower = its potency, tier = 0 allies / 1 enemies
-----------------------------------

require("scripts/globals/status");

function onEffectGain(target,effect)
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
end;
