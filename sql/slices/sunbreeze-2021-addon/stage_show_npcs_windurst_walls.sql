-- Sunbreeze Curtain Call stage show, Windurst Walls (zone 239). INSTALL (run only when SUNBREEZE_2021_ADDON = 1).
-- NO new ids: Valhalla's npc_list already holds the retail Curtain Call rows (17756358-17756367) parked at (0,0,0).
-- Capture 477-479 entity ids for this zone are IDENTICAL to these server ids, so no capture-to-server remap is needed here.
-- Positions = raw packet coords at show start (capture 477), NOT yet !checknav-verified (Y-inverted rule applies to navmesh checks).
-- Also sets status 0 (visible); stock rows are 5 (Mumor/Uka/Ullegore) and 4 (Diva/Foudeel/Bongo).
-- Cast -> npcid: Mumor 17756358, Uka 17756359, Diva 17756360, Ullegore 17756361, Foudeel 17756363, Bongo 17756367.
-- Left untouched: 17756370/17756371 (second/third Mumor, content_tag 1, other event), Bashraf/Wahboud/Tango/Fandango (shop NPCs).
UPDATE npc_list SET pos_x=4.310,  pos_y=-9.670, pos_z=1.620, pos_rot=247, status=0 WHERE npcid=17756358;
UPDATE npc_list SET pos_x=6.727,  pos_y=-9.090, pos_z=2.143, pos_rot=119, status=0 WHERE npcid=17756359;
UPDATE npc_list SET pos_x=2.687,  pos_y=-9.490, pos_z=0.450, pos_rot=239, status=0 WHERE npcid=17756360;
UPDATE npc_list SET pos_x=9.026,  pos_y=-10.000, pos_z=2.759, pos_rot=118, status=0 WHERE npcid=17756361;
UPDATE npc_list SET pos_x=1.403,  pos_y=-9.370, pos_z=1.122, pos_rot=248, status=0 WHERE npcid=17756363;
UPDATE npc_list SET pos_x=16.062, pos_y=-10.000, pos_z=5.050, pos_rot=120, status=0 WHERE npcid=17756367;
