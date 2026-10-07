--
-- Table structure for table `campaign_nation`
-- Seeded from a retail 0x071 snapshot (the packet previously hardcoded in campaing_map.cpp).
-- reconnaissance 0-10, morale/prosperity 0-100. id: 0 Sandoria,1 Bastok,2 Windurst,3 Orc,4 Quadav,5 Yagudo,6 Dark Kindred
--

DROP TABLE IF EXISTS `campaign_nation`;
CREATE TABLE `campaign_nation` (
  `id` tinyint(2) unsigned NOT NULL,
  `reconnaissance` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `morale` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `prosperity` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `campaign_nation` VALUES (0,10,5,2); -- Sandoria
INSERT INTO `campaign_nation` VALUES (1,10,10,4); -- Bastok
INSERT INTO `campaign_nation` VALUES (2,10,95,98); -- Windurst
INSERT INTO `campaign_nation` VALUES (3,10,100,100); -- Orc
INSERT INTO `campaign_nation` VALUES (4,10,96,99); -- Quadav
INSERT INTO `campaign_nation` VALUES (5,10,95,98); -- Yagudo
INSERT INTO `campaign_nation` VALUES (6,10,100,100); -- Dark Kindred
