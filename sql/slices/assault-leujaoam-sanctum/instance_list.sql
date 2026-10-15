-- Row-level DSP `instance_list` rows for this package (missions 1,2,3,4), taken from the tested live dspdb on 2026-09-20.
-- Added because this package previously shipped no instance rows (packaging gap found during the fresh-server rebuild).
-- Not INSERT IGNORE: re-running against a DB that already has the rows will fail on the first duplicate key.
INSERT INTO `instance_list` (`instanceid`, `instance_name`, `entrance_zone`, `time_limit`, `start_x`, `start_y`, `start_z`, `start_rot`, `music_day`, `music_night`, `battlesolo`, `battlemulti`) VALUES
(1, 'leujaoam_cleansing', 79, 30, 280, -7.5, 35, 195, -1, -1, -1, -1),
(2, 'orichalcum_survey', 79, 30, -432, -27.627, 169, 129, -1, -1, -1, -1),
(3, 'escort_professor_chanoix', 79, 30, -218, -3.415, -95, 64, -1, -1, -1, -1),
(4, 'shanarha_grass_conservation', 79, 30, 258.776, -3.5, -239.379, 4, -1, -1, -1, -1);
