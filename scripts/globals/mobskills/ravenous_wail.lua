---------------------------------------------
-- Ravenous Wail (Celaeno): AoE HP+MP drain-style damage, Terror/Silence [W]. [D] numbers, no capture.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*3,ELE_WIND,1,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_WIND,MOBPARAM_IGNORE_SHADOWS);
    target:delMP(math.floor(dmg / 4));
    MobStatusEffectMove(mob, target, EFFECT_SILENCE, 1, 0, 30);
    MobStatusEffectMove(mob, target, EFFECT_TERROR, 1, 0, 6);
    target:delHP(dmg);
    return dmg;
end;
