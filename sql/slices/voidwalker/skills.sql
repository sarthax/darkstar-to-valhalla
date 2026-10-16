-- Voidwalker NM skills (Blobdingnag, Orcus). Skill ids/anim ids are the DSP mob_skills ids (commented out in mob_skills.sql,
-- no script yet); every id was observed in the Discord captures. Rows copy the commented sql/mob_skills.sql rows; AoE flags
-- follow the captured targets (Cytokinesis/Dissolve hit 2 party members) and the sibling Spread skills (aoe, 10 yalms).
-- Import AFTER all_zones.sql (pools 7008/7023 point at skill lists 9001/9002).
DELETE FROM `mob_skills` WHERE mob_skill_id IN (1845,2514,2516,2517,2548,2550,2551,2552);
DELETE FROM `mob_skill_lists` WHERE skill_list_id IN (9001,9002);

INSERT INTO `mob_skills` VALUES (1845,1589,'mandibular_bite',0,7.0,2000,1500,4,0,0,0,0,0,0);
INSERT INTO `mob_skills` VALUES (2514,2258,'cytokinesis',1,10.0,2000,1500,4,0,0,0,0,0,0);
INSERT INTO `mob_skills` VALUES (2516,2260,'gravitic_horn',0,7.0,2000,1500,4,0,0,0,0,0,0);
INSERT INTO `mob_skills` VALUES (2517,2261,'quake_blast',0,7.0,2000,1500,4,0,0,0,0,0,0);
INSERT INTO `mob_skills` VALUES (2548,2292,'fluid_spread',1,10.0,2000,1500,4,0,0,0,0,0,0);
INSERT INTO `mob_skills` VALUES (2550,2294,'dissolve',1,10.0,2000,1500,4,0,0,0,0,0,0);
INSERT INTO `mob_skills` VALUES (2551,2295,'mucus_spread',1,10.0,2000,1500,4,0,0,0,0,0,0);
INSERT INTO `mob_skills` VALUES (2552,2296,'epoxy_spread',1,10.0,2000,1500,4,0,0,0,0,0,0);

INSERT INTO `mob_skill_lists` VALUES ('Blobdingnag',9001,2514);
INSERT INTO `mob_skill_lists` VALUES ('Blobdingnag',9001,2548);
INSERT INTO `mob_skill_lists` VALUES ('Blobdingnag',9001,2549);
INSERT INTO `mob_skill_lists` VALUES ('Blobdingnag',9001,2550);
INSERT INTO `mob_skill_lists` VALUES ('Blobdingnag',9001,2551);
INSERT INTO `mob_skill_lists` VALUES ('Blobdingnag',9001,2552);
INSERT INTO `mob_skill_lists` VALUES ('Orcus',9002,1845);
INSERT INTO `mob_skill_lists` VALUES ('Orcus',9002,2516);
INSERT INTO `mob_skill_lists` VALUES ('Orcus',9002,2517);
