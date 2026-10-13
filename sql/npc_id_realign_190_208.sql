-- Realign the DSP npc ids in Quicksand Caves (208) and King Ranperre's Tomb (190) with the client's entity ids.
-- Every row below sits at a uniform offset from the client's id for the same-named entity (verified by name against the
-- client entity table), which is why door/NPC names and targeting were wrong and why casket slots were blocked there.
-- Zone.lua / mob scripts / treasure_spawn_points were updated to the new ids in the same slice.
-- One-time and guarded: re-running does nothing. Run this BEFORE sql/treasure_caskets.sql.
SET @g208 := (SELECT `name` FROM `npc_list` WHERE `npcid`=17629685);
SET @g190 := (SELECT `name` FROM `npc_list` WHERE `npcid`=17555924);

-- Quicksand Caves: +9 for 17629685..17629778
UPDATE `npc_list` SET `npcid`=`npcid`+9 WHERE `npcid` BETWEEN 17629685 AND 17629778 AND @g208='_5s0' ORDER BY `npcid` DESC;
UPDATE `treasure_spawn_points` SET `npcid`=17629748 WHERE `npcid`=17629739 AND @g208='_5s0';

-- King Ranperre's Tomb: +60 for 17555924..17555977 (the 4 Treasure_Casket rows above that range are already correct)
UPDATE `npc_list` SET `npcid`=`npcid`+60 WHERE `npcid` BETWEEN 17555924 AND 17555977 AND @g190='Unity_Master' ORDER BY `npcid` DESC;
UPDATE `treasure_spawn_points` SET `npcid`=17556015 WHERE `npcid`=17555955 AND @g190='Unity_Master';
