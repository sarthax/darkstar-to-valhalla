-- Ogbunabali (Jade II / Windurst Stage II, Maze of Shakhrami zone 198). Capture ids == client ids [C,V].
-- Rifts 17588782-84, Pyxis 17588785-87, mobs 17588707-09 (group 13802, pool 5161). Rift row positions already match client/capture.
-- NM appears at the rift (vwSpawnAtRift setPos); row 3 = capture (-285,-0.375,-114) rot 77 [C].
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17588707,'Ogbunabali','Ogbunabali',13802,134.0,20.0,-89.0,77),
 (17588708,'Ogbunabali','Ogbunabali',13802,-5.0,20.0,160.0,77),
 (17588709,'Ogbunabali','Ogbunabali',13802,-285.0,-0.375,-114.0,77);
-- Dedicated skill list 1164 (pool 5161 shared list 26 with ordinary antlions): Sand Blast 275, Venom Spray 277, Mandibular Bite 279 [C,J,F].
-- NOT built: Gravitic Horn, Quake Blast (<50%): no DSP mob_skills rows, no capture of them (see UNIMPLEMENTED.md).
DELETE FROM mob_skill_lists WHERE skill_list_id=1164;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Ogbunabali',1164,275),('Ogbunabali',1164,277),('Ogbunabali',1164,279);
-- immunity: sleep (0x01) [J]
UPDATE mob_pools SET skill_list_id=1164, immunity=(immunity|1) WHERE poolid=5161;
