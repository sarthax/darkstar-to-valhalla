---------------------------------------------
--  Trebuchet  (Cottus, Voidwatch)
--  [C Raguza 2021.03.27] skill id 1636, anim 1132, msg 31 (actionview). [F] target-centred heavy ranged attack
--  that resets hate. Damage multiplier is [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob, target, skill, 1, 1, 3.0, TP_DMG_VARIES, 1, 2, 3);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT, MOBPARAM_1_SHADOW);
    target:delHP(dmg);
    mob:resetEnmity(target);
    return dmg;
end;
