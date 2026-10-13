-- Celaeno (Indigo IV, Dangruf Wadi zone 191). Rifts 17559929-31, Pyxis 17559932-34, mobs 17559871-73: ids == client [V/C].
-- NEW pool 6890 + group 18228 (nothing existed). Pool row from LSB pool 6890 (family 184, BLM/BLM). Capture HP 63664 [C hptrack]. Level 95-96 [D].
-- Skills [C]: Rending Talons 2725, Shrieking Gale 2726, Wings of Woe 2727 (effect unknown, stub), Wings of Agony 2728, Typhoean Rage 2729.
-- Unnamed LSB ids 2722-2724 NOT modelled. Spells [C]: Aeroja 498, Graviga 366, Aeroga IV 187, Slowga 357, Silencega 359.
DELETE FROM mob_pools WHERE poolid=6890;
INSERT INTO mob_pools VALUES (6890,'Celaeno','Celaeno',184,0x00003E0800000000000000000000000000000000,4,4,6,240,100,0,1,0,0,2,0,0,7,671,8,1,458,1,0,1183);
DELETE FROM mob_groups WHERE groupid=18228;
INSERT INTO mob_groups VALUES (18228,6890,191,0,128,0,63664,9999,95,96,0);
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17559871,'Celaeno','Celaeno',18228,-253.0,4.033,505.0,0),
 (17559872,'Celaeno','Celaeno',18228,-107.0,4.055,187.0,0),
 (17559873,'Celaeno','Celaeno',18228,-157.0,3.972,-164.0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1183;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES
 ('Celaeno',1183,2725),('Celaeno',1183,2726),('Celaeno',1183,2727),('Celaeno',1183,2728),('Celaeno',1183,2729);
DELETE FROM mob_spell_lists WHERE spell_list_id=458;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Celaeno',458,498,1,99),('Celaeno',458,366,1,99),('Celaeno',458,187,1,99),('Celaeno',458,357,1,99),('Celaeno',458,359,1,99);
