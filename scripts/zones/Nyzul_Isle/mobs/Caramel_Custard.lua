-----------------------------------
-- Area: Nyzul Isle
--  Mob: Caramel Custard (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family -- BG Wiki: "Takes normal or
-- increased physical damage and reduced magical damage." Distinct mob_pools row from Investigation's
-- own Custard-family leaders -- not a duplicate. Reduced-magic-damage trait is already covered by
-- the base Flan family's high inherent MDEF (mob_pools column, unmodified) -- no additional mod
-- needed beyond the base stat line per the reskin-precedent used throughout this item.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

