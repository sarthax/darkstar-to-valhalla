-- Row-level DSP `instance_list` rows for this package (missions 11,12,13,14), taken from the tested live dspdb on 2026-09-20.
-- Added because this package previously shipped no instance rows (packaging gap found during the fresh-server rebuild).
-- Not INSERT IGNORE: re-running against a DB that already has the rows will fail on the first duplicate key.
INSERT INTO `instance_list` (`instanceid`, `instance_name`, `entrance_zone`, `time_limit`, `start_x`, `start_y`, `start_z`, `start_rot`, `music_day`, `music_night`, `battlesolo`, `battlemulti`) VALUES
(11, 'imperial_agent_rescue', 52, 30, -20, 2.276, -405, 63, -1, -1, -1, -1),
(12, 'preemptive_strike', 52, 30, -75, -3.3, 20, 0, -1, -1, -1, -1),
(13, 'sagelord_elimination', 52, 30, -300, -3.3, 115, 64, -1, -1, -1, -1),
(14, 'breaking_morale', 52, 15, 19, 2.026, -136, 64, -1, -1, -1, -1);
