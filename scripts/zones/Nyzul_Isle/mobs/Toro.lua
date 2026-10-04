-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Toro (tier 3/Nashmeira-floor lamp trigger). 2026-09-28: user confirmed the wiki text they'd
--  fed me earlier had the floor 3/4 boss names transposed. Real mapping, confirmed against the
--  captured boss spawn positions (Nashmeira 17093247 at (-33.5,-0.449,-380), same z-band as Toro's
--  East Room; Lilisette 17093286 at (-20,-4.5,-11), matching the separate Warder room cluster):
--    Floor 3 (Nashmeira) key mobs: Toro / Miura (this file + Miura.lua). NOT the Warders.
--    Floor 4 (Lilisette) key mobs: the 6 Warder variants + trash. See Warder_Liberator.lua etc.
--  "Kill either Miura or Toro to activate the Runic Lamp. It's random which one will activate the
--  lamp" -- NOT "kill both". One candidate is randomly picked (first of the pair to die) as the
--  real key; the other is just trash. See tpz.heroines.randomKeyDeath in heroines_holdfast.lua.
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local CANDIDATES = { 17093212, 17093213 } -- Toro, Miura

function onMobDeath(mob, player, isKiller)
    tpz.heroines.randomKeyDeath(mob, "Nashmeira_Key", CANDIDATES, 3)
end

