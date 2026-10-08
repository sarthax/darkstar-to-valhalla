-- Murk-veined Baneberry (Indigo III, Pashhow Marshlands zone 109). Rifts 17224371-73, Pyxis 17224374-76 (AFTER rekey_109.sql, +2), mobs 17224185-87 (group 14089, pool 5312).
-- Pool/group existed from LSB with a misspelled name -> renamed. Capture HP ~47988 [C hptrack]. Level kept at LSB 92-94.
-- Skills [C]: Words of Bane 783, Everyone's Rancor 921 (rows + Lua already in DSP). Spells [C]: Blizzaga III 181, Stonega IV 192, Firaga IV 177.
-- Pool is already BLM/THF (LSB).
UPDATE mob_pools SET name='Murk-veined_Baneberry', packet_name='Murk-veined_Baneberry', hasSpellScript=1, spellList=457, skill_list_id=1182 WHERE poolid=5312;
UPDATE mob_groups SET HP=47988, MP=9999, respawntime=0, dropid=0 WHERE groupid=14089;
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17224185,'Murk-veined_Baneberry','Murk-veined Baneberry',14089,-420.0,24.14,-230.0,240),
 (17224186,'Murk-veined_Baneberry','Murk-veined Baneberry',14089,250.0,24.2,92.0,0),
 (17224187,'Murk-veined_Baneberry','Murk-veined Baneberry',14089,552.0,24.5,492.0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1182;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Baneberry',1182,783),('Baneberry',1182,921);
DELETE FROM mob_spell_lists WHERE spell_list_id=457;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Baneberry',457,181,1,99),('Baneberry',457,192,1,99),('Baneberry',457,177,1,99);
