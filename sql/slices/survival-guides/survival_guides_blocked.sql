-- BLOCKED: client DAT slot is a Survival Guide, but npc_list holds another npc there (after npc-id-realign).
-- Move the occupant to a free/correct slot first, then run the INSERT. Not applied by survival_guides_apply.sql.
-- occupant: blank
INSERT INTO `npc_list` VALUES (17142635,'Survival_Guide','Survival Guide',64,794.000,71.480,773.160,0,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,0,'WOTG',1);
-- occupant: Moogle
INSERT INTO `npc_list` VALUES (17187594,'Survival_Guide','Survival Guide',128,-452.571,-19.807,-217.970,10,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,0,NULL,1);
-- occupant: Kuchi_Eyjhann
INSERT INTO `npc_list` VALUES (17199773,'Survival_Guide','Survival Guide',160,137.000,-7.460,98.000,1,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,0,NULL,1);
-- occupant: blank
INSERT INTO `npc_list` VALUES (17203947,'Survival_Guide','Survival Guide',64,63.000,0.400,-14.000,25,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,0,NULL,1);
-- occupant: blank
INSERT INTO `npc_list` VALUES (17220214,'Survival_Guide','Survival Guide',32,-223.000,71.070,828.000,1,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,0,NULL,1);
-- occupant: Conquest_Banner
INSERT INTO `npc_list` VALUES (17248951,'Survival_Guide','Survival Guide',0,-13.322,-12.458,315.696,1,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,32,NULL,1);
-- occupant: Iroha
INSERT INTO `npc_list` VALUES (17257124,'Survival_Guide','Survival Guide',192,-160.000,47.250,647.110,1,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,0,NULL,1);
-- occupant: Siren
INSERT INTO `npc_list` VALUES (17281675,'Survival_Guide','Survival Guide',64,-240.000,0.000,-404.000,1,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,0,NULL,1);
-- occupant: Unity_Master
INSERT INTO `npc_list` VALUES (17563927,'Survival_Guide','Survival Guide',192,453.000,-8.000,182.300,1,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,0,NULL,1);
-- occupant: HazyRune
INSERT INTO `npc_list` VALUES (17568212,'Survival_Guide','Survival Guide',128,-104.000,-0.219,633.000,1,50,50,0,17,32,0,3,0x0000810900000000000000000000000000000000,0,NULL,1);
