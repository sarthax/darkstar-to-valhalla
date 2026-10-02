-----------------------------------------
-- ID: 5434
-- Item: bottle_of_fanatics_drink
-- Item Effect: Physical Shield (nullifies physical damage, also some magical TP moves), 60s --
-- confirmed via real ffxiclopedia excerpt supplied 2026-09-14 ("nullifies all physical damage...
-- Medicine Effects: (1 second, 1 minute)... Will overwrite and is overwritten by the effect of
-- Fool's Drink"). No Topaz source exists for this item (confirmed absent by direct file check);
-- built using old-dsp-reference's own real EFFECT_PHYSICAL_SHIELD (status.lua) -- confirmed
-- present, same family as EFFECT_MAGIC_SHIELD used by this drink's sibling bottle_of_fools_drink.lua.
-----------------------------------------
require("scripts/globals/status");
-----------------------------------------
function onItemCheck(target)
    return 0;
end;

function onItemUse(target)
    local duration = 60;

    target:addStatusEffectEx(EFFECT_PHYSICAL_SHIELD, EFFECT_PHYSICAL_SHIELD, 0, 0, duration);
end;
