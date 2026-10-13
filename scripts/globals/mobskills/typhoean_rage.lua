---------------------------------------------
-- Typhoean Rage: AoE, amnesia + encumbrance + muddle [W]; Aello uses it below 75% HP [forum #1140]
-- Aello (Voidwatch) skill. [C] anim id/usage from Wiggo Aello capture; effects/damage [W]/[D] flagged.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    if (mob:getName() == "Aello") then return (mob:getHPP() < 75) and 0 or 1; end
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*3,ELE_WIND,1,TP_NO_EFFECT); -- [D]
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_WIND,MOBPARAM_IGNORE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_AMNESIA, 1, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_MUDDLE, 1, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 60); -- cosmetic: engine does not lock slots
    target:delHP(dmg);
    return dmg;
end;
