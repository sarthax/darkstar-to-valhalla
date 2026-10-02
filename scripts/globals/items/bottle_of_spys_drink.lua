-----------------------------------------
-- ID: 5389
-- Item: bottle_of_spys_drink
-- Item Effect: Grants the Haste status effect, 90s -- confirmed via BG Wiki ("Gives Haste
-- effect"). Ported from Topaz's own working scripts/globals/items/bottle_of_spys_drink.lua --
-- uses the real HASTE effect (same id as the spell Haste, explaining the real "won't stack with
-- Haste" behavior), guards against overwriting an existing Haste, converted to
-- old-dsp-reference's bare-EFFECT_*/msgBasic-global convention.
-----------------------------------------
require("scripts/globals/status");
require("scripts/globals/msg");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local power    = 3000;
    local duration = 90;

    if (not target:hasStatusEffect(EFFECT_HASTE)) then
        target:addStatusEffectEx(EFFECT_HASTE, EFFECT_HASTE, power, 0, duration);
    else
        target:messageBasic(msgBasic.NO_EFFECT);
    end
end;
