-- Stachysaurus (Jeuno Stage V / White V, La Theine Plateau z102). Client ids (see rekey_102.sql) [V].
-- Rifts 17195690-92, Pyxis 693-95, mobs 17195494-96 (group 13808, pool 5167). Positions = rift positions [C].
DELETE FROM mob_spawn_points WHERE mobid IN (17195494,17195495,17195496);
INSERT INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17195494,'Stachysaurus','Stachysaurus',13808,640,32,1,0),
 (17195495,'Stachysaurus','Stachysaurus',13808,-440,-8,440,0),
 (17195496,'Stachysaurus','Stachysaurus',13808,200,32,-600,0);
-- HP ~193000 [C: hptrack 192604-194261]
UPDATE mob_groups SET HP=193000, respawntime=0 WHERE groupid=13808 AND zoneid=102;
-- Batterhorn 2099 / Clobber 2100 already exist (shared Wivre rows); own list so other Wivres are untouched [C]
DELETE FROM mob_skill_lists WHERE skill_list_id=1171;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Stachysaurus',1171,2099),('Stachysaurus',1171,2100);
UPDATE mob_pools SET skill_list_id=1171 WHERE poolid=5167;
