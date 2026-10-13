---------------------------------------------
--  Clobber  (Stachysaurus, Voidwatch)
--  [C] skill id 2100; [F] "Crippling Slam": severe physical damage + Paralyze (mapping to Clobber unconfirmed). Values [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob, target, skill, 1, 1, 3.5, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT, info.hitslanded);
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_PARALYSIS, 25, 0, 60);
    target:delHP(dmg);
    return dmg;
end;
