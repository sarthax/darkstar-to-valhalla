-----------------------------------
-- Area: Nyzul Isle
--  Mob: Abject Kharoub (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Soulflayer family -- BG Wiki: "Uses
-- standard Soulflayer TP moves. Can use Reprobation (full dispel including food, but not including
-- Embrava). Has access to all the Unbridled Learning Spells." Standard TP moves (Mind Blast/Mind
-- Purge, real ids 1963/1966) are already enabled in the base Soulflayer skill list (233), no extra
-- scripting needed. NOT built: Unbridled Learning spell access (a real BLU-specific spell-grant
-- mechanic this codebase has no confirmed per-mob binding for) and Reprobation (real mob_skill_id
-- 1969, confirmed NOT a member of list 233 -- no HP/frequency trigger cue given by the wiki, left
-- unbuilt and flagged rather than guessed, same reasoning as Abject_Awiija.lua/Abject_Farzahd.lua).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

