-- Restores the stock parked rows (0,0,0; original status values).
UPDATE npc_list SET pos_x=0, pos_y=0, pos_z=0, pos_rot=0, status=5 WHERE npcid IN (17756358,17756359,17756361);
UPDATE npc_list SET pos_x=0, pos_y=0, pos_z=0, pos_rot=0, status=4 WHERE npcid IN (17756360,17756363,17756367);
UPDATE npc_list SET pos_x=0, pos_y=0, pos_z=0, pos_rot=0, status=4 WHERE npcid IN (17756362,17756364,17756365);
UPDATE npc_list SET status=2 WHERE npcid IN (17756373, 17756374);

UPDATE npc_list SET status=2 WHERE npcid BETWEEN 17756375 AND 17756384;
UPDATE npc_list SET pos_x=0, pos_y=0, pos_z=0, pos_rot=0, status=4 WHERE npcid IN (17756366, 17756368);

UPDATE npc_list SET name='Moogle', polutils_name='Moogle', pos_x=-24.196, pos_y=-2.291, pos_z=-48.957, status=2 WHERE npcid=17756356;
