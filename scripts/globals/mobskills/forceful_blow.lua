---------------------------------------------
--  Forceful Blow
--
--  Description: Delivers a powerful strike to a single target.
--  Type: Physical
--  Utsusemi/Blink absorb: 1 shadow
--  Range: Melee
--  Notes: Only used by unarmed Mamool Ja of the warrior class (THF, NIN, BLU, BST, DRG).
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

---------------------------------------------
function onMobSkillCheck(target,mob,skill)
    -- H2H only (Topaz parity): valid only once the weapon has been thrown (AnimationSub 1 = unarmed)
    -- WHM/BLM/NIN Mamool Ja are always empty-handed (user-confirmed; captures show mage Warders using it)
    local job = mob:getMainJob();
    local unarmedJob = (job == JOBS.WHM or job == JOBS.BLM or job == JOBS.NIN);
    if mob:getFamily() == 176 and not unarmedJob and mob:AnimationSub() ~= 1 then
        return 1;
    end
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local numhits = 1;
    local accmod = 1;
    local dmgmod = 3;
    local info = MobPhysicalMove(mob,target,skill,numhits,accmod,dmgmod,TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg,mob,skill,target,MOBSKILL_PHYSICAL,MOBPARAM_BLUNT,info.hitslanded);
    target:delHP(dmg);
    return dmg;
end;
