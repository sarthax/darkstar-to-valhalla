-----------------------------------
-- Effect: Odyllic Subterfuge (slice run-geo-jobs)
-- Enemy debuff: magic accuracy and magic attack bonus down.
-- power = magic accuracy reduction, subpower = magic attack bonus reduction
-----------------------------------

function onEffectGain(target,effect)
    effect:addMod(MOD_MACC, -effect:getPower());
    effect:addMod(MOD_MATT, -effect:getSubPower());
end;

function onEffectTick(target,effect)
end;

function onEffectLose(target,effect)
end;
