-- Beaucedine Glacier [S] (136): the four NMs shared the clear-mob mob ids, so they spawned as Gjenganger/Gorehound (4900/5000 HP).
-- Real NM ids are 17334550-53 (LSB mobs.yaml). New groups 18784-18787 mirror Xarcabard [S] (18772-18775).
DELETE FROM `mob_groups` WHERE groupid IN (18784,18785,18786,18787);
INSERT INTO `mob_groups` VALUES (18784,4736,136,86400,0,4590,90000,5000,90,92,0);
INSERT INTO `mob_groups` VALUES (18785,7114,136,7200,0,4601,32600,0,85,85,0);
INSERT INTO `mob_groups` VALUES (18786,7106,136,3600,0,4597,15500,0,82,82,0);
INSERT INTO `mob_groups` VALUES (18787,7104,136,3600,0,4595,16000,0,82,82,0);
DELETE FROM `mob_spawn_points` WHERE mobid IN (17334550,17334551,17334552,17334553);
INSERT INTO `mob_spawn_points` VALUES (17334550,'Yilbegan','Yilbegan',18784,-123,-79,135,0);
INSERT INTO `mob_spawn_points` VALUES (17334551,'Lord_Ruthven','Lord_Ruthven',18785,-123,-79,135,0);
INSERT INTO `mob_spawn_points` VALUES (17334552,'Feuerunke','Feuerunke',18786,-123,-79,135,0);
INSERT INTO `mob_spawn_points` VALUES (17334553,'Erebus','Erebus',18787,-123,-79,135,0);
