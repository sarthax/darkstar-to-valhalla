-- salvage-silversea: instance 71. DSP's instance_list has no instance_zone column.
DELETE FROM `instance_list` WHERE `instanceid` = 71;
INSERT INTO `instance_list` VALUES (71,'silver_sea_remnants',72,100,340,12,-165.5,63,-1,-1,-1,-1);
