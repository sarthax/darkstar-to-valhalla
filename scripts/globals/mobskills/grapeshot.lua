-----------------------------------
-- Grapeshot (Lion, Heroines' Holdfast)
-- Ported from LandSandboat's grapeshot.lua via the Trust framework; fTP/durations are LSB's
-- own uncaptured placeholders (capture #237 shows ~24-30 dmg per use on players).
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
    tpz.heroines.skillSay(mob, tpz.heroines.LION_LINES[math.random(#tpz.heroines.LION_LINES)])
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_STUN, 1, 0, 5)
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 4, 30, MOBSKILL_PHYSICAL, MOBPARAM_PIERCE)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Lion Grapeshot 4-30 (8 samples). Additional effects are NOT captured.
-- Stun 5s: capture #237 "Siknawz is no longer stunned" 5s after a Grapeshot (23:32:51-56); Stun itself inferred from that timing.
