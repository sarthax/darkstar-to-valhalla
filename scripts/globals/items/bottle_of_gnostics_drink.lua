-----------------------------------------
-- ID: 5394
-- Item: bottle_of_gnostics_drink
-- Item Effect: Pax (greatly reduced enmity generation), 60s -- confirmed via BG Wiki ("Effect of
-- Pax - Enmity generation is reduced"). Ported from Topaz's own working
-- scripts/globals/items/bottle_of_gnostics_drink.lua (power unconfirmed magnitude, matches
-- Animus Minueo's own value as a baseline), converted to old-dsp-reference's
-- bare-EFFECT_*-global convention.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = -10;
    local duration = 60;

    target:addStatusEffectEx(EFFECT_PAX, EFFECT_PAX, power, 0, duration);
end;
