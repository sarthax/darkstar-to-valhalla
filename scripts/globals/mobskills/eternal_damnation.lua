---------------------------------------------
--  Eternal Damnation
--
--  Voidwalker NM Lord Ruthven. Dark magical AoE with Defense Down.
--  Damage numbers are DESIGN GUESSES (not wiki-sourced); tune after testing.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
---------------------------------------------

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*3,ELE_DARK,1.5,TP_NO_EFFECT,0);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_DARK,MOBPARAM_WIPE_SHADOWS);
    target:delHP(dmg);
    MobStatusEffectMove(mob, target, EFFECT_DEFENSE_DOWN, 25, 0, 60);
    return dmg;
end;
