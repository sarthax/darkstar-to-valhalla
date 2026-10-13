-----------------------------------
-- Eternal Vana Illusion (Mumor, Heroines' Holdfast)
-- Skill id/animation from capture #237. Damage/effect below is a PLACEHOLDER: capture msg 185; plain AoE hit.
-- 2026-09-29 (user): phase-2-only move per wiki ("New abilities in phase 2: Eternal Vana Illusion...")
-- -- gated on Mumor.lua's own HH_Phase localvar (set to 1 at HP<=25%, see Mumor.lua onMobFight)
-- so the AI can't roll this skill out of her mob_skill_lists pool (1061) before phase 2 begins.
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/heroines_holdfast")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    if mob:getLocalVar("HH_Phase") < 1 then
        return 1
    end
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    -- 2026-09-27: wired the "...Illusion!" callout, see tpz.heroines.MUMOR_LINES (globals/heroines_holdfast.lua)
    tpz.heroines.mumorSay(mob, "eternal_vana_illusion")
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 636, 1659, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Mumor Eternal Vana Illusion 1038 x4, 636-1659 (9 samples). Additional effects are NOT captured.
-- Attack Down 30s: capture #237 Siknawz "Attack Down wears off" 29s after Eternal Vana Illusion (23:11 -> 23:40); power guessed.
