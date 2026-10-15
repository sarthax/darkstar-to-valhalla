-- Converted from Topaz `instance_list` to DSP's real column order/shape.
-- Rows below are the live, verified DSP `instance_list` values for missions 21-24 (pulled directly
-- from the running dspdb on 2026-09-17, matching Topaz's source values exactly). The original
-- automated conversion pass produced zero data rows here (all 10 Topaz rows were skipped on a
-- column-count/shape mismatch since DSP's `instance_list` has no `zoneid` column) -- this was a
-- documentation/completeness gap only, not a live blocker, since these 4 rows already exist
-- correctly in the live database independent of this file.
INSERT INTO `instance_list` (`instanceid`, `instance_name`, `entrance_zone`, `time_limit`, `start_x`, `start_y`, `start_z`, `start_rot`, `music_day`, `music_night`, `battlesolo`, `battlemulti`) VALUES
(21, 'excavation_duty', 61, 30, 124.999, -39.309, 19.999, 0, -1, -1, -1, -1),
(22, 'lebros_supplies', 61, 30, -333.0, -9.921, -259.999, 128, -1, -1, -1, -1),
(23, 'troll_fugitives', 61, 30, -459.912, -9.86, 342.319, 0, -1, -1, -1, -1),
(24, 'evade_and_escape', 61, 30, 302.0, -29.399, 192.0, 64, -1, -1, -1, -1);
