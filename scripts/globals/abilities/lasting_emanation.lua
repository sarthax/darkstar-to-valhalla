-----------------------------------
-- Ability: lasting_emanation (slice run-geo-jobs)
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
    luopan:setMod(MOD_REGEN_DOWN, luopan:getMod(MOD_REGEN_DOWN) - math.floor(luopan:getMainLvl() / 14));
end;
