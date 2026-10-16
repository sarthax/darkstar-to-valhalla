-----------------------------------
-- Ability: blaze_of_glory (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onAbilityCheck(player,target,ability)
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    player:addStatusEffect(EFFECT_BLAZE_OF_GLORY, 1, 3, 60);
end;
