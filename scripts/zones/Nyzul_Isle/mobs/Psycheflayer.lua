-----------------------------------
-- Area: Nyzul Isle
--  Mob: Psycheflayer
-----------------------------------
-- 2026-09-03: wired into the real Layout 6 "Demons" enemy pool (Imp x10, Psycheflayer x2 -- see
-- Imp.lua's header). Real mob_spawn_points rows (17092701-17092702, mob_groups groupid 23/poolid
-- 3215, zone 77, real level 66-68) already existed, unwired. No family mixin exists for this mob
-- in this codebase (checked scripts/mixins/families/ -- no soulflayer/psycheflayer file) --
-- combat behavior comes entirely from mob_pools' own columns (cmbSkill/behavior/spellList),
-- same as any other mixin-less mob.
--
-- 2026-09-03 (later): Psycheflayer is ALSO one of the real ELIMINATE_SPECIFIED_ENEMIES family
-- groups (a second, separate real pool: 17092974-17092978, groupid 23 there too but a distinct
-- poolid/level range from the Layout 6 pair) -- since Topaz resolves scripts by npc/mob NAME, both
-- pools share this one file. Calling both kill hooks unconditionally is safe -- each has its own
-- stage guard (ELIMINATE_ALL_ENEMIES vs ELIMINATE_SPECIFIED_ENEMIES), so only the one matching
-- the instance's actual current objective ever does anything.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.eliminateAllKill(mob)
    Nyzul.specifiedEnemyKill(mob)
    Nyzul.specifiedGroupKill(mob)
end

