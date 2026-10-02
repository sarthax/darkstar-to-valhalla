-----------------------------------------
-- ID: 5388
-- Item: bottle_of_assassins_drink
-- Item Effect: Magic Accuracy +25, 90s -- confirmed via BG Wiki ("Increases Magic Accuracy").
-- Ported from Topaz's own working scripts/globals/items/bottle_of_assassins_drink.lua, which uses
-- INTENSION (no plain generic "Magic Accuracy Boost" effect exists in this family of codebases) --
-- converted to old-dsp-reference's bare-EFFECT_*-global convention.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 25;
    local duration = 90;

    target:addStatusEffectEx(EFFECT_INTENSION, EFFECT_INTENSION, power, 0, duration);
end;
