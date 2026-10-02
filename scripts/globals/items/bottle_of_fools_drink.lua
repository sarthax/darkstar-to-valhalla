-----------------------------------------
-- ID: 5435
-- Item: bottle_of_fools_drink
-- Item Effect: Magic Shield (nullifies magical damage), 60s -- confirmed via real BG Wiki excerpt
-- supplied 2026-09-14 ("Fool's Drink -> Provides invulnerability to magical attacks"), same real
-- mechanic family as this drink's sibling bottle_of_fanatics_drink.lua (Physical Shield -- real
-- ffxiclopedia source notes the two overwrite each other, matching this pair's shared duration).
-- No Topaz source exists for this item (confirmed absent by direct file check); built using
-- old-dsp-reference's own real EFFECT_MAGIC_SHIELD (status.lua) -- confirmed present.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local duration = 60;

    target:addStatusEffectEx(EFFECT_MAGIC_SHIELD, EFFECT_MAGIC_SHIELD, 0, 0, duration);
end;
