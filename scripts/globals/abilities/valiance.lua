-----------------------------------
-- Ability: valiance (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onAbilityCheck(player,target,ability)
    return RUNEFENCER.checkHaveRunes(player);
end;

function onUseAbility(player,target,ability)
    return RUNEFENCER.useVallationValiance(player,target,ability,true);
end;
