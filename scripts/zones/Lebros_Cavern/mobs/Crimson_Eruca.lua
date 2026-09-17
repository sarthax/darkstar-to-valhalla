-----------------------------------
-- Area: Lebros Cavern
--  Mob: Crimson Eruca
-----------------------------------
-- 2026-08-25: real hostile obstacle mob for Lebros Supplies (see instances/lebros_supplies.lua) --
-- mission progress comes from delivery, not from killing these. This file never existed at all
-- despite mob_pools/IDs.lua already referencing it (poolid 837), causing a real
-- "luautils::onMobDeath: undefined procedure onMobDeath" error on every kill. Minimal stub only.
-----------------------------------
function onMobDeath(mob, player, isKiller)
end

