-----------------------------------
-- Area: Periqia (Saving Private Ryaaf)
--  Mob: Cursed Chigoe
-----------------------------------
-- Ambient obstacle, 3 per room -- see instances/saving_private_ryaaf.lua. This file originally
-- existed only to satisfy the engine's onMobDeath hook lookup (was previously missing entirely,
-- logging "undefined procedure onMobDeath" on every kill).
-- 2026-08-22, user-requested: real FFXI Chigoes are classically undetectable/untargetable until
-- they aggro -- `mob_pools` poolid 865's `entityFlags` restored to include `FLAG_UNTARGETABLE`
-- (see that SQL row's comment for the full writeup on why the earlier fix removed it, and why
-- that was the wrong direction). Reveal now happens explicitly here on `onMobEngaged` -- same
-- reveal-on-event shape as Saving Private Ryaaf's own Hunched Figures
-- (instances/saving_private_ryaaf.lua's revealOccupant()).
-----------------------------------
function onMobSpawn(mob)
    mob:untargetable(true)
    mob:hideName(true)
end

function onMobEngaged(mob, target)
    mob:untargetable(false)
    mob:hideName(false)
end

function onMobDeath(mob, player, isKiller)
end

