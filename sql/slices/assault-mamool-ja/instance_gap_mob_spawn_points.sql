-- Instance-gap rows for mamool_ja_training_grounds_missions_1-4, from the tested live dspdb, 2026-09-20.
-- These entities are referenced by this package's instance_entities.sql but were absent from the package's other sql-dsp files.
-- Not INSERT IGNORE. Load after the package's npc_list / mob_spawn_points files.
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES
(17047610, 'Mamool_Ja_Recruit', 'Mamool Ja Recruit', 17041, 47, 2, -213, 148),
(17047611, 'Mamool_Ja_Recruit', 'Mamool Ja Recruit', 17041, 55, 2, -219, 228),
(17047612, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, 53, 2, -219, 119),
(17047613, 'Mamool_Ja_Recruit', 'Mamool Ja Recruit', 17041, -19, 2, -211, 198),
(17047614, 'Mamool_Ja_Recruit', 'Mamool Ja Recruit', 17041, -21, 2, -185, 137),
(17047615, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, -17, 2, -208, 149),
(17047616, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, -34, 2, -230, 148),
(17047617, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, -21, 2, -216, 75),
(17047618, 'Mamool_Ja_Recruit', 'Mamool Ja Recruit', 17041, 9, 2, -271, 203),
(17047619, 'Mamool_Ja_Recruit', 'Mamool Ja Recruit', 17041, -43, 2, -271, 93),
(17047620, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, -36, 2, -275, 213),
(17047621, 'Mamool_Ja_Recruit', 'Mamool Ja Recruit', 17041, -37, 2, -236, 123),
(17047622, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, -55, 2, -234, 138),
(17047623, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, 26, -5, -262, 32),
(17047624, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, 17, -5, -209, 238),
(17047625, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, -24, -5, -251, 121),
(17047626, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, -62, -5, -266, 120),
(17047627, 'Mamool_Ja_Trainer', 'Mamool Ja Trainer', 17036, -60, -5, -213, 252);
