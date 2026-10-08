---------------------------------------------
--  Tainting Breath  (Melancholic Moira, Voidwatch)
--  [B #106] named in her kit; [B #611] radial. The skill row exists only as a commented LSB line (id 2575, anim 63).
--  No capture and no effect text: damage and Disease are [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    MobStatusEffectMove(mob, target, EFFECT_DISEASE, 1, 0, 60);
    local dmgmod = math.random(300, 500);
    local dmg = MobFinalAdjustments(dmgmod, mob, skill, target, MOBSKILL_BREATH, MOBPARAM_EARTH, MOBPARAM_IGNORE_SHADOWS);
    target:delHP(dmg);
    return dmg;
end;
