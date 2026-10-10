-- salvage-base: pathos status effects (already in sql/status_effects.sql on main; idempotent re-apply).
DELETE FROM `status_effects` WHERE `id` IN (259,260,261,262,263,264);
INSERT INTO `status_effects` VALUES (259,'encumbrance',8388640,0,0,0,0,0,0,0);
INSERT INTO `status_effects` VALUES (260,'obliviscence',8388640,0,0,0,0,0,0,0);
INSERT INTO `status_effects` VALUES (261,'impairment',8388640,0,0,0,0,0,0,0);
INSERT INTO `status_effects` VALUES (262,'omerta',8388640,0,0,0,0,0,0,0);
INSERT INTO `status_effects` VALUES (263,'debilitation',8388640,0,0,0,0,0,0,0);
INSERT INTO `status_effects` VALUES (264,'pathos',8388640,0,0,0,0,0,0,0);
