-----------------------------------
-- EFFECT_BATTUTA (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onEffectGain(target,effect)
    RUNEFENCER.onBattutaGain(target,effect);
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
end;
