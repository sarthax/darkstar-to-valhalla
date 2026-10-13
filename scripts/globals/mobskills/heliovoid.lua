---------------------------------------------
--  Heliovoid  (Lord Asag, Voidwatch)
--
--  [F] Absorbs effects / dispels, then Amnesia. Exact retail behaviour
--  unverified; implemented as one dispel + Amnesia [D] (see UNIMPLEMENTED.md).
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

---------------------------------------------
function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    target:dispelStatusEffect();
    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_AMNESIA, 1, 0, 30));
    return EFFECT_AMNESIA;
end;
