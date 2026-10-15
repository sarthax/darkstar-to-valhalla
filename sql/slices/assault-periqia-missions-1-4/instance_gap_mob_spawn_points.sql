-- Instance-gap rows for periqia_missions_1-4, from the tested live dspdb, 2026-09-20.
-- These entities are referenced by this package's instance_entities.sql but were absent from the package's other sql-dsp files.
-- Not INSERT IGNORE. Load after the package's npc_list / mob_spawn_points files.
INSERT INTO `mob_spawn_points` (`mobid`, `mobname`, `polutils_name`, `groupid`, `pos_x`, `pos_y`, `pos_z`, `pos_rot`) VALUES
(17006593, 'Excaliace', 'Excaliace', 1962, -322, -16.5, 380, 128);
