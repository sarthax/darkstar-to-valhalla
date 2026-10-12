-- salvage-zhayolm: instance 62. DSP's instance_list has no instance_zone column (zone comes from the entity ids).
DELETE FROM `instance_list` WHERE `instanceid` = 62;
INSERT INTO `instance_list` VALUES (62,'zhayolm_remnants',72,100,340,0,-593,191,-1,-1,-1,-1);
