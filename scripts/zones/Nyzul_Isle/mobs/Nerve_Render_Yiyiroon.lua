-----------------------------------
-- Area: Nyzul Isle
--  Mob: Nerve Render Yiyiroon (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Qiqirn family -- BG Wiki: "Uses Faze on
-- multiple targets." Real mob_skill_id 1728 ('faze', animation 1203) is confirmed enabled in the
-- base Qiqirn skill list (199) via sql/mob_skill_lists.sql -- already a real, standard TP move for
-- this family, no force-fire scripting needed; the engine's normal AI already includes it. Ships as
-- a plain reskin (standard Qiqirn skill-list behavior, unmodified).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

