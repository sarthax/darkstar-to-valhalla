---------------------------------------------------
-- Yaksha Stance (Hahava, Voidwatch)
-- Self stance: erases all status effects, -50% physical damage taken (not dispellable) [J]
-- Evidence: [J wikiwiki.jp Hahava, F FFXIclopedia]; damage/durations [D] (see docs/voidwatch/UNIMPLEMENTED.md)
---------------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    mob:eraseAllStatusEffect();
    mob:delMod(MOD_DMGPHYS, mob:getLocalVar("HH_PHYS"));
    mob:setLocalVar("HH_PHYS", -50);
    mob:addMod(MOD_DMGPHYS, -50);
    mob:setLocalVar("HH_STANCE", 1);
    skill:setMsg(msgBasic.NO_EFFECT);
    return 0;
end;
