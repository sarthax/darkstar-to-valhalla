---------------------------------------------
-- Shrieking Gale: AoE dispel (2-4 buffs [W]), hate reset, resummons dead handmaidens [forum #1140]
-- Aello (Voidwatch) skill. [C] anim id/usage from Wiggo Aello capture; effects/damage [W]/[D] flagged.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");
require("scripts/globals/voidwatch");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local total = 0;
    for i = 1, math.random(2, 4) do
        if (target:dispelStatusEffect() ~= EFFECT_NONE) then total = total + 1; end
    end
    mob:resetEnmity(target);
    if (mob:getName() == "Aello") then vwAelloResummon(mob, target); end
    if (total == 0) then
        skill:setMsg(msgBasic.NO_EFFECT);
    else
        skill:setMsg(msgBasic.DISAPPEAR_NUM);
    end
    return total;
end;
