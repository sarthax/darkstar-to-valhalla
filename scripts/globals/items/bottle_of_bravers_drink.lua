-----------------------------------------
-- ID: 5390
-- Item: bottle_of_bravers_drink
-- Item Effect: All base stats +15, 180s -- confirmed via BG Wiki ("+15 to all attributes").
-- Ported from Topaz's own working scripts/globals/items/bottle_of_bravers_drink.lua (uses the
-- _BOOST_II effect variants, not the plain ones), converted to old-dsp-reference's
-- bare-EFFECT_*-global convention.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 15;
    local duration = 180;

    local effects =
    {
        EFFECT_STR_BOOST_II,
        EFFECT_DEX_BOOST_II,
        EFFECT_VIT_BOOST_II,
        EFFECT_AGI_BOOST_II,
        EFFECT_INT_BOOST_II,
        EFFECT_MND_BOOST_II,
        EFFECT_CHR_BOOST_II,
    };

    for _, effect in ipairs(effects) do
        target:addStatusEffectEx(effect, effect, power, 0, duration);
    end
end;
