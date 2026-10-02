---------------------------------------------
--  Rushing Drub
--
--  Description: Delivers a fourfold attack on a single target.
--  Type: Physical
--  Range: Melee
--  Notes: WHM/BLM Mamool Ja, only once unarmed (staff thrown via Stave Toss, animationsub 1).
--  Ported from Topaz rushing_drub.lua.
---------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

---------------------------------------------

function onMobSkillCheck(target,mob,skill)
    if mob:AnimationSub() == 1 then
        return 0;
    end
    return 1;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob,target,skill,4,1,1,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_BLUNT,info.hitslanded);
    target:delHP(dmg);
    return dmg;
end;
