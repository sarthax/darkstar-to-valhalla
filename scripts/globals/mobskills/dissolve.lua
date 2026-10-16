---------------------------------------------
--  Dissolve (Blobdingnag, Voidwalker)
--
--  AoE HP drain (msg 187 'HP drained'), hit 2 targets.
--  [D] Damage numbers are a design guess; captured values: 543, 589
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

---------------------------------------------
function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob,target,skill,mob:getWeaponDmg()*3,ELE_DARK,1.5,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_MAGICAL,MOBPARAM_DARK,MOBPARAM_WIPE_SHADOWS);
    skill:setMsg(MobDrainMove(mob, target, MOBDRAIN_HP, dmg));
    return dmg;
end;
