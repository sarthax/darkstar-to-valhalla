-- Lancing Lamorak (Jeuno Stage IV / White IV, West Ronfaure z100). Client ids (see rekey_100.sql) [V].
-- Rifts 17187587-89, Pyxis 590-92, mobs 17187289-91 (group 13807, pool 5166). Positions = rift positions [C].
DELETE FROM mob_spawn_points WHERE mobid IN (17187289,17187290,17187291);
INSERT INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17187289,'Lancing_Lamorak','Lancing Lamorak',13807,-360,-50.5,270,0),
 (17187290,'Lancing_Lamorak','Lancing Lamorak',13807,-320,-10,-360,0),
 (17187291,'Lancing_Lamorak','Lancing Lamorak',13807,-340,-29.751,-40,0);
-- HP ~106500 [C: hptrack 105595-107347]
UPDATE mob_groups SET HP=106500, respawntime=0 WHERE groupid=13807 AND zoneid=100;
-- Rhinowrecker [C: anim 1986]; Rhino Attack 340 / Power Attack 338 reuse existing rows
DELETE FROM mob_skills WHERE mob_skill_id=2823;
INSERT INTO mob_skills VALUES (2823,1986,'rhinowrecker',4,10.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1169;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Lancing_Lamorak',1169,338),('Lancing_Lamorak',1169,340),('Lancing_Lamorak',1169,2823);
-- Spells [F]: Aero V 158, Aeroga IV 187, Aeroja 498, Silencega 359
DELETE FROM mob_spell_lists WHERE spell_list_id=452;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Lancing_Lamorak',452,158,1,99),('Lancing_Lamorak',452,187,1,99),('Lancing_Lamorak',452,498,1,99),('Lancing_Lamorak',452,359,1,99);
UPDATE mob_pools SET skill_list_id=1169, spellList=452, hasSpellScript=1 WHERE poolid=5166;
