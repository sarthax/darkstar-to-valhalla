-----------------------------------
-- Final Eternal Heart (Mumor 25% HP telegraphed AoE, Heroines' Holdfast)
-- Capture #237: chat "Get close to Mumor before it's too late!" then the skill; two players
-- (far away) were KO'd, melee players standing on Mumor took 78-231 and lived.
-- Modelled as: players within 20 yalms (wiki) take 15% of their max HP, everyone else is KO'd.
-- The real safe radius and damage are NOT captured.
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/heroines_holdfast")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
-- 2026-09-29 (user report): "Mumor is using Final Eternal Heart above 25%... observed it happening
-- multiple times in a run." Root cause: this always returned 0 (valid), so the engine's own random
-- TP-based weaponskill AI (mob_controller.cpp CMobController::MobSkill(), called unconditionally off
-- TPUseChance()) could pick FEH straight out of her mob_skill_lists pool (1061) at ANY HP%, fully
-- bypassing the phase-gated `mob:useMobAbility(FINAL_ETERNAL_HEART)` scripted call in Mumor.lua
-- (which only runs once phase 0->1 has already required HPP<=25). That scripted call goes through a
-- separate direct-invoke path (CMobController::MobSkill(targid, wsid)) that never calls
-- onMobSkillCheck, so gating it here does not affect the intended scripted use.
function onMobSkillCheck(target, mob, skill)
    -- 2026-10-02 (user): FEH must be in her pool at all times while she is under 25% in the second
    -- phase (HH_Phase >= 1, set by Mumor.lua at the 25% transition). Above 25% (phase 0, or after
    -- the heal to 50% until she drops below 25% again) it stays blocked so the engine's random
    -- TP pick can't use it early. The scripted useMobAbility opener bypasses this check.
    if mob:getLocalVar("HH_Phase") >= 1 and mob:getHPP() <= 25 then
        return 0
    end
    return 1
end

function onMobWeaponSkill(target, mob, skill)
    -- 2026-09-27: wired the "Final!!! Eternal!!! Heart!!!" callout, see tpz.heroines.MUMOR_LINES
    -- (globals/heroines_holdfast.lua) -- ultimate move, always the full line (no short variant).
    tpz.heroines.mumorSay(mob, "final_eternal_heart")
    local dmg
    if mob:checkDistance(target) <= 20 then
        dmg = math.floor(target:getMaxHP() * 0.15)
    else
        dmg = target:getHP() + 9999
    end
    target:delHP(dmg)
    return dmg
end

