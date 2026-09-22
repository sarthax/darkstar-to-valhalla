-- Mamool_Ja_Training_Grounds door prop registrations (zone 66)
-- Added to instance_entities.sql for missions 11-20
-- These ensure all door props are registered and visible correctly

-- Mission 11: Imperial Agent Rescue - additional door props if missing
INSERT INTO `instance_entities` VALUES (11,17047903);
INSERT INTO `instance_entities` VALUES (11,17047904);
INSERT INTO `instance_entities` VALUES (11,17047905);

-- Mission 12: Preemptive Strike - already registered in base SQL

-- Mission 13: Sagelord Elimination - additional props
INSERT INTO `instance_entities` VALUES (13,17047867);
INSERT INTO `instance_entities` VALUES (13,17047868);

-- Mission 14: Breaking Morale - all props registered

-- Mission 15-20: Verify registrations match instance.lua definitions
