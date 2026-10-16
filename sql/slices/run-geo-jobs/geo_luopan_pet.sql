-- GEO Luopan pet. Model bytes copied from LSB mob_pools 6040 (unverified on a DSP client).
-- familyid 700 and poolid 7000 are unused in DSP; pet_list id 75 matches PETID_LUOPAN.
REPLACE INTO `mob_family_system` VALUES (700,'Luopan',18,'Unclassified',1,0,100,100,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0);
REPLACE INTO `mob_pools` VALUES (7000,'Luopan','Luopan',700,0x0000280B00000000000000000000000000000000,21,21,3,240,100,0,0,0,0,0,0,0,0,131,0,0,0,16,0,0);
REPLACE INTO `pet_list` VALUES (75,'Luopan',7000,1,99,0,0);
