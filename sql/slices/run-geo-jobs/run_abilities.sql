-- Slice run-geo-jobs: RUN abilities (from LSB baf0b36e, id=LSB-16, radius column dropped).
-- NOT live until imported. message1/animation/recastId values UNVERIFIED against client 30170905_5 (see PLAN.md).
REPLACE INTO `abilities` VALUES (328,'swipe',22,25,4,90,241,110,0,0,2000,0,6,3,0,80,320,0,0,'SOA');
REPLACE INTO `abilities` VALUES (340,'elemental_sforzo',22,0,1,3600,0,0,0,302,2000,0,6,0,0,1800,7200,0,0,'SOA');
REPLACE INTO `abilities` VALUES (350,'vallation',22,10,1,180,23,668,366,0,2000,0,6,0,0,450,900,0,0,'SOA');
REPLACE INTO `abilities` VALUES (351,'swordplay',22,20,1,300,24,667,0,299,2000,0,6,0,0,160,320,0,0,'SOA');
REPLACE INTO `abilities` VALUES (352,'lunge',22,25,4,180,25,110,0,8,2000,0,6,3,0,0,0,1796,0,'SOA');
REPLACE INTO `abilities` VALUES (353,'pflug',22,40,1,180,59,671,369,1,2000,0,6,0,0,450,900,0,0,'SOA');
REPLACE INTO `abilities` VALUES (354,'embolden',22,60,1,600,72,100,0,300,2000,0,6,0,0,160,320,0,0,'SOA');
REPLACE INTO `abilities` VALUES (355,'valiance',22,50,1,300,113,668,0,2,2000,0,6,0,1,450,900,0,0,'SOA');
REPLACE INTO `abilities` VALUES (356,'gambit',22,70,4,300,116,672,0,4,2000,0,6,3,0,640,1280,1800,0,'SOA');
REPLACE INTO `abilities` VALUES (357,'liement',22,85,1,180,117,670,373,3,2000,0,6,0,0,450,900,0,0,'SOA');
REPLACE INTO `abilities` VALUES (358,'one_for_all',22,95,1,300,118,100,0,301,2000,0,6,0,1,160,320,0,0,'SOA');
REPLACE INTO `abilities` VALUES (359,'rayke',22,75,4,300,119,320,0,4,2000,0,6,3,0,640,1260,3458,1,'SOA');
REPLACE INTO `abilities` VALUES (360,'battuta',22,75,1,300,120,100,0,4,2000,0,6,0,0,450,900,3456,1,'SOA');
REPLACE INTO `abilities` VALUES (362,'odyllic_subterfuge',22,96,4,3600,131,0,0,277,2000,0,6,10,6,1,318,0,0,'SOA');
REPLACE INTO `abilities` VALUES (367,'vivacious_pulse',22,65,1,60,242,102,0,327,2000,0,6,0,0,0,0,0,0,'SOA');

-- Recast ids for pre-existing DSP rows (were 0, sharing Elemental Sforzo's 1-hour timer). Client/LSB values.
UPDATE `abilities` SET `recastId` = 92 WHERE `abilityId` = 341;
UPDATE `abilities` SET `recastTime` = 5, `recastId` = 10 WHERE `abilityId` BETWEEN 342 AND 349;
UPDATE `abilities` SET `recastId` = 142 WHERE `abilityId` = 363;
UPDATE `abilities` SET `recastId` = 143 WHERE `abilityId` = 364;
