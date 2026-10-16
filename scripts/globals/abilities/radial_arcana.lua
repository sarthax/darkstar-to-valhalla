-----------------------------------
-- Ability: Radial Arcana (slice run-geo-jobs)
-- Luopan vanishes and restores MP to party members near it: 3 x luopan level.
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

GEOMANCER.RADIAL_PER_LEVEL = 3;
GEOMANCER.AURA_BASE_RANGE  = GEOMANCER.AURA_BASE_RANGE or 6; -- yalms

function onAbilityCheck(player,target,ability)
    if (GEOMANCER.getLuopan(player) == nil) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil) then return 0; end
    local amount = GEOMANCER.RADIAL_PER_LEVEL * luopan:getMainLvl();
    for _, member in ipairs(player:getParty()) do
        if (member:getHP() > 0 and luopan:checkDistance(member) <= GEOMANCER.AURA_BASE_RANGE) then
            member:addMP(math.min(amount, member:getMaxMP()));
        end
    end
    player:despawnPet();
    return amount;
end;
