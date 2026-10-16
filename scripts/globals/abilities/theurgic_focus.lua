-----------------------------------
-- Ability: theurgic_focus (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onAbilityCheck(player,target,ability)
    if (player:hasStatusEffect(EFFECT_THEURGIC_FOCUS)) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    player:addStatusEffect(EFFECT_THEURGIC_FOCUS, 1, 0, 60);
end;
