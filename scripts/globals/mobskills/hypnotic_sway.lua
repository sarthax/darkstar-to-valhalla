---------------------------------------------
-- Hypnotic Sway (Lamia) -- DSP port of Topaz hypnotic_sway.lua (Amnesia 60s)
---------------------------------------------
require("scripts/globals/monstertpmoves");
require("scripts/globals/status");
require("scripts/globals/msg");

function onMobSkillCheck(target, mob, skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    local typeEffect = EFFECT_AMNESIA
    skill:setMsg(MobStatusEffectMove(mob, target, typeEffect, 1, 0, 60))
    return typeEffect
end
