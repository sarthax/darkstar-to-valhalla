-----------------------------------
-- Area: Nyzul Isle
--  Mob: Mad Miner Boboroon (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Qiqirn family -- BG Wiki: "Periodically
-- drops a Qiqirn Mine." Checked both real 'qiqirn_mine' references in this codebase:
--   1) sql/mob_skills.sql -- no 'qiqirn_mine' TP-move row exists at all; the one grep hit is a
--      comment pointing at a Lua file, not a skills-table entry.
--   2) scripts/zones/*/mobs/Qiqirn_Mine.lua (Lebros_Cavern, Arrapago_Remnants, TH_ variant) -- a
--      real, but structurally unrelated, mechanic: a separately-spawned mob entity driven by
--      PlayerID/RockID localvars set by an external player-trades-rock-to-NPC trigger, used for
--      Excavation Duty's wall-destruction puzzle. It is not a TP move a leader NM can "use"/"drop"
--      on its own turn, and reusing it here would require inventing a trigger condition ("mine
--      periodically appears near the leader") the wiki doesn't specify and no other script in this
--      family establishes.
-- Left unbuilt and flagged rather than fabricating a periodic-drop mechanic from scratch. Ships as
-- a plain reskin (standard Qiqirn TP moves from the base skill list, unmodified).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

