-----------------------------------
-- Knuckle Sandwich (Prishe, Heroines' Holdfast)
-- Ported from LandSandboat's knuckle_sandwich.lua (Trust: Prishe II). Magical LIGHT, fTP/element are
-- LSB's own uncaptured placeholders.
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/heroines_holdfast")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    -- 2026-09-29: same fix as nullifying_dropkick.lua -- flavor quip never fired for HH Prishe.
    -- dialog.yml id 7586 confirmed this session (exact match, capture #240, no drift in this range).
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    tpz.heroines.skillSay(mob, 7586) -- once per use (onMobSkillCheck runs every AI tick)
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_WEAKNESS, 1, 0, 30) -- wiki
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 50, 80, MOBSKILL_MAGICAL, MOBPARAM_LIGHT)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Prishe Knuckle Sandwich 63 (1 sample, range widened). Additional effects are NOT captured.
