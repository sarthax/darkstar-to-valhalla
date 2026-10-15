-- Instance-gap rows for ilrusi_atoll_missions_1-4, from the tested live dspdb, 2026-09-20.
-- These entities are referenced by this package's instance_entities.sql but were absent from the package's other sql-dsp files.
-- Not INSERT IGNORE. Load after the package's npc_list / mob_spawn_points files.
INSERT INTO `npc_list` (`npcid`, `name`, `polutils_name`, `pos_rot`, `pos_x`, `pos_y`, `pos_z`, `flag`, `speed`, `speedsub`, `animation`, `animationsub`, `namevis`, `status`, `entityFlags`, `look`, `name_prefix`, `content_tag`, `widescan`) VALUES
(17002738, '_1jw', '', 0, 405.262, -10.082, -251.108, 1, 50, 50, 9, 0, 0, 0, 6147, 0x0200000000000000000000000000000000000000, 0, NULL, 0),
(17002746, '_jj4', '', 0, 212.838, -6.5, -281.078, 1, 50, 50, 9, 0, 0, 0, 6147, 0x0200000000000000000000000000000000000000, 0, NULL, 0),
(17002748, '_jj6', '', 0, 294.87, -6.5, -359.301, 1, 50, 50, 9, 0, 0, 0, 6147, 0x0200000000000000000000000000000000000000, 0, NULL, 0),
(17002749, '_jj7', '', 0, 343.707, -6.5, -363.7, 1, 50, 50, 9, 0, 0, 0, 6147, 0x0200000000000000000000000000000000000000, 0, NULL, 0),
(17002750, '_jj8', '', 0, 414.269, -6.5, -439.766, 1, 50, 50, 9, 0, 0, 0, 6147, 0x0200000000000000000000000000000000000000, 0, NULL, 0),
(17002751, '_jj9', '', 0, 464.223, -6.5, -437.038, 1, 50, 50, 9, 0, 0, 0, 6147, 0x0200000000000000000000000000000000000000, 0, NULL, 0);
