-- homepoint-audit-fixes: import into the DSP `npc_list` table (idempotent).
-- Uleguerand_Range (zone 5): HomePoint#1-5 were never loaded (commented NC placeholders at 0,0,0).
-- Ids follow this tree's zone layout (LSB id - 1), positions/rot from LSB retail-derived rows.
DELETE FROM `npc_list` WHERE `npcid`=16798151;
INSERT INTO `npc_list` VALUES (16798151,'HomePoint#1','Home Point #1',0,65.000,-196.500,181.000,1,50,50,0,0,0,0,3,0x0000330000000000000000000000000000000000,0,'SOA',0);
DELETE FROM `npc_list` WHERE `npcid`=16798152;
INSERT INTO `npc_list` VALUES (16798152,'HomePoint#2','Home Point #2',128,379.000,23.000,-62.600,1,50,50,0,0,0,0,3,0x0000330000000000000000000000000000000000,0,'SOA',0);
DELETE FROM `npc_list` WHERE `npcid`=16798153;
INSERT INTO `npc_list` VALUES (16798153,'HomePoint#3','Home Point #3',64,424.000,-32.500,220.000,1,50,50,0,0,0,0,3,0x0000330000000000000000000000000000000000,0,'SOA',0);
DELETE FROM `npc_list` WHERE `npcid`=16798154;
INSERT INTO `npc_list` VALUES (16798154,'HomePoint#4','Home Point #4',64,64.000,-96.500,460.000,1,50,50,0,0,0,0,3,0x0000330000000000000000000000000000000000,0,'SOA',0);
DELETE FROM `npc_list` WHERE `npcid`=16798155;
INSERT INTO `npc_list` VALUES (16798155,'HomePoint#5','Home Point #5',0,-219.000,-1.000,-62.000,1,50,50,0,0,0,0,3,0x0000330000000000000000000000000000000000,0,'SOA',0);
