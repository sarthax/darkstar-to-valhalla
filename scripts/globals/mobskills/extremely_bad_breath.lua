---------------------------------------------
--  Extremely Bad Breath
--
--  Voidwatch (Melancholic Moira): conal AoE instant Death, ignores shadows, stunnable (prepare time) [W BG, F].
--  Row 1332 from the LSB commented-out set; anim 1076 unverified [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
---------------------------------------------
function onMobSkillCheck(target,mob,skill)
    if (mob:getLocalVar("VW_DEADLINE") == 0) then return 1; end
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    -- Instant death, ignores shadows; Moira-style fixed kill (no resist roll) [D]
    local dmg = MobFinalAdjustments(target:getHP(),mob,skill,target,MOBSKILL_BREATH,MOBPARAM_EARTH,MOBPARAM_IGNORE_SHADOWS);
    if (dmg > 0) then
        target:setHP(0);
    end
    return dmg;
end;
