-- Hahava (Crimson IV, King Ranperre's Tomb zone 190). Capture ids == client ids in this zone [C,V].
-- Rifts 17555961-63, Pyxis 17555964-66, mobs 17555901-03 (group 13805, pool 5164).
-- Spawn positions [C]: NM appears at the rift (vwSpawnAtRift setPos); rows only need to be non-zero. Row 2 = capture (-121.683,7.0,-360.847).
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17555901,'Hahava','Hahava',13805,-115.0,9.0,60.0,118),
 (17555902,'Hahava','Hahava',13805,-121.683,7.0,-360.847,134),
 (17555903,'Hahava','Hahava',13805,-59.0,8.0,154.0,122);
-- Spells [J,F]: Lua picks (tiered by HP).
DELETE FROM mob_spell_lists WHERE spell_list_id=447;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Hahava',447,147,1,99),('Hahava',447,148,1,99),('Hahava',447,176,1,99),('Hahava',447,177,1,99),('Hahava',447,496,1,99),
 ('Hahava',447,366,1,99),('Hahava',447,273,1,99),('Hahava',447,357,1,99),('Hahava',447,360,1,99),('Hahava',447,362,1,99),
 ('Hahava',447,359,1,99),('Hahava',447,286,1,99),('Hahava',447,252,1,99);
-- immunity [J]: sleep 0x01, gravity 0x02, bind 0x04, silence 0x10, paralyze 0x20 (petrify has no bit here) = 0x37
UPDATE mob_pools SET skill_list_id=0, spellList=447, hasSpellScript=1, immunity=(immunity|55) WHERE poolid=5164;

-- [C] 2026-10-07: HP 71785 (hptrack 71519-72052 midpoint); Yaksha/Raksha stance skills matched by ANIM (capture ids differ).
UPDATE mob_groups SET HP=71785 WHERE groupid=13805;
DELETE FROM mob_skill_lists WHERE skill_list_id=1175;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Hahava',1175,2714),('Hahava',1175,2716),('Hahava',1175,2717),('Hahava',1175,2718),('Hahava',1175,2720);
UPDATE mob_pools SET skill_list_id=1175 WHERE poolid=5164;
