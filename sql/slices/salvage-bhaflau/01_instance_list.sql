-- salvage-bhaflau: instance 68. DSP's instance_list has no instance_zone column.
DELETE FROM `instance_list` WHERE `instanceid` = 68;
INSERT INTO `instance_list` VALUES (68,'bhaflau_remnants',72,100,339.999,19.999,-553.499,192,-1,-1,-1,-1);
