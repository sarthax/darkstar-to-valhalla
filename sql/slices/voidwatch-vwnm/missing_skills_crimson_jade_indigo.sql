-- Missing Crimson/Jade/Indigo VW NM moves. NO captures: effects/numbers from BG wiki [W], FFXIclopedia [F], wikiwiki.jp [J], BG forum [B], else [D] design guess.
-- Skill ids from LSB mob_skills. Anim ids: 1660 fatal_scream and 1839 mud_stream are [C]; 1455/1581/1543/1803/1805 are LSB/REUSE placeholders, NOT client-verified.
-- aoe: 1 self AoE, 4 conal. Columns: id,anim,name,aoe,dist,anim_time,prepare,valid_targets,flag,param,knockback,sc1,sc2,sc3
REPLACE INTO `mob_skills` VALUES (2112,1455,'nocturnal_servitude',4,15.0,2000,1500,4,0,0,0,0,0,0);
REPLACE INTO `mob_skills` VALUES (2157,1543,'calcifying_mist',1,15.0,2000,1500,4,0,0,0,0,0,0);
REPLACE INTO `mob_skills` VALUES (2387,1660,'fatal_scream',1,20.0,2000,1500,4,0,0,0,0,0,0);
REPLACE INTO `mob_skills` VALUES (2516,1581,'gravitic_horn',4,20.0,2000,1500,4,0,0,0,0,0,0);
REPLACE INTO `mob_skills` VALUES (2517,1581,'quake_blast',1,20.0,2000,1500,4,0,0,0,0,0,0);
REPLACE INTO `mob_skills` VALUES (2518,1581,'norn_arrows',1,20.0,2000,2000,4,0,0,0,0,0,0);
REPLACE INTO `mob_skills` VALUES (2576,1803,'mercurial_strike',1,15.0,2000,1500,4,0,0,0,0,0,0);
REPLACE INTO `mob_skills` VALUES (2578,1805,'colossal_slam',1,15.0,2000,3000,4,0,0,1,0,0,0);
REPLACE INTO `mob_skills` VALUES (2645,1839,'mud_stream',1,20.0,2000,1500,4,0,0,0,0,0,0);
-- Scripted (Cottus 2576/2578, Belphoebe 2518) skills stay OUT of the random lists; the rest are added to the pools' lists.
DELETE FROM `mob_skill_lists` WHERE `mob_skill_id` IN (2387,2645,2516,2517,2112,2157,2156,2730,788) AND `skill_list_id` IN (1161,1163,1164,1165,1180,1183,1182);
INSERT INTO `mob_skill_lists` (`skill_list_name`,`skill_list_id`,`mob_skill_id`) VALUES
 ('Pancimanci',1161,2387),('Sallow_Seymour',1163,2645),('Ogbunabali',1164,2516),('Ogbunabali',1164,2517),
 ('Lord_Asag',1165,2112),('Ushumgal',1180,2156),('Ushumgal',1180,2157),('Celaeno',1183,2730),('Baneberry',1182,788);

-- Melancholic Moira: Extremely Bad Breath (LSB row 1332, anim 1076 unverified [D]); conal, 7y, 1.5s prepare (stunnable)
REPLACE INTO `mob_skills` VALUES (1332,1076,'extremely_bad_breath',4,7.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM `mob_skill_lists` WHERE `mob_skill_id`=1332 AND `skill_list_id`=1173;
INSERT INTO `mob_skill_lists` (`skill_list_name`,`skill_list_id`,`mob_skill_id`) VALUES ('Melancholic_Moira',1173,1332);
