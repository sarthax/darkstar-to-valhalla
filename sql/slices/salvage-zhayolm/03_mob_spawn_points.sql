-- salvage-zhayolm: spawn point corrections from captured positions (25 rows) and the Archaic_Chariot regroup.
-- Rows still at (0,0,0) in the live build are NOT carried: the instance loader never loads them.
UPDATE `mob_spawn_points` SET `pos_x` = 289.695, `pos_y` = -4.354, `pos_z` = -469.037, `pos_rot` = 183 WHERE `mobid` = 17076279;
UPDATE `mob_spawn_points` SET `pos_x` = 291.527, `pos_y` = -6.646, `pos_z` = -448.541, `pos_rot` = 96 WHERE `mobid` = 17076280;
UPDATE `mob_spawn_points` SET `pos_x` = 310.6, `pos_y` = -6.69, `pos_z` = -449.599, `pos_rot` = 30 WHERE `mobid` = 17076281;
UPDATE `mob_spawn_points` SET `pos_x` = 310.22, `pos_y` = -8.066, `pos_z` = -468.656, `pos_rot` = 246 WHERE `mobid` = 17076282;
UPDATE `mob_spawn_points` SET `pos_x` = 299.879, `pos_y` = -12, `pos_z` = -527.44, `pos_rot` = 182 WHERE `mobid` = 17076283;
UPDATE `mob_spawn_points` SET `pos_x` = 310.246, `pos_y` = -12.01, `pos_z` = -540.085, `pos_rot` = 164 WHERE `mobid` = 17076284;
UPDATE `mob_spawn_points` SET `pos_x` = 300.187, `pos_y` = -12.01, `pos_z` = -550.985, `pos_rot` = 60 WHERE `mobid` = 17076285;
UPDATE `mob_spawn_points` SET `pos_x` = 290.69, `pos_y` = -12.01, `pos_z` = -540.198, `pos_rot` = 245 WHERE `mobid` = 17076286;
UPDATE `mob_spawn_points` SET `groupid` = 2379 WHERE `mobid` IN (17076502,17076535,17076560);
