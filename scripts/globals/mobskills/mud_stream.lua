---------------------------------------------
-- Mud Stream (Sallow Seymour): earth AoE, Magic Def Down/Slow/Bind/Rasp, hate reset [W]
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*3,ELE_EARTH,1,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_EARTH,MOBPARAM_IGNORE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_MAGIC_DEF_DOWN, 20, 3, 60);
    MobStatusEffectMove(mob, target, EFFECT_SLOW, 2000, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_BIND, 1, 0, 15);
    MobStatusEffectMove(mob, target, EFFECT_RASP, 10, 3, 60);
    mob:resetEnmity(target);
    target:delHP(dmg);
    return dmg;
end;
