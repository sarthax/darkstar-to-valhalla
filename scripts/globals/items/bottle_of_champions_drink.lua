-----------------------------------------
-- ID: 5392
-- Item: bottle_of_champions_drink
-- Item Effect: Magic Haste 18% + Critical Hit Rate +5%, 60s -- confirmed via BG Wiki ("Increases
-- critical hit rate"; the magic-haste half is Topaz's own already-working value). Ported from
-- Topaz's own working scripts/globals/items/bottle_of_champions_drink.lua (uses POTENCY with a
-- subpower, not a plain generic buff), converted to old-dsp-reference's bare-EFFECT_*-global
-- convention.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 1800; -- magic haste
    local subPower = 5;    -- crit rate
    local duration = 60;

    target:addStatusEffectEx(EFFECT_POTENCY, EFFECT_POTENCY, power, 0, duration, 0, subPower);
end;
