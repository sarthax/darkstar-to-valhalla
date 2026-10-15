-- Row-level DSP `instance_list` rows for this package (missions 31,32,33,34), taken from the tested live dspdb on 2026-09-20.
-- Added because this package previously shipped no instance rows (packaging gap found during the fresh-server rebuild).
-- Not INSERT IGNORE: re-running against a DB that already has the rows will fail on the first duplicate key.
INSERT INTO `instance_list` (`instanceid`, `instance_name`, `entrance_zone`, `time_limit`, `start_x`, `start_y`, `start_z`, `start_rot`, `music_day`, `music_night`, `battlesolo`, `battlemulti`) VALUES
(31, 'seagull_grounded', 79, 30, -350, -15.245, 380, 0, -1, -1, -1, -1),
(32, 'requiem', 79, 30, -470, -9.694, -325, 192, -1, -1, -1, -1),
(33, 'saving_private_ryaaf', 79, 30, 20, -15.644, 548, 64, -1, -1, -1, -1),
(34, 'shooting_down_the_baron', 79, 15, -143.905, -15.257, -65.603, 138, -1, -1, -1, -1);
