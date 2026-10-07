-- Restores the stock parked rows (0,0,0; original status values).
UPDATE npc_list SET pos_x=0, pos_y=0, pos_z=0, pos_rot=0, status=5 WHERE npcid IN (17756358,17756359,17756361);
UPDATE npc_list SET pos_x=0, pos_y=0, pos_z=0, pos_rot=0, status=4 WHERE npcid IN (17756360,17756363,17756367);
