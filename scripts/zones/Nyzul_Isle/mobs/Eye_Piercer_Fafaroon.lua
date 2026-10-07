-----------------------------------
-- Area: Nyzul Isle
--  Mob: Eye Piercer Fafaroon (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Qiqirn family -- BG Wiki: "Uses Eagle Eye
-- Shot twice in a row." NOT built: no confirmed real id exists for a Qiqirn-family Eagle Eye Shot.
-- Checked both real mechanisms this codebase uses for Eagle Eye Shot:
--   1) mob_skills.sql TP-move id -- grepped ~20 real 'eagle_eye_shot' rows (413/711/712/735-739/
--      1019/1065/1091/1121/1122/1151/1153/1327/1389/1557/1641/1931/1932/2148/2252/2941); none of
--      them are attached to skill list 199 (Qiqirn) in sql/mob_skill_lists.sql.

--   2) tpz.jsa job-special mixin (scripts/globals/status.lua EES_* enum, the mechanism Item 1's
--      Stheno used via EES_LAMIA) -- only EES_GOBLIN/EES_ANTICA/EES_ORC/EES_SHADE/EES_GIGA/
--      EES_MAAT/EES_YAGUDO/EES_QUADAV/EES_KINDRED/EES_AERN/EES_LAMIA are defined; no EES_QIQIRN
--      entry exists.
-- Inventing either a new mob_skill_id/skill-list membership or a new EES_QIQIRN status id would
-- violate the project's never-fabricate-ids rule. Flagged and left unbuilt -- ships as a plain
-- reskin pending a real confirmed id.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

