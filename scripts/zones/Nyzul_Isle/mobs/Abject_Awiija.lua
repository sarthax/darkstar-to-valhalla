-----------------------------------
-- Area: Nyzul Isle
--  Mob: Abject Awiija (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Soulflayer family -- BG Wiki: "Uses Mind
-- Purge in addition to other normal TP moves and ice spells. Can use Reprobation (full dispel
-- including food, but not including Embrava)." Mind Purge (real mob_skill_id 1966) is already
-- enabled in the base Soulflayer skill list (233), so no force-fire scripting is needed for it --
-- the engine's normal AI already includes it. NOT built: the "ice spells" nuking kit (no
-- established scripted-elemental-magic pattern anywhere in this family, same gap as Uroro
-- Samaroro's Water/Waterga) and Reprobation (real mob_skill_id 1969, confirmed NOT a member of
-- list 233 -- but the wiki gives no HP/frequency trigger cue for it at all, unlike the Chariot
-- family's "at low health"/"close to dying" wording, so imposing an invented trigger condition
-- would not be honestly sourced; left unbuilt and flagged rather than guessed).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

