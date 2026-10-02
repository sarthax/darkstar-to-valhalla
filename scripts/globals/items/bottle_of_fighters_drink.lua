-----------------------------------------
-- ID: 5386
-- Item: bottle_of_fighters_drink
-- Item Effect: Accuracy +100, 90s -- confirmed via BG Wiki ("Increases Accuracy") and ported from
-- Topaz's own working scripts/globals/items/bottle_of_fighters_drink.lua, converted to
-- old-dsp-reference's bare-EFFECT_*-global convention.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 100;
    local duration = 90;

    target:addStatusEffectEx(EFFECT_ACCURACY_BOOST, EFFECT_ACCURACY_BOOST, power, 0, duration);
end;
