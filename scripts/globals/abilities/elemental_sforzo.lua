-----------------------------------
-- Ability: Elemental Sforzo (slice run-geo-jobs)
-- Immunity to magic damage for 30 seconds.
-----------------------------------

require("scripts/globals/status");

function onAbilityCheck(player,target,ability)
    return 0,0;
end;

function onUseAbility(player,target,ability)
    player:addStatusEffect(EFFECT_ELEMENTAL_SFORZO,1,0,30);
    return EFFECT_ELEMENTAL_SFORZO;
end;
