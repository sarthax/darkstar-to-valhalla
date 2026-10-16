-----------------------------------
-- Ability: full_circle (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onAbilityCheck(player,target,ability)
    if (GEOMANCER.getLuopan(player) == nil) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil) then return; end
    local hpp = luopan:getHPP();
    local mpCost = player:getLocalVar("MP_COST");
    local mult = 0.5 + player:getMod(MOD_FULL_CIRCLE) / 10;
    player:restoreMP(math.floor(mult * mpCost * hpp / 100));
    player:despawnPet();
end;
