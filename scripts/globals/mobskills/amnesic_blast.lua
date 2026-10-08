---------------------------------------------
--  Amnesic Blast  (Kholomodumo, Voidwatch)
--  [B #614] cone Amnesia + damage. Skill id 2391, anim 1664, msg 185, ~80 dmg on one target [C Raguza 2021.03.28].
--  Damage multiplier and Amnesia duration are [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg() * 2, ELE_DARK, 1, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_DARK, MOBPARAM_IGNORE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_AMNESIA, 1, 0, 30);
    target:delHP(dmg);
    skill:setMsg(msgBasic.DAMAGE);
    return dmg;
end;
