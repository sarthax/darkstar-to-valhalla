-- Botulus Rex (Jeuno Stage VI / White VI, Buburimu Peninsula z118). Client ids (see rekey_118.sql) [V].
-- Rifts 17261219-21, Pyxis 17261222-24, mobs 17261047-49 (group 13731, pool 4734). Positions [C].
DELETE FROM mob_spawn_points WHERE mobid IN (17261047,17261048,17261049);
INSERT INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17261047,'Botulus_Rex','Botulus Rex',13731,80,0.049,-195,0),
 (17261048,'Botulus_Rex','Botulus Rex',13731,360,0.001,-240,0),
 (17261049,'Botulus_Rex','Botulus Rex',13731,-360,-8,-200,0);
-- HP ~145000 [C: hptrack 142648-145430]
UPDATE mob_groups SET HP=145000, respawntime=0 WHERE groupid=13731 AND zoneid=118;
-- Skills [C: Siknoz capture anim ids]: Gnash 'n Guttle 2798, Sloughy Sputum 2799, Rancid Reflux 2801, Crowning Flatus 2802
DELETE FROM mob_skills WHERE mob_skill_id IN (2798,2799,2801,2802);
INSERT INTO mob_skills VALUES
 (2798,1968,'gnash_n_guttle',0,7.0,2000,1500,4,0,0,0,0,0,0),
 (2799,1969,'sloughy_sputum',4,10.0,2000,1500,4,0,0,0,0,0,0),
 (2801,1971,'rancid_reflux',4,10.0,2000,1500,4,0,0,0,0,0,0),
 (2802,1972,'crowning_flatus',1,15.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1166;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Botulus_Rex',1166,2798),('Botulus_Rex',1166,2799),('Botulus_Rex',1166,2801),('Botulus_Rex',1166,2802);
-- Spells [C]: Aeroja 498, Waterja 501, Blizzaja 497, Meteor 218 seen; Firaja 496/Stonja 499/Thundaja 500 inferred [D]
DELETE FROM mob_spell_lists WHERE spell_list_id=449;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Botulus_Rex',449,496,1,99),('Botulus_Rex',449,497,1,99),('Botulus_Rex',449,498,1,99),('Botulus_Rex',449,499,1,99),
 ('Botulus_Rex',449,500,1,99),('Botulus_Rex',449,501,1,99),('Botulus_Rex',449,218,1,99);
UPDATE mob_pools SET skill_list_id=1166, spellList=449, hasSpellScript=1 WHERE poolid=4734;
