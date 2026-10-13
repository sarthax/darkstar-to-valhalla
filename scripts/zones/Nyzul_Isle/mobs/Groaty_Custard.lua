-----------------------------------
-- Area: Nyzul Isle
--  Mob: Groaty Custard (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family -- BG Wiki: "Uses standard Flan
-- TP moves. Amplification makes it absorb one type of physical damage until the next TP move;
-- Boiling Point makes it absorb one type of magical damage until the next TP move." Both TP moves
-- are already real, unmodified members of the base Flan skill list (112) -- no Lua-side restriction
-- needed, unlike the Chariot family's non-list special moves. Distinct mob_pools row from
-- Investigation's own Custard-family leaders (Anise/Ginger/etc.) -- not a duplicate.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

