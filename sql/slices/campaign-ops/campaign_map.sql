--
-- Table structure for table `campaign_map`
-- id = region order in the 0x071 packet (0-25). nation = packet Owner value: 1 Sandoria,2 Bastok,3 Windurst,
-- 4 Orc,5 Quadav,6 Yagudo,7 Dark Kindred. Seeded from a retail 0x071 snapshot; zoneid/id pairing from LSB.
--

DROP TABLE IF EXISTS `campaign_map`;
CREATE TABLE `campaign_map` (
  `id` tinyint(2) unsigned NOT NULL,
  `zoneid` smallint(3) unsigned NOT NULL DEFAULT 0,
  `isbattle` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `nation` tinyint(2) unsigned NOT NULL DEFAULT 4,
  `heroism` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `influence_sandoria` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `influence_bastok` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `influence_windurst` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `influence_beastman` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `current_fortifications` smallint(4) unsigned NOT NULL DEFAULT 0,
  `current_resources` smallint(4) unsigned NOT NULL DEFAULT 0,
  `max_fortifications` smallint(4) unsigned NOT NULL DEFAULT 0,
  `max_resources` smallint(4) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `campaign_map` VALUES (0,80,0,1,0,250,0,0,0,292,272,300,292);
INSERT INTO `campaign_map` VALUES (1,81,0,1,200,10,0,1,243,147,146,152,150);
INSERT INTO `campaign_map` VALUES (2,82,0,4,200,3,0,0,250,141,150,150,150);
INSERT INTO `campaign_map` VALUES (3,83,0,1,200,0,0,0,250,126,137,145,143);
INSERT INTO `campaign_map` VALUES (4,84,0,4,200,7,0,0,250,150,119,150,126);
INSERT INTO `campaign_map` VALUES (5,85,0,4,0,0,0,0,250,300,180,300,199);
INSERT INTO `campaign_map` VALUES (6,175,0,4,200,11,0,0,250,150,134,150,150);
INSERT INTO `campaign_map` VALUES (7,87,0,2,0,0,250,0,31,270,265,300,300);
INSERT INTO `campaign_map` VALUES (8,88,0,5,200,0,0,0,250,150,122,150,142);
INSERT INTO `campaign_map` VALUES (9,89,0,2,200,0,46,0,242,136,138,140,138);
INSERT INTO `campaign_map` VALUES (10,90,0,5,200,0,0,0,250,150,140,150,150);
INSERT INTO `campaign_map` VALUES (11,91,0,2,200,0,25,0,238,150,116,150,136);
INSERT INTO `campaign_map` VALUES (12,92,0,5,0,0,0,0,250,300,212,300,257);
INSERT INTO `campaign_map` VALUES (13,171,0,5,200,0,209,0,200,150,127,150,150);
INSERT INTO `campaign_map` VALUES (14,94,0,3,0,0,0,250,0,300,274,300,300);
INSERT INTO `campaign_map` VALUES (15,95,0,3,200,0,0,250,0,153,145,153,150);
INSERT INTO `campaign_map` VALUES (16,96,0,3,200,0,0,248,180,150,124,150,150);
INSERT INTO `campaign_map` VALUES (17,97,0,3,200,0,0,219,203,150,53,150,150);
INSERT INTO `campaign_map` VALUES (18,98,0,3,200,0,0,38,226,145,1,150,142);
INSERT INTO `campaign_map` VALUES (19,99,0,6,200,0,0,0,250,300,145,300,172);
INSERT INTO `campaign_map` VALUES (20,164,0,3,200,0,0,0,250,33,0,100,100);
INSERT INTO `campaign_map` VALUES (21,136,0,7,200,0,0,0,250,200,138,200,165);
INSERT INTO `campaign_map` VALUES (22,137,0,7,187,0,0,0,250,200,120,200,142);
INSERT INTO `campaign_map` VALUES (23,138,0,7,200,0,0,0,250,250,250,250,250);
INSERT INTO `campaign_map` VALUES (24,155,0,7,195,0,0,0,250,250,250,250,250);
INSERT INTO `campaign_map` VALUES (25,156,0,7,0,0,0,0,250,1000,1000,1000,1000);
