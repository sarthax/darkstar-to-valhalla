-----------------------------------------
-- ID: 5391
-- Item: bottle_of_soldiers_drink
-- Item Effect: BG Wiki confirms "Greatly increases damage dealt" -- the real "wears off after
-- first hit, overwrites Barbarian's Drink" behavior has no confirmed real implementation anywhere
-- (absent from Topaz's own scripts/globals/items/ too), so per this project's precedent (see
-- Topaz's own header comment on this same file) it's built as a plain timed ATTACK_BOOST, same as
-- Barbarian's Drink, at a shorter 15s duration. Converted to old-dsp-reference's
-- bare-EFFECT_*-global convention.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 50;
    local duration = 15;

    target:addStatusEffectEx(EFFECT_ATTACK_BOOST, EFFECT_ATTACK_BOOST, power, 0, duration);
end;
