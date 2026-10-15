-----------------------------------
-- EFFECT_TENEBRAE (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onEffectGain(target,effect)
    RUNEFENCER.onRuneGain(target,effect);
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
    RUNEFENCER.onRuneLose(target,effect);
end;
