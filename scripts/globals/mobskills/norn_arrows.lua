---------------------------------------------
--  Norn Arrows
--
--  Voidwalker NM Verthandi. AoE ranged attack, knockback, Encumbrance (wiki).
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
    MobStatusEffectMove(mob, target, EFFECT_ENCUMBRANCE_I, 1, 0, 60);

    local info = MobPhysicalMove(mob,target,skill,1,4,5,TP_DMG_VARIES,1,2,3);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_RANGED,MOBPARAM_PIERCE,MOBPARAM_IGNORE_SHADOWS);
    target:delHP(dmg);
    return dmg;
end;
