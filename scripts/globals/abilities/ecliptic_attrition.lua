-----------------------------------
-- Ability: ecliptic_attrition (slice run-geo-jobs)
-----------------------------------

require("scripts/globals/status");
require("scripts/globals/geomancer");

function onAbilityCheck(player,target,ability)
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil or luopan:getLocalVar("eclipticAttrition") ~= 0) then
        return GEOMANCER.MSG_UNABLE_JA, 0;
    end
    return 0, 0;
end;

function onUseAbility(player,target,ability)
    local luopan = GEOMANCER.getLuopan(player);
    if (luopan == nil) then return; end
    luopan:setMod(MOD_REGEN_DOWN, luopan:getMod(MOD_REGEN_DOWN) + math.floor(luopan:getMainLvl() / 16));
    if (not player:hasStatusEffect(EFFECT_BOLSTER)) then
        local aura = luopan:getStatusEffect(EFFECT_COLURE_ACTIVE);
        if (aura ~= nil) then
            aura:setSubPower(math.floor(1.25 * aura:getSubPower()));
            luopan:setLocalVar("eclipticAttrition", 1);
        end
    end
end;
