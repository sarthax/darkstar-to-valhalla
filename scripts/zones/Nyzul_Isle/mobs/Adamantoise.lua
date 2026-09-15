-----------------------------------
-- Area: Nyzul Isle
--  Mob: Adamantoise
-----------------------------------
-- 2026-09-04: real boss-floor HNM (floors 20/40, per BG Wiki), user-confirmed real roster
-- alongside Behemoth/Fafnir. A FIRST real mob_spawn_points row (17092999, mob_groups groupid 160)
-- has poolid 0 -- genuinely undefined/incomplete data, not used. This uses a SECOND, correctly-
-- populated real row instead (17093102, mob_groups groupid 260, poolid 44, level 80-80 -- all
-- real, valid data) -- just never wired to anything until now. No special-move scripting ported
-- (same treatment as Behemoth.lua/Fafnir.lua) -- base combat comes from mob_pools' own columns.
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

