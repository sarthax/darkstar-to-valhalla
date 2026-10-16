-- Voidwalker per-NM skill lists (docs/voidwalker/SKILL-GATING-ANALYSIS.md). Only reuses existing mob_skills rows that have Lua.
-- 9003 Krabkatoa: Mega Scissors replaces Big Scissors, adds Venom Shower. 9004 Lamprey Lord: Acid Mist only.
-- 9005 Chesma: adds Charged Whisker. 9006 Farruca Fly: adds Somersault.
DELETE FROM `mob_skill_lists` WHERE skill_list_id IN (9003,9004,9005,9006);
INSERT INTO `mob_skill_lists` VALUES ('Krabkatoa',9003,442),('Krabkatoa',9003,443),('Krabkatoa',9003,2513),('Krabkatoa',9003,445),('Krabkatoa',9003,448),('Krabkatoa',9003,2512);
INSERT INTO `mob_skill_lists` VALUES ('Lamprey_Lord',9004,415);
INSERT INTO `mob_skill_lists` VALUES ('Chesma',9005,652),('Chesma',9005,653),('Chesma',9005,3416);
INSERT INTO `mob_skill_lists` VALUES ('Farruca_Fly',9006,659),('Farruca_Fly',9006,660),('Farruca_Fly',9006,318);
UPDATE `mob_pools` SET skill_list_id=9003 WHERE poolid=7112;
UPDATE `mob_pools` SET skill_list_id=9004 WHERE poolid=7113;
UPDATE `mob_pools` SET skill_list_id=9005 WHERE poolid=7102;
UPDATE `mob_pools` SET skill_list_id=9006 WHERE poolid=7105;
-- 9007 Verthandi: stock list 195 plus Norn Arrows (2518, Lua norn_arrows.lua).
DELETE FROM `mob_skill_lists` WHERE skill_list_id=9007;
INSERT INTO `mob_skill_lists` VALUES ('Verthandi',9007,2193),('Verthandi',9007,2194),('Verthandi',9007,2195),('Verthandi',9007,2196),('Verthandi',9007,2197),('Verthandi',9007,2198),('Verthandi',9007,2199),('Verthandi',9007,2200),('Verthandi',9007,2518);
UPDATE `mob_pools` SET skill_list_id=9007 WHERE poolid=7135;
