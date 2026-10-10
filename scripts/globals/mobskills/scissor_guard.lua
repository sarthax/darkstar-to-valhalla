---------------------------------------------------
-- Scissor Guard
-- Enhances defense 100%.
---------------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/voidwatch");

---------------------------------------------------

function onMobSkillCheck(target,mob,skill)
    if (vwBuffActive ~= nil and vwBuffActive(mob, EFFECT_DEFENSE_BOOST)) then return 1; end -- Voidwatch NMs: no re-buff while active
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local typeEffect = EFFECT_DEFENSE_BOOST;
    skill:setMsg(MobBuffMove(mob, typeEffect, 100, 0, 60));
    return typeEffect;
end;
