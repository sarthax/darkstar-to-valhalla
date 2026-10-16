-----------------------------------
-- Ability: vallation (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onAbilityCheck(player,target,ability)
    return RUNEFENCER.checkHaveRunes(player);
end;

function onUseAbility(player,target,ability,action)
    -- test: message 668 shows a blank ability name on this client; force the stock 'uses <ability>' message
    action:messageID(target:getID(), 100);
    local r = RUNEFENCER.useVallationValiance(player,target,ability,false);
    -- test: send the 668 'receives the effect of Vallation...' line separately
    target:messageBasic(668, EFFECT_VALLATION);
    return r;
end;
