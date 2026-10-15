-- Live-verified DSP mob_spawn_points rows for Lebros Cavern missions 21-24 (excavation_duty,
-- lebros_supplies, troll_fugitives, evade_and_escape). Pulled directly from the running dspdb
-- on 2026-09-17 -- replaces the automated conversion pass, which had minted fake groupid
-- values 1-10 instead of the real live groupids these mobs already use (17018-17027, 2134,
-- 14240-14242) -- applying the original file as-is would have created 10 duplicate mob_groups
-- rows and split the real content across two parallel, inconsistent group ids.
--
-- 2026-09-17 cleanup: removed 5 orphaned duplicate Brittle_Rock rows (ids 17035283/285/287/
-- 289/291, each sharing exact coordinates with its paired real id 17035282/284/286/288/290).
-- These were leftovers of a "dup entity" mechanic that Brittle_Rock.lua's own 2026-08-20 revert
-- note documents as tried and reverted (broke targeting/collision on rocks 1-3) -- the ids were
-- never referenced by instance_entities.sql so they never actually loaded into the instance, but
-- they were dead rows in the live table. Deleted from the live dspdb and this file both.

INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035265, 'Volcanic_Bomb', 'Volcanic Bomb', 17019, 104.849, -30.782, 71.223, 31);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035266, 'Volcanic_Bomb', 'Volcanic Bomb', 17019, 171.747, -30.054, 56.534, 2);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035267, 'Volcanic_Bomb', 'Volcanic Bomb', 17019, 183.383, -30.205, 128.727, 74);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035268, 'Qiqirn_Ceramist', 'Qiqirn Ceramist', 17026, 182.794, -30.495, 175.626, 235);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035269, 'Qiqirn_Volcanist', 'Qiqirn Volcanist', 17024, 174.561, -30.499, 173.275, 208);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035270, 'Volcanic_Bomb', 'Volcanic Bomb', 17019, 187.156, -36.638, 225.025, 47);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035271, 'Volcanic_Bomb', 'Volcanic Bomb', 17019, 180.99, -38.81, 239.351, 182);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035272, 'Volcanic_Bomb', 'Volcanic Bomb', 17019, 180.053, -32.766, 208.615, 65);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035273, 'Qiqirn_Ceramist', 'Qiqirn Ceramist', 17026, 183.52, -40.267, 255.747, 35);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035274, 'Qiqirn_Volcanist', 'Qiqirn Volcanist', 17024, 161.072, -40.596, 319.473, 30);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035275, 'Qiqirn_Volcanist', 'Qiqirn Volcanist', 17024, 160.968, -40.624, 326.377, 92);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035276, 'Qiqirn_Ceramist', 'Qiqirn Ceramist', 17026, 257.38, -30.656, 191.686, 215);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035277, 'Qiqirn_Ceramist', 'Qiqirn Ceramist', 17026, 285.401, -29.157, 261.043, 7);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035278, 'Qiqirn_Ceramist', 'Qiqirn Ceramist', 17026, 299.235, -29.639, 249.027, 86);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035279, 'Qiqirn_Volcanist', 'Qiqirn Volcanist', 17024, 330.191, -30.537, 339.25, 253);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035280, 'Volcanic_Bomb', 'Volcanic Bomb', 17019, 372.723, -30.584, 332.945, 38);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035281, 'Volcanic_Bomb', 'Volcanic Bomb', 17019, 252.169, -30.026, 341.965, 78);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035282, 'Brittle_Rock', 'Brittle Rock', 2134, 179.0, -42.362, 380.0, 0);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035284, 'Brittle_Rock', 'Brittle Rock', 2134, 179.0, -32.992, 100.0, 0);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035286, 'Brittle_Rock', 'Brittle Rock', 2134, 259.0, -32.862, 220.0, 0);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035288, 'Brittle_Rock', 'Brittle Rock', 2134, 300.0, -32.909, 341.0, 0);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035290, 'Brittle_Rock', 'Brittle Rock', 2134, 339.0, -32.901, 300.0, 0);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035304, 'Crimson_Eruca', 'Crimson Eruca', 17027, -400.341, -9.5, -383.901, 79);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035305, 'Crimson_Eruca', 'Crimson Eruca', 17027, -311.642, -8.924, -219.153, 137);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035306, 'Crimson_Eruca', 'Crimson Eruca', 17027, -319.234, -8.581, -177.19, 131);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035307, 'Crimson_Eruca', 'Crimson Eruca', 17027, -512.092, -10.054, -162.526, 235);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035308, 'Crimson_Eruca', 'Crimson Eruca', 17027, -555.575, -10.872, -149.561, 201);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035309, 'Crimson_Eruca', 'Crimson Eruca', 17027, -154.116, -10.063, -279.954, 230);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035310, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17018, -367.6, -10.53, 230.561, 18);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035311, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17025, -370.7, -10.49, 240.79, 177);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035312, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17025, -348.1, -10.02, 232.17, 130);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035313, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17023, -491.3, -10.57, 157.789, 74);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035314, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17020, -473.5, -10.32, 159.927, 14);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035315, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17020, -488.0, -10.52, 158.824, 209);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035316, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17020, -294.2, -10.6, 183.402, 142);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035317, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17018, -460.7, -10.28, 89.837, 123);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035318, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17023, -431.3, -10.44, -6.488, 200);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035319, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17018, -442.6, -10.39, 5.018, 45);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035320, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17025, -503.7, -10.13, -17.16, 234);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035321, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17023, -271.9, -10.09, 77.684, 221);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035322, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17018, -281.8, -10.39, 83.448, 16);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035323, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17020, -273.5, -10.3, 77.054, 183);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035324, 'Broken_Troll_Soldier', 'Broken Troll Soldier', 17023, -253.9, -24.06, 212.11, 218);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035325, 'Dahak', 'Dahak', 17022, 355.702, -46.538, -12.491, 92);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035326, 'Dahak', 'Dahak', 17022, 287.658, -31.046, 60.976, 5);
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035327, 'Dahak', 'Dahak', 17022, 274.528, -30.921, 58.135, 221);
