---------------------------------------------------
-- Mega Scissors (Krabimanjaro)
-- Frontal cone, heavy slashing damage, resets enmity (BG wiki: "frontal cone high damage and hate reset").
-- Damage multiplier is a judgement call (no retail number); tune after in-game test.
---------------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob,target,skill,1,1,4.0,TP_DMG_VARIES,1,2,3);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_SLASH,info.hitslanded);
    target:delHP(dmg);
    mob:resetEnmity(target);
    return dmg;
end;
