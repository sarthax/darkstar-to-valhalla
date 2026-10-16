-----------------------------------
-- Ability: entrust (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onAbilityCheck(player,target,ability)
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    player:addStatusEffect(EFFECT_ENTRUST, 1, 0, 60);
end;
