-----------------------------------------
-- ID: 19132
-- Item: Twilight Knife
-- Additional Effect: HP, MP or TP Drain
-- Source: BG Wiki -- "5% activation. Activation distribution for HP/MP/TP is 45:45:10.
--         For a max of 45 HP, 45 MP or 10 TP."
-- ASSUMPTION (not stated by any source): the HP/MP amount is uniform 1..45. Verify against retail.
-----------------------------------------
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");

-----------------------------------
-- onAdditionalEffect Action
-----------------------------------

function onAdditionalEffect(player,target,damage)
    if (math.random(0,99) >= 5) then
        return 0,0,0;
    end

    local roll = math.random(1,100);
    local params = {};
    params.bonusmab = 0;
    params.includemab = false;

    if (roll <= 45) then -- HP drain
        local drain = math.random(1,45);
        drain = drain * applyResistanceAddEffect(player,target,ELE_DARK,0);
        drain = adjustForTarget(target,drain,ELE_DARK);
        drain = finalMagicNonSpellAdjustments(player,target,ELE_DARK,drain);
        drain = math.min(drain, target:getHP());
        target:addHP(-drain);
        return SUBEFFECT_HP_DRAIN, msgBasic.ADD_EFFECT_HP_DRAIN, player:addHP(drain);
    elseif (roll <= 90) then -- MP drain
        local drain = math.random(1,45);
        drain = drain * applyResistanceAddEffect(player,target,ELE_DARK,0);
        drain = adjustForTarget(target,drain,ELE_DARK);
        drain = finalMagicNonSpellAdjustments(player,target,ELE_DARK,drain);
        drain = math.min(drain, target:getMP());
        target:addMP(-drain);
        return SUBEFFECT_MP_DRAIN, msgBasic.ADD_EFFECT_MP_DRAIN, player:addMP(drain);
    else -- TP drain
        local drain = math.min(10, target:getTP());
        target:addTP(-drain);
        player:addTP(drain);
        return SUBEFFECT_TP_DRAIN, msgBasic.ADD_EFFECT_TP_DRAIN, drain;
    end
end;
