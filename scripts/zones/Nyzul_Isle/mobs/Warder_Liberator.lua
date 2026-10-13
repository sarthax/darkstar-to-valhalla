-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Warder Liberator, one of 6 Dynamis-beastman-class Warder variants (Footsoldier,
--  Neckchopper, Depredator, Vindicator, Liberator, Partisan) that are the floor4/Lilisette lamp
--  trigger. 2026-09-28: user confirmed the wiki text they'd fed me earlier had the floor 3/4 boss
--  names transposed -- these 6 Warders are Lilisette's key mobs, not Nashmeira's (Toro/Miura are
--  Nashmeira's, see Toro.lua). Confirmed against captured boss spawn positions (Nashmeira 17093247
--  at (-33.5,-0.449,-380); Lilisette 17093286 at (-20,-4.5,-11), matching this room cluster).
--  "Kill one of the Dynamis-style beastmen... It's random which one will activate the lamp" --
--  NOT "all 6 must die". One candidate across all 6 variants is randomly picked (first of the
--  group to die) as the real key; the rest are trash. See tpz.heroines.randomKeyDeath in
--  heroines_holdfast.lua. All 6 variants have real captured positions (Lilisette floor Rooms 1-3),
--  pulled from the Siknawz npclogger table. Rooms 2-4 also each have 3 real trash mobs now wired
--  (mob_spawn_points 17093259/260/265, 268/273/275, 282/283/285); Room 1's trash decade
--  (17093236-17093245) never appeared in the available capture and is still unwired.
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local CANDIDATES = { 17093250, 17093251, 17093252, 17093253, 17093254, 17093255 }
-- Footsoldier,      Neckchopper,  Depredator,   Vindicator,   Liberator,    Partisan

function onMobDeath(mob, player, isKiller)
    tpz.heroines.randomKeyDeath(mob, "Lilisette_Key", CANDIDATES, 4)
end

