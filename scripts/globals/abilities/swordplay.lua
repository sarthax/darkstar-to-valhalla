-----------------------------------
-- Ability: Swordplay (slice run-geo-jobs)
-- Increases accuracy and evasion until you take severe damage.
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onAbilityCheck(player,target,ability)
    return 0,0;
end;

function onUseAbility(player,target,ability)
    return RUNEFENCER.useSwordplay(player,target,ability);
end;
