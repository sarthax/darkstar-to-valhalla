---------------------------------------------
-- Keraunos Quill (Ocythoe, Voidwatch Jeuno VI [S])
-- Forum [B]: AoE, paralyze, weapon-slot encumbrance. Skill id 2811 / anim 2555 from the DSP data (previously commented out).
-- Damage/durations [D]; encumbrance is cosmetic (engine does not lock slots), as in typhoean_rage.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg()*3, ELE_THUNDER, 1.5, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_THUNDER, MOBPARAM_WIPE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_PARALYSIS, 25, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 60);
    target:delHP(dmg);
    skill:setMsg(msgBasic.DAMAGE);
    return dmg;
end;
