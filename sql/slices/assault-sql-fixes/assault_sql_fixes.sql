-- assault-sql-fixes: rows present in the backport packages but wrong/missing in the dev base SQL.
-- Import with: mysql <db> < this file (idempotent: REPLACE / UPDATE).
-- 1) Brittle_Rock rows are syntactically corrupt in base sql/mob_spawn_points.sql (e.g. '...2134,17021);259,...').
REPLACE INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035282, 'Brittle_Rock', 'Brittle Rock', 2134, 179.0, -42.362, 380.0, 0);
REPLACE INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035284, 'Brittle_Rock', 'Brittle Rock', 2134, 179.0, -32.992, 100.0, 0);
REPLACE INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035286, 'Brittle_Rock', 'Brittle Rock', 2134, 259.0, -32.862, 220.0, 0);
REPLACE INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035288, 'Brittle_Rock', 'Brittle Rock', 2134, 300.0, -32.909, 341.0, 0);
REPLACE INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES (17035290, 'Brittle_Rock', 'Brittle Rock', 2134, 339.0, -32.901, 300.0, 0);
-- 2) Troll skill list entry
REPLACE INTO `mob_skill_lists` (`skill_list_name`, `skill_list_id`, `mob_skill_id`) VALUES ('Troll', 246, 1747);
-- 3) Warhorse_Hoofprint positions (base has 0,0,0 for these ids)
REPLACE INTO `npc_list` VALUES (16986599,'Warhorse_Hoofprint','Warhorse Hoofprint',0,-340.001,-31.621,685.425,0,40,40,0,0,0,2,3,0x0000340000000000000000000000000000000000,0,'TOAU',1);
REPLACE INTO `npc_list` VALUES (16986600,'Warhorse_Hoofprint','Warhorse Hoofprint',0,154.929,-20.123,-227.454,0,40,40,0,0,0,2,3,0x0000340000000000000000000000000000000000,0,'TOAU',1);
REPLACE INTO `npc_list` VALUES (16986601,'Warhorse_Hoofprint','Warhorse Hoofprint',0,-99.640,-19.051,-552.911,0,40,40,0,0,0,2,3,0x0000340000000000000000000000000000000000,0,'TOAU',1);
REPLACE INTO `npc_list` VALUES (17027510,'Warhorse_Hoofprint','Warhorse Hoofprint',0,727.108,-14.442,-54.955,0,40,40,0,0,0,2,3,0x0000340000000000000000000000000000000000,0,'TOAU',1);
REPLACE INTO `npc_list` VALUES (17027511,'Warhorse_Hoofprint','Warhorse Hoofprint',0,-471.422,-13.772,337.187,0,40,40,0,0,0,2,3,0x0000340000000000000000000000000000000000,0,'TOAU',1);
REPLACE INTO `npc_list` VALUES (17027512,'Warhorse_Hoofprint','Warhorse Hoofprint',0,153.357,-13.744,-208.806,0,40,40,0,0,0,2,3,0x0000340000000000000000000000000000000000,0,'TOAU',1);
