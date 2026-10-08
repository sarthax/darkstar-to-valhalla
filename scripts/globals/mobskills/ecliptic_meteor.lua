---------------------------------------------
--  Ecliptic Meteor  (Kholomodumo, Voidwatch)
--  [B #614] only used below 50% HP. Skill id 2586, anim 1684, msg 185, ~103 dmg to one target at ~1:25 into the
--  fight [C Raguza 2021.03.28]. Retail damage is larger on unshelled targets [B #801]; multiplier here is [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg() * 6, -1, 1, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_DARK, MOBPARAM_IGNORE_SHADOWS);
    -- [J wikiwiki.jp, F] also Blindness, Paralysis and Bio (-10HP/3s); durations/potency [D]
    MobStatusEffectMove(mob, target, EFFECT_BLINDNESS, 30, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_PARALYSIS, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_BIO, 10, 3, 60);
    target:delHP(dmg);
    skill:setMsg(msgBasic.DAMAGE);
    return dmg;
end;
