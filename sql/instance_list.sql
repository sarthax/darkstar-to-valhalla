-- MySQL dump 10.13  Distrib 5.6.15, for Win64 (x86_64)
--
-- Host: localhost    Database: dspdb
-- ------------------------------------------------------
-- Server version	5.6.15

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `instance_list`
--

DROP TABLE IF EXISTS `instance_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_list` (
  `instanceid` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `instance_name` varchar(35) NOT NULL DEFAULT '',
  `entrance_zone` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `time_limit` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `start_x` float(7,3) NOT NULL DEFAULT '0.000',
  `start_y` float(7,3) NOT NULL DEFAULT '0.000',
  `start_z` float(7,3) NOT NULL DEFAULT '0.000',
  `start_rot` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `music_day` smallint(3) NOT NULL DEFAULT '-1',
  `music_night` smallint(3) NOT NULL DEFAULT '-1',
  `battlesolo` smallint(3) NOT NULL DEFAULT '-1',
  `battlemulti` smallint(3) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`instanceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instance_list`
--

LOCK TABLES `instance_list` WRITE;
/*!40000 ALTER TABLE `instance_list` DISABLE KEYS */;
INSERT INTO `instance_list` VALUES (0,'TEST',0,0,0.000,0.000,0.000,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (53,'the_black_coffin',54,30,0,-22,24,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (58,'path_of_darkness',72,30,500,0,-572,192,143,143,143,143);
INSERT INTO `instance_list` VALUES (59,'nashmeira\'s_plea',72,45,-444,-4,420,127,143,143,143,143);
INSERT INTO `instance_list` VALUES (79,'shades_of_vengeance',79,30,127,-15,-303,0,-1,-1,-1,-1);
/*!40000 ALTER TABLE `instance_list` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-28 15:42:27

-- Merged from C:	opaz\sql\instance_list.sql (2026-09-14) -- real Assault/Nyzul instance metadata
-- (name/entrance_zone/time_limit/start pos/rotation/music), never extracted into any
-- mission-packages sql/ folder before this. Topaz's own extra `zoneid` column dropped
-- (not present in this codebase's real instance_list schema -- confirmed via this
-- file's own CREATE TABLE statement).
INSERT INTO `instance_list` VALUES (1,'leujaoam_cleansing',79,30,280.000,-7.500,35.000,195,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (2,'orichalcum_survey',79,30,-432.000,-27.627,169.000,129,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (3,'escort_professor_chanoix',79,30,-218.000,-3.415,-95.000,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (4,'shanarha_grass_conservation',79,30,258.776,-3.500,-239.379,4,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (5,'counting_sheep',79,15,-59.543,-3.500,197.311,193,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (6,'supplies_recovery',79,30,182.691,-3.364,141.424,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (7,'azure_experiments',79,30,82.787,-3.086,323.746,145,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (8,'imperial_code',79,30,-320.000,-4.000,-440.700,142,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (9,'red_versus_blue',79,30,19.990,-7.500,-363.797,172,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (10,'bloody_rondo',79,30,424.000,4.683,-341.000,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (11,'imperial_agent_rescue',52,30,-20.000,2.276,-405.000,63,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (12,'preemptive_strike',52,30,-75.000,-3.300,20.000,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (13,'sagelord_elimination',52,30,-300.000,-3.300,115.000,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (14,'breaking_morale',52,15,19.000,2.026,-136.000,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (15,'the_double_agent',52,30,-327.199,-4.748,-406.599,96,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (16,'imperial_treasure_retrieval',52,15,289.705,2.306,-419.980,129,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (17,'blitzkrieg',52,30,-99.688,-3.853,59.220,188,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (18,'marids_in_the_mist',52,30,339.000,14.632,98.000,192,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (19,'azure_ailments',52,30,-177.192,-0.201,200.204,69,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (20,'the_susanoo_shuffle',52,30,-503.000,1.783,-54.000,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (21,'excavation_duty',61,30,124.999,-39.309,19.999,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (22,'lebros_supplies',61,30,-333.000,-9.921,-259.999,128,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (23,'troll_fugitives',61,30,-459.912,-9.860,342.319,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (24,'evade_and_escape',61,30,302.000,-29.399,192.000,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (25,'siegemaster_assassination',61,30,0.000,-50.000,-319.999,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (26,'apkallu_breeding',61,15,86.852,-29.464,256.080,22,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (27,'wamoura_farm_raid',61,30,540.977,-39.976,220.919,128,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (28,'egg_conservation',61,30,-140.540,-9.627,468.960,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (29,'operation:black_pearl',61,30,157.823,-40.000,324.153,66,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (30,'better_than_one',61,30,420.000,0.018,-460.000,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (31,'seagull_grounded',79,30,-350,-15.245,380,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (32,'requiem',79,30,-470.000,-9.694,-325.000,192,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (33,'saving_private_ryaaf',79,30,20.000,-15.644,548.000,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (34,'shooting_down_the_baron',79,15,-143.905,-15.257,-65.603,138,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (35,'building_bridges',79,15,-347.170,-15.283,379.983,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (36,'stop_the_bloodshed',79,30,-222.000,-15.207,-60.000,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (37,'defuse_the_threat',79,30,-99.999,-15.251,-219.999,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (38,'operation:snake_eyes',79,30,-300.791,-15.341,93.644,204,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (39,'wake_the_puppet',79,30,-59.506,-15.303,427.706,78,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (40,'the_price_is_right',79,30,380.000,0.717,144.000,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (41,'golden_salvage',54,30,386.000,-12.000,17.000,46,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (42,'lamia_no_13',54,30,155.000,-7.000,-175.000,47,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (43,'extermination',54,30,298.099,-3.943,135.234,64,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (44,'demolition_duty',54,30,368.200,-7.194,-464.499,16,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (45,'searat_salvation',54,15,-511.057,-4.327,24.332,208,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (46,'apkallu_seizure',54,30,-609.629,-3.768,-369.272,39,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (47,'lost_and_found',54,30,-191.388,-7.000,-371.895,144,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (48,'deserter',54,30,153.250,-7.000,-585.750,224,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (49,'desperately_seeking_cephalopods',54,30,-20.621,-7.589,250.441,30,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (50,'bellerophons_bliss',54,30,-464.000,0.717,-540.000,0,-1,-1,-1,-1);
INSERT INTO `instance_list` VALUES (51,'nyzul_isle_investigation',72,30,-20.172,-4.000,-19.928,193,-1,-1,-1,-1);

-- Merged remainder of C:	opaz\sql\instance_list.sql (2026-09-14, per user direction: bring over the whole table) -- zoneid column dropped, same as above

-- Nyzul 52 (Uncharted Area Survey) backport import, applied 2026-10-03
-- Nyzul 52
INSERT IGNORE INTO `instance_list` VALUES (52,'nyzul_isle_uncharted_area_survey',72,30,-20.172,-4.000,-19.928,193,-1,-1,-1,-1);

-- HEROINES HOLDFAST BACKPORT (instance 80) 2026-10-03
-- Holdfast
INSERT IGNORE INTO `instance_list` VALUES (80,'heroines_holdfast',72,15,460.000,0.000,-610.000,59,-1,-1,-1,-1);
