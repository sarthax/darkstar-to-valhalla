-----------------------------------
-- Area: Nyzul Isle
--  Mob: Abject Farzahd (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Soulflayer family -- BG Wiki: "Uses Mind
-- Blast and casts Blizzaga III frequently. Can use Reprobation (full dispel including food, but
-- not including Embrava)." Mind Blast (real mob_skill_id 1963) is already enabled in the base
-- Soulflayer skill list (233), so no force-fire scripting is needed -- the engine's normal AI
-- already includes it. NOT built: scripted Blizzaga III casting (no established scripted-spellcast
-- pattern anywhere in this family) and Reprobation (real mob_skill_id 1969, confirmed NOT a member
-- of list 233 -- no HP/frequency trigger cue given by the wiki, left unbuilt and flagged rather
-- than guessed, same reasoning as Abject_Awiija.lua).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

