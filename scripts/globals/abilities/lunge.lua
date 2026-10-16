-----------------------------------
-- Ability: lunge (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/ability");
require("scripts/globals/magic");
require("scripts/globals/weaponskills");
require("scripts/globals/runefencer");

function onAbilityCheck(player,target,ability)
    return RUNEFENCER.checkHaveRunes(player);
end;

function onUseAbility(player,target,ability,action)
    return RUNEFENCER.useSwipeLunge(player,target,ability,action,true);
end;
