-----------------------------------
-- EFFECT: bolstered (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onEffectGain(target,effect)
    GEOMANCER.bolsterOnGain(target, effect);
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
    GEOMANCER.bolsterOnLose(target, effect);
end;
