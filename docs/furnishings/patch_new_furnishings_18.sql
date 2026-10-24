-- DRAFT PATCH (not applied, not in server sql/). 18 furnishings that exist in OUR client DAT (ROM/118/106.DAT) and LSB but have no item_basic/item_furnishing row.
-- Source: LSB sql/item_basic.sql + item_furnishing.sql, converted to our columns. Flags/aH/BaseSell are LSB values (unverified vs retail); element is our 0-based numbering.
-- Not covered: how each is obtained (statues/events/Adoulin) - see furnishings_missing_client_check.csv. Review before importing; check ids with tools/check_sql_id_collisions.py not needed (item tables).

-- item_basic
INSERT INTO `item_basic` VALUES (294,0,'campfire','campfire',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3718,0,'handful_of_adoulinian_tomatoes','ado._tomatoes',1,28752,0,1,0);
INSERT INTO `item_basic` VALUES (3719,0,'prishe_statue_ii','prishe_statue_ii',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3720,0,'arciela_statue','arciela_statue',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3721,0,'iroha_statue','iroha_statue',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3722,0,'lion_statue','lion_statue',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3723,0,'lilisette_statue','lilisette_statue',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3724,0,'uka_statue','uka_statue',1,61520,0,1,0);
INSERT INTO `item_basic` VALUES (3725,0,'cornelia_statue','cornelia_statue',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3726,0,'aphmau_statue','aphmau_statue',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3727,0,'mumor_statue','mumor_statue',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3728,0,'ullegore_statue','ullegore_statue',1,61504,0,1,0);
INSERT INTO `item_basic` VALUES (3732,0,'crimson_chest','crimson_chest',1,28736,0,1,0);
INSERT INTO `item_basic` VALUES (3735,0,'aurum_coffer','aurum_coffer',1,28752,0,1,0);
INSERT INTO `item_basic` VALUES (3736,0,'well','well',1,28752,0,1,0);
INSERT INTO `item_basic` VALUES (3737,0,'doll_stand','doll_stand',1,61520,0,1,0);
INSERT INTO `item_basic` VALUES (3738,0,'eastern_umbrella','eastern_umbrella',1,61520,0,1,0);
INSERT INTO `item_basic` VALUES (3739,0,'autumn_tree','autumn_tree',1,28736,0,1,0);

-- item_furnishing
INSERT INTO `item_furnishing` VALUES (294, 'campfire', 1, 512, 0, 3);
INSERT INTO `item_furnishing` VALUES (3718, 'handful_of_adoulinian_tomatoes', 1, 2849, 5, 6);
INSERT INTO `item_furnishing` VALUES (3719, 'prishe_statue_ii', 4, 512, 0, 3);
INSERT INTO `item_furnishing` VALUES (3720, 'arciela_statue', 4, 513, 1, 3);
INSERT INTO `item_furnishing` VALUES (3721, 'iroha_statue', 4, 514, 2, 3);
INSERT INTO `item_furnishing` VALUES (3722, 'lion_statue', 4, 515, 3, 3);
INSERT INTO `item_furnishing` VALUES (3723, 'lilisette_statue', 4, 516, 4, 3);
INSERT INTO `item_furnishing` VALUES (3724, 'uka_statue', 4, 518, 6, 3);
INSERT INTO `item_furnishing` VALUES (3725, 'cornelia_statue', 4, 514, 2, 3);
INSERT INTO `item_furnishing` VALUES (3726, 'aphmau_statue', 4, 517, 5, 3);
INSERT INTO `item_furnishing` VALUES (3727, 'mumor_statue', 4, 518, 6, 3);
INSERT INTO `item_furnishing` VALUES (3728, 'ullegore_statue', 4, 519, 7, 3);
INSERT INTO `item_furnishing` VALUES (3732, 'crimson_chest', 1, 517, 5, 1);
INSERT INTO `item_furnishing` VALUES (3735, 'aurum_coffer', 5, 540, 6, 7);
INSERT INTO `item_furnishing` VALUES (3736, 'well', 80, 517, 5, 8);
INSERT INTO `item_furnishing` VALUES (3737, 'doll_stand', 2, 2855, 6, 15);
INSERT INTO `item_furnishing` VALUES (3738, 'eastern_umbrella', 1, 521, 5, 2);
INSERT INTO `item_furnishing` VALUES (3739, 'autumn_tree', 1, 515, 3, 5);
