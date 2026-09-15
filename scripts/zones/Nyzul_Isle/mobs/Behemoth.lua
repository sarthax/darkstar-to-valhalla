-----------------------------------
-- Area: Nyzul Isle
--  Mob: Behemoth
-----------------------------------
-- 2026-09-03: real boss-floor HNM (floors 20/40, per BG Wiki). Real, pre-existing mob_spawn_points
-- row (17093000, mob_groups groupid 161/poolid 387, zone 77, level 80) -- just never wired to
-- anything until now. NOT a copy of Behemoths_Dominion/mobs/Behemoth.lua -- that file is specific
-- to its own zone (references that zone's own QM npc/LandKingSystem globals) and Nyzul's real
-- version is explicitly scaled down per the wiki ("HP and overall strength...will not be as it is
-- outside of this Assault"), matching this real mob_pools row's own stats. The real rage/TP-move
-- mixin from that zone's version is NOT ported here -- base combat comes from mob_pools' own
-- columns only, same treatment as Imp/Psycheflayer/Mokke.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
-- 2026-09-15, real crash found live (AI state stack overflow) -- see Fafnir.lua's matching comment
-- for the full root-cause writeup and the two wrong fixes tried before landing on the real one
-- (despawnBosses() itself now guards on mob:isSpawned() -- nyzul_isle_investigation.lua). This
-- file is back to its original, pre-2026-09-15 state; no mob-side change needed.
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
    Nyzul.bossArmorDrop(player, mob)
end

