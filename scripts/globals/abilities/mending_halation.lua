-----------------------------------
-- Ability: Mending Halation (slice run-geo-jobs)
-- Luopan vanishes and heals party members near it for 7 x luopan level.
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

GEOMANCER.HALATION_PER_LEVEL = 7;
GEOMANCER.AURA_BASE_RANGE    = 6; -- yalms

function onAbilityCheck(player,target,ability)
    if (GEOMANCER.getLuopan(player) == nil) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    ability:setMsg(102);
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil) then return 0; end
    local amount = GEOMANCER.HALATION_PER_LEVEL * luopan:getMainLvl();
    local total = 0;
    for _, member in ipairs(player:getParty()) do
        if (member:getHP() > 0 and luopan:checkDistance(member) <= GEOMANCER.AURA_BASE_RANGE) then
            member:wakeUp();
            member:addHP(math.min(amount, member:getMaxHP()));
            total = total + amount;
        end
    end
    player:despawnPet();
    return amount;
end;
