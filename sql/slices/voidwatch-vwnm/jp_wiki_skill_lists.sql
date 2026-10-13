-- Skill lists corrected from wikiwiki.jp VW route pages [J] (shared stock lists gave these mobs skills they never use).
-- Aello's Handmaiden (pool Aello_Handmaiden, groups 13708/13738): Lethe Arrows only (stock list 195 is shared by 21 pixie pools).
DELETE FROM mob_skill_lists WHERE skill_list_id=1176;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Aello_Handmaiden',1176,2194);
UPDATE mob_pools SET skill_list_id=1176 WHERE name='Aello_Handmaiden';
-- Hraun Dragon (pool 5176): Voidsong, Petro Eyes, Body Slam, Flame Breath (stock list 87 is shared by 43 dragon pools).
DELETE FROM mob_skill_lists WHERE skill_list_id=1177;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Hraun_Dragon',1177,649),('Hraun_Dragon',1177,648),('Hraun_Dragon',1177,645),('Hraun_Dragon',1177,642);
UPDATE mob_pools SET skill_list_id=1177 WHERE poolid=5176;
-- Ildebrann: add Spike Flail (JP: used when the target is behind him; engine has no facing trigger, so it rolls like the rest) [J]
DELETE FROM mob_skill_lists WHERE skill_list_id=1168 AND mob_skill_id=1280;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Ildebrann',1168,1280);
