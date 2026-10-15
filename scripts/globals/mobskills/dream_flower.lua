---------------------------------------------------
-- Dream Flower
-- 15' AoE sleep
-- Pancimanci (Voidwatch) has a custom version [user]: resets hate and damage does not wake the target.
---------------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

---------------------------------------------------

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local typeEffect = EFFECT_SLEEP_I;

    local msg = MobStatusEffectMove(mob, target, typeEffect, 1, 0, math.random(20, 30));
    if (mob:getName() == "Pancimanci") then
        mob:resetEnmity(target);
        local e = target:getStatusEffect(EFFECT_SLEEP_I);
        if (e ~= nil) then e:unsetFlag(EFFECTFLAG_DAMAGE); end -- hits will not wake [user]
    end
    skill:setMsg(msg);

    return typeEffect;
end;
