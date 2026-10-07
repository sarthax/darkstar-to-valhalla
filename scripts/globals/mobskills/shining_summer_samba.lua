-----------------------------------
-- Shining Summer Samba (Mumor, Heroines' Holdfast)
-- Skill id/animation from capture #237. Damage/effect below is a PLACEHOLDER: capture shows 17-66 dmg on players and a self-target line; modelled as damage + self Haste.
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
    -- 2026-09-27: wired the "...Samba!" callout, see tpz.heroines.MUMOR_LINES (globals/heroines_holdfast.lua)
    tpz.heroines.mumorSay(mob, "shining_summer_samba")
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_DEFENSE_DOWN, 25, 0, 30)
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_MAGIC_DEF_DOWN, 25, 0, 40)
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 17, 82, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Mumor Shining Summer Samba 17-82 (10 samples, 139 outlier dropped). Additional effects are NOT captured.
-- Defense Down 25%/30s: capture #237 Siknawz Defense 1108 -> 831 (x0.75) after Samba, wore off ~31s after; Magic Def Down 40s inferred from wear-off (~41s). Attribution by timing, not a decoded effect packet.
