-----------------------------------
-- EFFECT_SWORDPLAY (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onEffectGain(target,effect)
    RUNEFENCER.onSwordplayGain(target,effect);
end;

function onEffectTick(target,effect)
    RUNEFENCER.onSwordplayTick(target,effect);
end;

function onEffectLose(target,effect)
    RUNEFENCER.onSwordplayLose(target,effect);
end;
