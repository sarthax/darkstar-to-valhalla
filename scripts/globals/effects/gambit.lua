-----------------------------------
-- EFFECT_GAMBIT (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onEffectGain(target,effect)
    RUNEFENCER.onGambitGain(target,effect);
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
    RUNEFENCER.onGambitLose(target,effect);
end;
