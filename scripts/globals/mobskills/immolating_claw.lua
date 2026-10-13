---------------------------------------------
-- Immolating Claw (Gaunab, Voidwatch Jeuno VI [S])
-- Name/theme from forum [B]; skill id 2809 / anim 2553 from the DSP data (previously commented out).
-- Effect is UNKNOWN: modelled as single-target fire damage. Damage/ratio [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg()*3, ELE_FIRE, 1.5, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_FIRE, MOBPARAM_WIPE_SHADOWS);
    target:delHP(dmg);
    skill:setMsg(msgBasic.DAMAGE);
    return dmg;
end;
