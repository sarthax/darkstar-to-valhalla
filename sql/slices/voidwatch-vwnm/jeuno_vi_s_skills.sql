-- Jeuno VI [S] NMs: skills + spells. Names/themes from forum [B]; skill ids/anims from DSP data; effects [D] (see Lua headers).
-- Row format = mob_skills VALUES (id,anim,name,aoe,dist,animtime,prep,validtargets,flag,param,knockback,sc1,sc2,sc3)
DELETE FROM mob_skills WHERE mob_skill_id IN (2809,2811);
INSERT INTO mob_skills VALUES
 (2809,2553,'immolating_claw',0,7.0,2000,1500,4,0,0,0,0,0,0),
 (2811,2555,'keraunos_quill',1,15.0,2000,1500,4,0,0,0,0,0,0);

-- Gaunab (pool 5173): Mantis family list 340 + Immolating Claw
DELETE FROM mob_skill_lists WHERE skill_list_id=1184;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES
 ('Gaunab',1184,2751),('Gaunab',1184,2752),('Gaunab',1184,2753),('Gaunab',1184,2754),('Gaunab',1184,2755),('Gaunab',1184,2756),('Gaunab',1184,2809);
UPDATE mob_pools SET skill_list_id=1184 WHERE poolid=5173;

-- Ocythoe (pool 4679): Rending Talons, Wings of Woe (stub), Kaleidoscopic Fury (<50%, row 2758 from aello.sql), Keraunos Quill. Lightning spells [B].
DELETE FROM mob_skill_lists WHERE skill_list_id=1185;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES
 ('Ocythoe',1185,2725),('Ocythoe',1185,2727),('Ocythoe',1185,2758),('Ocythoe',1185,2811);
DELETE FROM mob_spell_lists WHERE spell_list_id=459;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Ocythoe',459,167,1,99),('Ocythoe',459,168,1,99),('Ocythoe',459,196,1,99),('Ocythoe',459,197,1,99),('Ocythoe',459,500,1,99);
UPDATE mob_pools SET skill_list_id=1185, spellList=459, hasSpellScript=1 WHERE poolid=4679;

-- Kalasutrax (pool 4708): Raksha Judgement/Illusion/Vengeance (<50%) [B, Hahava precedent]. Water spells [B].
DELETE FROM mob_skill_lists WHERE skill_list_id=1186;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES
 ('Kalasutrax',1186,2719),('Kalasutrax',1186,2720),('Kalasutrax',1186,2721);
DELETE FROM mob_spell_lists WHERE spell_list_id=460;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Kalasutrax',460,172,1,99),('Kalasutrax',460,173,1,99),('Kalasutrax',460,201,1,99),('Kalasutrax',460,202,1,99),('Kalasutrax',460,501,1,99);
UPDATE mob_pools SET skill_list_id=1186, spellList=460, hasSpellScript=1 WHERE poolid=4708;
