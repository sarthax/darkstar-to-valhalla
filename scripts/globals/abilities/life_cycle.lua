-----------------------------------
-- Ability: life_cycle (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onAbilityCheck(player,target,ability)
    if (GEOMANCER.getLuopan(player) == nil or player:getHP() <= 2) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil) then return; end
    local amount = math.floor(0.25 * player:getHP());
    local transfer = amount;
    local bonus = player:getMod(MOD_LIFE_CYCLE_EFFECT);
    if (bonus > 0) then transfer = amount * bonus / 10; end
    luopan:restoreHP(transfer);
    player:delHP(amount);
    return transfer;
end;
