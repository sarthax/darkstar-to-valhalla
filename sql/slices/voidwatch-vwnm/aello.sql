-- Aello (Ru'Aun Gardens, groups 13737/13738, pools 4720/4721). Spawn at rift positions [C: Wiggo capture, Aello spawns exactly on rift]; rift1/2 rot are [D].
-- Handmaiden offsets from Aello are [C]. Run !checknav on these before relying on them.
REPLACE INTO `mob_spawn_points` VALUES (17309985,'Aello','Aello',13737,377.0,-40.0,246.0,20);
REPLACE INTO `mob_spawn_points` VALUES (17309986,'Aellos_Handmaiden','Aello''s Handmaiden',13738,377.805,-40.0,246.113,4);
REPLACE INTO `mob_spawn_points` VALUES (17309987,'Aellos_Handmaiden','Aello''s Handmaiden',13738,377.807,-40.0,246.126,3);
REPLACE INTO `mob_spawn_points` VALUES (17309988,'Aellos_Handmaiden','Aello''s Handmaiden',13738,378.277,-40.0,246.438,2);
REPLACE INTO `mob_spawn_points` VALUES (17309989,'Aello','Aello',13737,-117.0,-40.0,436.0,20);
REPLACE INTO `mob_spawn_points` VALUES (17309990,'Aellos_Handmaiden','Aello''s Handmaiden',13738,-116.195,-40.0,436.113,4);
REPLACE INTO `mob_spawn_points` VALUES (17309991,'Aellos_Handmaiden','Aello''s Handmaiden',13738,-116.193,-40.0,436.126,3);
REPLACE INTO `mob_spawn_points` VALUES (17309992,'Aellos_Handmaiden','Aello''s Handmaiden',13738,-115.723,-40.0,436.438,2);
REPLACE INTO `mob_spawn_points` VALUES (17309993,'Aello','Aello',13737,94.0,-40.2,-459.0,20);
REPLACE INTO `mob_spawn_points` VALUES (17309994,'Aellos_Handmaiden','Aello''s Handmaiden',13738,94.805,-40.2,-458.887,4);
REPLACE INTO `mob_spawn_points` VALUES (17309995,'Aellos_Handmaiden','Aello''s Handmaiden',13738,94.807,-40.2,-458.874,3);
REPLACE INTO `mob_spawn_points` VALUES (17309996,'Aellos_Handmaiden','Aello''s Handmaiden',13738,95.277,-40.2,-458.562,2);
-- Spells [C]: Aello 148,177,252,286,357,496; handmaiden 21,129,134,157,186,356,359. Lists 441/442 unused (max was 440).
DELETE FROM mob_spell_lists WHERE spell_list_id IN (441,442);
INSERT INTO mob_spell_lists (spell_list_name, spell_list_id, spell_id, min_level, max_level) VALUES
('Aello',441,148,1,255),
('Aello',441,177,1,255),
('Aello',441,252,1,255),
('Aello',441,286,1,255),
('Aello',441,357,1,255),
('Aello',441,496,1,255),
('Aellos_Handmaiden',442,21,1,255),
('Aellos_Handmaiden',442,129,1,255),
('Aellos_Handmaiden',442,134,1,255),
('Aellos_Handmaiden',442,157,1,255),
('Aellos_Handmaiden',442,186,1,255),
('Aellos_Handmaiden',442,356,1,255),
('Aellos_Handmaiden',442,359,1,255);
UPDATE mob_pools SET spellList = 441 WHERE poolid = 4720;
UPDATE mob_pools SET spellList = 442 WHERE poolid = 4721;
-- Skills: drop never-seen wings_of_woe/ravenous_wail; add kaleidoscopic_fury (2758, anim 1932) [C].
DELETE FROM mob_skill_lists WHERE skill_list_id = 471 AND mob_skill_id IN (2727,2730);
DELETE FROM mob_skills WHERE mob_skill_id = 2758;
INSERT INTO mob_skills SELECT 2758, 1932, 'kaleidoscopic_fury', mob_skill_aoe, mob_skill_distance, mob_anim_time, mob_prepare_time, mob_valid_targets, mob_skill_flag, mob_skill_param, knockback, primary_sc, secondary_sc, tertiary_sc FROM mob_skills WHERE mob_skill_id = 2729;
DELETE FROM mob_skill_lists WHERE skill_list_id = 471 AND mob_skill_id = 2758;
INSERT INTO mob_skill_lists (skill_list_name, skill_list_id, mob_skill_id) VALUES ('Harpeia', 471, 2758);
