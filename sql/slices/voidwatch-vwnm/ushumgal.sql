-- Ushumgal (Indigo I, North Gustaberg [S] zone 88). Rifts 17138606-08, Pyxis 17138609-11, mobs 17138408-10: ids == client [V/C].
-- NEW pool 6820 + group 18227 (nothing existed in DSP). Pool row from LSB pool 6820 (family 312, model, THF/THF; job is LSB-only, in-game unverified).
-- Capture: Raguza 2021.03.27 (hptrack HP 43455). Skills seen [C]: Torpefying Charge 2155, Oppressive Glare 2392 (effect unknown, stub).
-- LSB list 803 (7 skills) NOT used: only the two captured ones are modelled. No spells seen, no spell list.
DELETE FROM mob_pools WHERE poolid=6820;
INSERT INTO mob_pools VALUES (6820,'Ushumgal','Ushumgal',312,0x0000E00700000000000000000000000000000000,6,6,2,240,100,0,1,0,0,2,0,0,7,1183,4,0,0,1,0,1180);
DELETE FROM mob_groups WHERE groupid=18227;
INSERT INTO mob_groups VALUES (18227,6820,88,0,128,0,43455,0,95,95,0);
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17138408,'Ushumgal','Ushumgal',18227,798.0,0.001,440.0,0),
 (17138409,'Ushumgal','Ushumgal',18227,558.0,-10.0,603.0,0),
 (17138410,'Ushumgal','Ushumgal',18227,-322.0,40.0,-42.0,0);
DELETE FROM mob_skills WHERE mob_skill_id=2392;
INSERT INTO mob_skills VALUES (2392,1665,'oppressive_glare',0,7.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1180;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Ushumgal',1180,2155),('Ushumgal',1180,2392);
