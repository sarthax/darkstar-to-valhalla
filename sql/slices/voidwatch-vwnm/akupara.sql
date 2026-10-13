-- Akupara (Jade III / Windurst, Meriphataud Mountains [S] zone 97). Rifts 17175422-24, Pyxis 17175425-27 (match client [V]).
-- Mobs 17175250-52 (group 13729, pool 4684). Client entities.yml lists all three ids [V fresh pull 2026-10-07]; DSP only had 251/252.
-- Row 250 = rift-0 position from LSB (200,-0.5,-520,rot 6); Y from LSB, NOT navmesh-checked: run !checknav 200 -0.5 -520.
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17175250,'Akupara','Akupara',13729,200.000,-0.500,-520.000,6);
-- Skills [J wikiwiki.jp]: Tortoise Stomp 806, Earth Breath 808, Tortoise Song 804 (existing rows), Testudo Tremor 2585 (HP<=50%, Lua gate).
-- 2585 comes from the commented LSB row (anim 2329 NOT capture/client verified [D]); aoe 2 = target-centred, radius [D].
DELETE FROM mob_skills WHERE mob_skill_id=2585;
INSERT INTO mob_skills VALUES (2585,2329,'testudo_tremor',2,10.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1178;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Akupara',1178,806),('Akupara',1178,808),('Akupara',1178,804),('Akupara',1178,2585);
-- Spells [J]: common Slowga 357, Breakga 365; >=50%: Stone IV 162, Stonega III 191; <50%: Stone V 163, Stonega IV 192, Stoneja 499.
DELETE FROM mob_spell_lists WHERE spell_list_id=454;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Akupara',454,357,1,99),('Akupara',454,365,1,99),('Akupara',454,162,1,99),('Akupara',454,191,1,99),
 ('Akupara',454,163,1,99),('Akupara',454,192,1,99),('Akupara',454,499,1,99);
-- immunity [J]: stun 8, slow 128, elegy 512
UPDATE mob_pools SET skill_list_id=1178, spellList=454, hasSpellScript=1, immunity=(immunity|648) WHERE poolid=4684;
UPDATE mob_groups SET respawntime=0, dropid=0 WHERE groupid=13729;
-- HP/level not captured: group HP left unset (engine value) [unverified].
