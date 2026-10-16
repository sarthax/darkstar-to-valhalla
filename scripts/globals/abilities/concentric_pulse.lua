-----------------------------------
-- Ability: Concentric Pulse (slice run-geo-jobs)
-- Luopan detonates on the target for damage equal to its current HP, then vanishes.
-- Implemented as a player ability (DSP has no pet_skills table).
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

GEOMANCER.CONCENTRIC_RANGE = 10; -- yalms, luopan to target

function onAbilityCheck(player,target,ability)
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    if (luopan:checkDistance(target) > GEOMANCER.CONCENTRIC_RANGE) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    ability:setMsg(110);
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil) then return 0; end
    local dmg = luopan:getHP();
    target:delHP(dmg);
    player:despawnPet();
    return dmg;
end;
