-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Gigantoad (tier 2/Prishe-floor lamp trigger, paired with Twinkling Treant). Per user
--  2026-09-28: "Kill Twinkling Treant or Gigantoad to activate the Runic Lamp. It's random which
--  one" -- NOT "kill both". One candidate is randomly picked (first of the pair to die) as the
--  real key. See tpz.heroines.randomKeyDeath in heroines_holdfast.lua.
--  NOTE: Twinkling Treant (mob_spawn_points 17093180) fixed 2026-09-28 -- user confirmed real
--  position (-312.000,0.000,-393.000), right next to the Rune of Transfer in this room. Also
--  registered in instance_entities for instance 80 (was missing, same "never wired" bug class
--  as Miura/the Warders).
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local CANDIDATES = { 17093179, 17093180 } -- Gigantoad, Twinkling Treant

function onMobDeath(mob, player, isKiller)
    tpz.heroines.randomKeyDeath(mob, "Prishe_Key", CANDIDATES, 2)
end

