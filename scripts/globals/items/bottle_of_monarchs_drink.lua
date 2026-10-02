-----------------------------------------
-- ID: 5393
-- Item: bottle_of_monarchs_drink
-- Item Effect: Regain (TP gradually restored), 180s -- confirmed via BG Wiki ("Effect of Regain
-- - TP gradually restored"). Ported from Topaz's own working
-- scripts/globals/items/bottle_of_monarchs_drink.lua, converted to old-dsp-reference's
-- bare-EFFECT_*-global convention.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 3;
    local duration = 180;

    target:addStatusEffectEx(EFFECT_REGAIN, EFFECT_REGAIN, power, 0, duration);
end;
