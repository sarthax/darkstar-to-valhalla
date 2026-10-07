-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Auspicious Tiger (trash, no mechanic tie). File was entirely missing (map-server log:
--  "undefined procedure onMobDeath"), so kills here never dropped anything.
--  2026-09-29: "Trash mobs should drop items at random from the pool of items that the vending
--  chest would normally drop. Drop rate should be 20%." -- see tpz.heroines.trashDrop.
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    tpz.heroines.trashDrop(mob, player)
end

