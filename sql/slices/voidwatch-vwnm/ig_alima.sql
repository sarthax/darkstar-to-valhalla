-- Ig-Alima (Jeuno Stage VI / White VI, Valkurm Dunes z103). Client ids [V]; npc_list already matches.
-- Rifts 17199764-66, Pyxis 17199767-69, mobs 17199612-14 (group 13766, pool 4693). Rift positions [V entities.yml].
DELETE FROM mob_spawn_points WHERE mobid IN (17199612,17199613,17199614);
INSERT INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17199612,'Ig-Alima','Ig-Alima',13766,720,-8.078,195,0),
 (17199613,'Ig-Alima','Ig-Alima',13766,650,0.293,0.001,0),
 (17199614,'Ig-Alima','Ig-Alima',13766,-75,-0.312,-45,0);
-- HP ~161800 [C: hptrack 161624-161973]
UPDATE mob_groups SET HP=161800, respawntime=0 WHERE groupid=13766 AND zoneid=103;
-- Skills 2784-2790 rows already exist (anim 1956-1962). Melee variants 2781-2783 not built.
DELETE FROM mob_skill_lists WHERE skill_list_id=1167;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Ig-Alima',1167,2784),('Ig-Alima',1167,2785),('Ig-Alima',1167,2786),('Ig-Alima',1167,2787),('Ig-Alima',1167,2788),('Ig-Alima',1167,2789),('Ig-Alima',1167,2790);
-- Spikes: Blaze 249 [C], Ice 250 / Shock 251 [D standard ids]
DELETE FROM mob_spell_lists WHERE spell_list_id=450;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES ('Ig-Alima',450,249,1,99),('Ig-Alima',450,250,1,99),('Ig-Alima',450,251,1,99);
UPDATE mob_pools SET skill_list_id=1167, spellList=450, hasSpellScript=1 WHERE poolid=4693;
