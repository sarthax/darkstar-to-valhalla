-----------------------------------------
-- ID: 5385
-- Item: bottle_of_barbarians_drink
-- Item Effect: Attack +50%, 60s -- confirmed via BG Wiki ("Increases Attack") and ported from
-- Topaz's own working scripts/globals/items/bottle_of_barbarians_drink.lua, converted to
-- old-dsp-reference's bare-EFFECT_*-global convention (see EFFECT_ATTACK_BOOST in status.lua).
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 50;
    local duration = 60;

    target:addStatusEffectEx(EFFECT_ATTACK_BOOST, EFFECT_ATTACK_BOOST, power, 0, duration);
end;
