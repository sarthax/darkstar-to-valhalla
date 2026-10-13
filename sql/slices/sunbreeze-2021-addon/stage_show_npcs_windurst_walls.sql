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
-- Stage props/vendors that were VISIBLE (status 0) in captures 477/478 (positions from capture 477; stock rows are parked at 0,0,0 / hidden):
--   17756362 blank prop (model 0x32), 17756364 Bashraf, 17756365 Wahboud (fireworks/goods vendors)
UPDATE npc_list SET pos_x=8.272, pos_y=-10.000, pos_z=1.489, pos_rot=152, status=0 WHERE npcid=17756362;
UPDATE npc_list SET pos_x=1.768, pos_y=-9.540, pos_z=2.466, pos_rot=248, status=0 WHERE npcid=17756364;
UPDATE npc_list SET pos_x=1.037, pos_y=-9.210, pos_z=-0.215, pos_rot=248, status=0 WHERE npcid=17756365;
-- Decoration rows already positioned in the stock table but hidden (status 2); visible in capture 477 (status 0):
--   17756373 Fireworks (-130.382,-9.345,317.519), 17756374 blank prop at the Moogle (-26.51,-2.246,-51.839)
UPDATE npc_list SET status=0 WHERE npcid IN (17756373, 17756374);
-- NOT installed (need show-time logic / no capture evidence): 17756357 ???, 17756369 Wahboud #2. Decoration sets 17756375-17756384 / 17756388-17756397 / Shards: no capture evidence which are shown.

-- Decoration set A (look 0x0506; 374 of this set is visible in captures 473/477/478/479, set B 387-397 uses look 0x04E0 and is not). [C]
UPDATE npc_list SET status=0 WHERE npcid BETWEEN 17756375 AND 17756384;
-- Tango / Fandango stand at their show positions with Bongo (same shot); the show script runs them in and out. [C 479]
UPDATE npc_list SET pos_x=15.490, pos_y=-10.020, pos_z=6.142, pos_rot=120, status=0 WHERE npcid=17756366;
UPDATE npc_list SET pos_x=12.875, pos_y=-10.000, pos_z=2.957, pos_rot=120, status=0 WHERE npcid=17756368;

-- Event Moogle: renamed (script lookup is by name; plain 'Moogle' runs the Mog House script) and placed at the user's !logpos.
UPDATE npc_list SET name='Sunbreeze_Moogle', polutils_name='Moogle', pos_x=-24.2861, pos_y=-2.2549, pos_z=-49.9921, status=0 WHERE npcid=17756356;
