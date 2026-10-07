---------------------------------------------
--  Rhinowrecker  (Lancing Lamorak, Voidwatch)
--  [F] high conal damage and knockback; gains shadows after TP moves [F]. Damage/shadow count [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

---------------------------------------------
function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob, target, skill, 1, 1, 3.0, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT, info.hitslanded);
    target:delHP(dmg);
    mob:delStatusEffect(EFFECT_COPY_IMAGE);
    mob:addStatusEffect(EFFECT_COPY_IMAGE, 3, 0, 300);
    return dmg;
end;
