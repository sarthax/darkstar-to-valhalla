-----------------------------------------
-- ID: 5387
-- Item: bottle_of_oracles_drink
-- Item Effect: Temporarily increases Magic Attack -- confirmed via BG Wiki ("Increases Magic
-- Attack"), no documented magnitude/duration anywhere. Ported from Topaz's own working
-- scripts/globals/items/bottle_of_oracles_drink.lua (which itself notes the same power/duration
-- are estimated defaults matching this drink family's other confirmed durations, not sourced
-- numbers), converted to old-dsp-reference's bare-EFFECT_*-global convention.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 100;
    local duration = 90;

    target:addStatusEffectEx(EFFECT_MAGIC_ATK_BOOST, EFFECT_MAGIC_ATK_BOOST, power, 0, duration);
end;
