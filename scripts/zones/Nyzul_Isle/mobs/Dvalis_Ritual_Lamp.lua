-----------------------------------
-- Area: Nyzul Isle
--  Mob: Dvali's Ritual Lamp (Dvali Jonah's pet add, instance 52)
-----------------------------------
-- Reskin of Pandemonium_Lamp (Aydeewa Subterrane), which has no Lua script of its own -- this
-- stub exists only to satisfy luautils::OnMobDeath (unlike the Honor Guard/Gorgon Handmaid adds,
-- these are killable by players mid-fight, not just despawned by the boss script). All real
-- rewards/progress are handled by Dvali_Jonah's own onMobDeath; nothing is invented here.
-----------------------------------
function onMobDeath(mob, player, isKiller)
end

