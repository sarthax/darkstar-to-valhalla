---------------------------------------------------
-- Raksha Stance (Hahava, Voidwatch)
-- Self stance: removes magic effects, drops the physical reduction [J]
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
    mob:setLocalVar("HH_PHYS", 0);
    mob:setLocalVar("HH_STANCE", 2);
    skill:setMsg(msgBasic.NO_EFFECT);
    return 0;
end;
