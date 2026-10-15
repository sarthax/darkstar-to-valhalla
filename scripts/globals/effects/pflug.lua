-----------------------------------
-- EFFECT_PFLUG (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onEffectGain(target,effect)
    RUNEFENCER.onPflugGain(target,effect);
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
    RUNEFENCER.onPflugLose(target,effect);
end;
