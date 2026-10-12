-- salvage-arrapago: instance 65. DSP's instance_list has no instance_zone column.
DELETE FROM `instance_list` WHERE `instanceid` = 65;
INSERT INTO `instance_list` VALUES (65,'arrapago_remnants',72,100,340,0,-246,63,-1,-1,-1,-1);
