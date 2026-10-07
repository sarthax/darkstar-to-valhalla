-- Sallow Seymour (Indigo I, North Gustaberg zone 106). Rift/Pyxis ids match the client (17212116-21): no re-key.
-- [V] client mob ids 17211882-84; live had only 82 and 84.
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17211883,'SallowSeymour','Sallow Seymour',13772,558.0,-10.0,603.0,0);
-- Skills in DB [J]: Sandspin 426, Tremors 427. NOT built: Mud Stream, Epuration; Draw In via MOBMOD_DRAW_IN (see UNIMPLEMENTED.md).
DELETE FROM mob_skill_lists WHERE skill_list_id=1163;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('SallowSeymour',1163,426),('SallowSeymour',1163,427);
-- Spells [J]: Rasp 238, Slowga 357, Stonega II 190, Stonega III 191, Stone IV 162, Stoneja 499, Breakga 365 (<=30% HP, Lua)
DELETE FROM mob_spell_lists WHERE spell_list_id=445;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('SallowSeymour',445,238,1,99),('SallowSeymour',445,357,1,99),('SallowSeymour',445,190,1,99),('SallowSeymour',445,191,1,99),
 ('SallowSeymour',445,162,1,99),('SallowSeymour',445,499,1,99),('SallowSeymour',445,365,1,99);
-- immunity: silence (0x10) [J]
UPDATE mob_pools SET skill_list_id=1163, spellList=445, hasSpellScript=1, immunity=(immunity|16) WHERE poolid=4687;
