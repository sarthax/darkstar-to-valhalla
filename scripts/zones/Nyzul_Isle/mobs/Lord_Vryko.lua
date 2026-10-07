-----------------------------------
-- Area: Nyzul Isle
--  Mob: Lord Vryko (boss floor 80, Uncharted Area Survey, instance 52)
-----------------------------------
-- Reskin of Vampyr_Jarl (mob_pools poolid 4130, familyid 252) -- confirmed this session that
-- Vampyr_Jarl has NO Lua script anywhere in the tree (its existing reskins Enigmatic_Vampyr/
-- Soaring_Vampyr likewise have none), so base combat comes entirely from mob_pools' own columns,
-- same treatment as Adamantoise.lua/Fafnir.lua for the other Investigation boss floors. No
-- special-move scripting invented here.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
    Nyzul.bossArmorDrop(player, mob)
    Nyzul.unchartedVrykoCoinPurseDrop(player, mob)
    Nyzul.unchartedAstrariaFragmentGain(player, mob)
end

