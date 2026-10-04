-----------------------------------
-- Imperial Authority (Heroines' Holdfast automatons/Nashmeira)
-- Placeholder tuning: capture #237 confirms the skill id/animation only; fTP, dmgmod and the
-- additional effect are NOT captured (LSB port: 3 hits + STUN 10s).
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/heroines_holdfast")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_STUN, 1, 0, 10)
    mob:resetEnmity(target) -- wiki: hate reset
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 90, 95, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Nashmeira Imperial Authority 92-93 (2 samples). Additional effects are NOT captured.
