-----------------------------------
-- Ability: pflug (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onAbilityCheck(player,target,ability)
    return 0,0;
end;

function onUseAbility(player,target,ability)
    return RUNEFENCER.usePflug(player,target,ability);
end;
