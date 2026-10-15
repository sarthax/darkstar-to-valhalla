-- Row-level DSP `instance_list` rows for this package (missions 41,42,43,44), taken from the tested live dspdb on 2026-09-20.
-- Added because this package previously shipped no instance rows (packaging gap found during the fresh-server rebuild).
-- Not INSERT IGNORE: re-running against a DB that already has the rows will fail on the first duplicate key.
INSERT INTO `instance_list` (`instanceid`, `instance_name`, `entrance_zone`, `time_limit`, `start_x`, `start_y`, `start_z`, `start_rot`, `music_day`, `music_night`, `battlesolo`, `battlemulti`) VALUES
(41, 'golden_salvage', 54, 30, 386, -12, 17, 46, -1, -1, -1, -1),
(42, 'lamia_no_13', 54, 30, 155, -7, -175, 47, -1, -1, -1, -1),
(43, 'extermination', 54, 30, 298.099, -3.943, 135.234, 64, -1, -1, -1, -1),
(44, 'demolition_duty', 54, 30, 368.2, -7.194, -464.499, 16, -1, -1, -1, -1);
