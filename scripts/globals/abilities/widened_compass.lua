-----------------------------------
-- Ability: widened_compass (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onAbilityCheck(player,target,ability)
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    player:addStatusEffect(EFFECT_WIDENED_COMPASS, 1, 3, 60);
end;
