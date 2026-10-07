-- Krabimanjaro boss moves. Rows/anim ids from LSB mob_skills (2512 venom_shower anim 1778, 2513 mega_scissors anim 1781);
-- DSP had these commented out with placeholder anim ids 2256/2257. Anim ids NOT yet verified against our client.
-- aoe: venom_shower 1 (AoE), mega_scissors 4 (conal). Pool 5168 repointed from generic Crab list 77 to new list 1159.
REPLACE INTO `mob_skills` VALUES (2512,1778,'venom_shower',1,12.0,2000,1500,4,0,0,0,0,0,0);
REPLACE INTO `mob_skills` VALUES (2513,1781,'mega_scissors',4,10.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM `mob_skill_lists` WHERE `skill_list_id`=1159;
INSERT INTO `mob_skill_lists` (`skill_list_name`,`skill_list_id`,`mob_skill_id`) VALUES
 ('Krabimanjaro',1159,442),('Krabimanjaro',1159,443),('Krabimanjaro',1159,444),
 ('Krabimanjaro',1159,445),('Krabimanjaro',1159,448),('Krabimanjaro',1159,2512),('Krabimanjaro',1159,2513);
UPDATE `mob_pools` SET `skill_list_id`=1159 WHERE `poolid`=5168;
-- Immunities (from Krabkatoa BG wiki; user confirmed shared by other high-level crab NMs):
-- Sleep 0x01 + Gravity 0x02 + Bind 0x04 + Paralyze 0x20 + Poison 0x100 = 295. Slow/Elegy/Blind stay susceptible (no bit set).
UPDATE `mob_pools` SET `immunity`=295 WHERE `poolid`=5168;
