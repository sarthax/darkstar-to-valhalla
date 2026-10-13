---------------------------------------------
--  Corpse Breath (Virvatuli)
--  [C] skill id 2511, anim 1775 (capture). Ignores shadows, ~200-600 dmg [FFXIclopedia]; Blind [J wikiwiki.jp]; dark element + params [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    MobStatusEffectMove(mob, target, EFFECT_BLINDNESS, 20, 0, 120); -- [J] "Breath damage, Blind"; power/duration [D]
    local dmgmod = MobBreathMove(mob, target, 0.1, 1, ELE_DARK, 200); -- [D]
    local dmg = MobFinalAdjustments(dmgmod,mob,skill,target,MOBSKILL_BREATH,MOBPARAM_DARK,MOBPARAM_IGNORE_SHADOWS);
    target:delHP(dmg);
    return dmg;
end;
