-----------------------------------
-- Area: Nyzul Isle
--  Mob: Archaic Rampart
-----------------------------------
-- 2026-09-07: real fix -- BG Wiki: "There will always be an Archaic Rampart next to the HNM; this
-- can be used to build TP before engaging the boss." Real, pre-existing mob_spawn_points row
-- (mob_groups groupid 1/poolid 221, zone 77), just never wired to anything until now -- see
-- IDs.lua's ARCHAIC_RAMPART entry and nyzul_isle_investigation.lua's spawnRandomBoss. Plain stub
-- (matches Mokke.lua/Racing_Chariot.lua's own treatment for base-combat-only mobs) -- the engine
-- calls onMobDeath on every mob death regardless of script content, and a missing file (not just
-- an empty one) throws "undefined procedure onMobDeath", so this needs to exist even with no
-- special behavior. No death reward/progress hook -- it's a free TP punching bag per the wiki,
-- not a kill objective.
-----------------------------------
function onMobDeath(mob, player, isKiller)
end

