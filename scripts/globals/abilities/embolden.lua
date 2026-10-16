-----------------------------------
-- Ability: Embolden (slice run-geo-jobs)
-- Next white enhancing spell cast on the target gets x1.5 power / x0.5 duration.
-- The scaling is done in C++ (CBattleEntity::OnCastFinished spell path), see battleentity.cpp.
-----------------------------------

require("scripts/globals/status");

function onAbilityCheck(player,target,ability)
    return 0,0;
end;

function onUseAbility(player,target,ability)
    target:addStatusEffect(EFFECT_EMBOLDEN, 1, 0, 60);
    return EFFECT_EMBOLDEN;
end;
