-- modid 23 = MOBMOD_IMMUNITY (value 8 = stun), 3 = MP base; same enum in DSP mob_modifier.h
INSERT INTO `mob_pool_mods` VALUES (7030,23,8,1);
INSERT INTO `mob_pool_mods` VALUES (7031,23,8,1);
INSERT INTO `mob_pool_mods` VALUES (7032,23,8,1);
INSERT INTO `mob_pool_mods` VALUES (7035,23,8,1);
INSERT INTO `mob_pool_mods` VALUES (7036,3,100,1);
INSERT INTO `mob_pool_mods` VALUES (7036,23,8,1);
-- Pyracmon (WAR/WAR, spellList 11) has 0 MP in DSP without an MP base -> 'tried to cast magic with no mp'
DELETE FROM `mob_pool_mods` WHERE poolid=3241 AND modid=3;
INSERT INTO `mob_pool_mods` VALUES (3241,3,100,1);
