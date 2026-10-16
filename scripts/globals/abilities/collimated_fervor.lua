-----------------------------------
-- Ability: collimated_fervor (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onAbilityCheck(player,target,ability)
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    target:addStatusEffect(EFFECT_COLLIMATED_FERVOR, 1, 0, 60);
end;
