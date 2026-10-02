---------------------------------------------
--  Gusting Gouge
--
--  Description: Deals Wind damage in a threefold attack to targets in a fan-shaped area of effect.
--  Type: Physical?
--  Utsusemi/Blink absorb: 2-3 shadows
--  Range: Melee?
--  Notes: Used only by Lamia equipped with a one-handed weapon. If they lost their weapon, they'll use Hysteric Barrage instead.
---------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

---------------------------------------------

function onMobSkillCheck(target,mob,skill)
    -- Topaz gate: only COR/BRD/RDM lamias, and only while armed (animationsub 0)
    local job = mob:getMainJob()
    if mob:AnimationSub() == 0 and (job == JOBS.COR or job == JOBS.BRD or job == JOBS.RDM) then
        return 0
    end
    return 1
end;

function onMobWeaponSkill(target, mob, skill)
    local numhits = math.random(2, 3);
    local accmod = 1;
    local dmgmod = 1;
    local info = MobPhysicalMove(mob,target,skill,numhits,accmod,dmgmod,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_BLUNT,info.hitslanded);
    target:delHP(dmg);
    return dmg;
end;
