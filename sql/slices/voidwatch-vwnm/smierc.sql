-- Smierc (Jeuno Stage V / White V, Tahrongi Canyon z117). DB npc ids already = client ids [V].
-- Rifts 17257088-90, Pyxis 91-93, mobs 17256919-21 (group 13730, pool 4735). Positions = rift positions [C].
DELETE FROM mob_spawn_points WHERE mobid IN (17256919,17256920,17256921);
INSERT INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17256919,'Smierc','Smierc',13730,205,15.746,-680,0),
 (17256920,'Smierc','Smierc',13730,200,-24,-160,0),
 (17256921,'Smierc','Smierc',13730,360,24,280,0);
-- HP ~142000 [C: hptrack 141268-142975]
UPDATE mob_groups SET HP=142000, respawntime=0 WHERE groupid=13730 AND zoneid=117;
-- Cloudscourge [C: id 2824, anim 1993]
DELETE FROM mob_skills WHERE mob_skill_id=2824;
INSERT INTO mob_skills VALUES (2824,1993,'cloudscourge',1,10.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1170;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Smierc',1170,2824);
-- Spells: Impact 503, Comet 219 [C], Meteor 218, -ja 496-501 [F]
DELETE FROM mob_spell_lists WHERE spell_list_id=453;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Smierc',453,503,1,99),('Smierc',453,219,1,99),('Smierc',453,218,1,99),('Smierc',453,496,1,99),('Smierc',453,497,1,99),
 ('Smierc',453,498,1,99),('Smierc',453,499,1,99),('Smierc',453,500,1,99),('Smierc',453,501,1,99);
UPDATE mob_pools SET skill_list_id=1170, spellList=453, hasSpellScript=1 WHERE poolid=4735;
