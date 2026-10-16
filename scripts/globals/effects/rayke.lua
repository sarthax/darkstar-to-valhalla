-----------------------------------
-- EFFECT_RAYKE (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onEffectGain(target,effect)
    RUNEFENCER.onRaykeGain(target,effect);
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
    RUNEFENCER.onRaykeLose(target,effect);
end;
