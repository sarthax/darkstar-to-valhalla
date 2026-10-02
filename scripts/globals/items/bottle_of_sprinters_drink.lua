-----------------------------------------
-- ID: 5397
-- Item: bottle_of_sprinters_drink
-- Item Effect: Grants Flee (temporary movement speed boost), 60s -- confirmed via BG Wiki
-- ("This medicine temporarily boosts movement speed"). Ported from Topaz's own working
-- scripts/globals/items/bottle_of_sprinters_drink.lua, converted to old-dsp-reference's
-- bare-EFFECT_*-global convention.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 7500;
    local duration = 60;

    target:addStatusEffectEx(EFFECT_FLEE, EFFECT_FLEE, power, 0, duration);
end;
