-----------------------------------
-- Ability: valiance (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/runefencer");

function onAbilityCheck(player,target,ability)
    return RUNEFENCER.checkHaveRunes(player);
end;

function onUseAbility(player,target,ability,action)
    -- message 668 prints a blank ability name on this client: use the stock 'uses' message, send the 668 effect line separately
    action:messageID(target:getID(), 100);
    local r = RUNEFENCER.useVallationValiance(player,target,ability,true);
    target:messageBasic(668, EFFECT_VALIANCE);
    return r;
end;
