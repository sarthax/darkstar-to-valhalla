-----------------------------------
-- Area: Nyzul Isle
--  Mob: Khimaira
-----------------------------------
-- 2026-09-03: real boss-floor HNM (floors 60/80/100, per BG Wiki). Real, pre-existing
-- mob_spawn_points row (17093002, mob_groups groupid 163/poolid 2220, zone 77, level 80) -- just
-- never wired to anything. No special-move scripting ported (same treatment as Behemoth.lua/
-- Fafnir.lua) -- base combat comes from mob_pools' own columns. Wiki's floor-100 desperation move
-- (Fulmination) is not implemented here.
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
    Nyzul.handleRunicKey(mob)
end

