-- salvage-zhayolm: Armoury Crate is id 17076579 in the build; DSP base had it at 17076584.
DELETE FROM `npc_list` WHERE `npcid` IN (17076584,17076579);
INSERT INTO `npc_list` (`npcid`,`name`,`polutils_name`,`pos_rot`,`pos_x`,`pos_y`,`pos_z`,`flag`,`speed`,`speedsub`,`animation`,`animationsub`,`namevis`,`status`,`entityFlags`,`look`,`name_prefix`,`content_tag`,`widescan`) VALUES (17076579,'Armoury_Crate','Armoury Crate',64,340.0,-8.5,-460.0,7,50,50,0,8,0,0,131,0x0000c10300000000000000000000000000000000,0,'TOAU',1);
