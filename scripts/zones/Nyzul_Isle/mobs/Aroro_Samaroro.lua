-----------------------------------
-- Area: Nyzul Isle
--  Mob: Aroro Samaroro (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Poroggo family -- BG Wiki: "Uses standard
-- Poroggo TP moves. Casts various tier 3 -ga spells and uses Providence to cast Ancient Magic."
-- NOT built: the scripted tier-3-ga / Providence-into-Ancient-Magic spellcasting kit -- no
-- established Lua pattern for this exists anywhere in the Poroggo family's scripts (Uriri/Eriri/
-- Oriri/Uroro/Iroro are all plain reskins or single-TP-move-only), and Ancient Magic access in
-- particular is a real, non-trivial spell-list mechanic this codebase has no confirmed per-mob
-- binding for. Flagged here rather than invented -- ships as a plain reskin (standard Poroggo TP
-- moves from the base skill list, unmodified) pending a real precedent or explicit go-ahead to
-- build scripted spellcasting from scratch.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

