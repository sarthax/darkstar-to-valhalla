-- 2026-10-03 Stealthlord Haraal Ja (pool 6998): skill ids MUST be 1797-1801 -- the client takes the chat name from the skill id
-- (1797 Rushing Slash, 1798 Decussate, 1799 Tyrannic Blare, 1800 Miasma, 1801 Vorpal Wheel). Earlier ids 3900-3904 showed
-- Suction/Drainkiss/Snow Cloud/Wild Carrot/Sudden Lunge. Model 1863 passes the pw_* gate, so existing Lua is reused.
UPDATE mob_skills SET mob_anim_id=1320 WHERE mob_skill_id=1797;
UPDATE mob_skills SET mob_anim_id=1321 WHERE mob_skill_id=1798;
UPDATE mob_skills SET mob_anim_id=1322 WHERE mob_skill_id=1799;
REPLACE INTO mob_skills VALUES (1800,1323,'miasma',0,7.0,2000,1500,4,0,0,0,0,0,0);
REPLACE INTO mob_skills VALUES (1801,1324,'vorpal_wheel',0,7.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1158;
INSERT INTO mob_skill_lists VALUES ('Haraal_Ja',1158,1797),('Haraal_Ja',1158,1798),('Haraal_Ja',1158,1799),('Haraal_Ja',1158,1800),('Haraal_Ja',1158,1801);
UPDATE mob_pools SET skill_list_id=1158 WHERE poolid=6998;
UPDATE mob_skills SET mob_skill_name='pw_tyrranic_blare' WHERE mob_skill_id=1799; -- Lua file is spelled pw_tyrranic_blare.lua (double r)
UPDATE mob_pools SET skill_list_id=1158 WHERE poolid=1846; -- Gulool Ja Ja shares Haraal's move set
