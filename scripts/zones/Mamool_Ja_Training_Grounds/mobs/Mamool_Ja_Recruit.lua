-----------------------------------
-- Area: Mamool Ja Training Grounds (Breaking Morale)
--  Mob: Mamool Ja Recruit
-----------------------------------
-- Ambient camp guard -- see instances/breaking_morale.lua. Corrected 2026-08-18: real objective
-- is looting Supplies Crates and turning them in to Quhaaja, not killing these; no longer tied
-- to instance progress.
-- 2026-08-24, user-reported: Recruits still attack while the Viscous Liquid disguise
-- (EFFECT_ILLUSION) is active. Real mechanic per the wiki (already noted in
-- Viscous_Liquid.lua's own header as "NOT implemented here... flagged as a follow-up" -- this is
-- that follow-up): the disguise prevents Mamool Ja Recruit aggro entirely. No existing hook was
-- confirmed for pre-empting the native aggro decision itself, so this uses onMobEngaged (the same
-- real, engine-provided hook Mamool_Ja_Trainer.lua already relies on) to immediately disengage
-- the instant a disguised player is engaged.
-- 2026-08-24, follow-up, user re-reported still attacking after the above: resetEnmity() alone
-- doesn't necessarily stop an already-engaged mob's current combat tick -- every other real
-- combat-termination case elsewhere this session (Black_Baron.lua, Sagelord_Molaal_Ja.lua) always
-- pairs it with an explicit disengage() too. Added here to match.
-- 2026-08-24, further follow-up: Viscous_Liquid.lua reworked to grant EFFECT_COSTUME instead
-- of EFFECT_ILLUSION (see that file's header for the full reasoning -- ILLUSION's real
-- setCostume() mechanism turned out to have unrelated engine-level side effects). Check updated
-- to match.
-----------------------------------
function onMobEngaged(mob, target)
    if target:getObjType() == TYPE_PC and target:hasStatusEffect(EFFECT_COSTUME) then
        mob:disengage()
        mob:resetEnmity(target)
    end
end

function onMobDeath(mob, player, isKiller)
end

