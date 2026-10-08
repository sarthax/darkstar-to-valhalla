-- Belphoebe (Crimson III, Jugner Forest zone 104). Rift/Pyxis ids match client (rifts 17203939-41, Pyxis 17203942-44).
-- [V] client mob ids 17203696-98 (z104 entities.yml; 17203699-701 are Emperor Arthro, so the old 97-99 set showed that name on rift 2).
-- Positions [C] capture: rift0 (78,118) rot 224; rift1 (263.84,539.1); rift2 (-333.9,-119). Pyxis1 position [D] (no capture of that rift).
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17203696,'Belphoebe','Belphoebe',13782, 78.0,-0.5,118.0,52),
 (17203697,'Belphoebe','Belphoebe',13782,263.84,-0.447,539.103,233),
 (17203698,'Belphoebe','Belphoebe',13782,-333.937,-1.242,-118.985,139);
UPDATE npc_list SET pos_x=78.000,pos_y=0.000,pos_z=118.000,pos_rot=224 WHERE npcid=17203939;
UPDATE npc_list SET pos_x=78.100,pos_y=0.000,pos_z=118.000,pos_rot=224 WHERE npcid=17203942;
UPDATE npc_list SET pos_x=263.100,pos_y=0.000,pos_z=553.000 WHERE npcid=17203943;
UPDATE npc_list SET pos_x=-324.900,pos_y=0.000,pos_z=-124.000 WHERE npcid=17203944;
-- Skills [J,F,C]: Spring 2195 (anim 1583 [C]), Summer 2196, Autumn 2197, Winter 2198, Cyclonic Turmoil 2199, in that order via Lua (pool skill list left empty so the engine doesn't pick randomly).
-- NOT built: Norn Arrows (see UNIMPLEMENTED.md).
-- Spells [J]: Lua picks from list 446 (tiered by HP).
DELETE FROM mob_spell_lists WHERE spell_list_id=446;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Belphoebe',446,365,1,99),('Belphoebe',446,366,1,99),('Belphoebe',446,273,1,99),('Belphoebe',446,360,1,99),('Belphoebe',446,359,1,99),
 ('Belphoebe',446,252,1,99),('Belphoebe',446,286,1,99),('Belphoebe',446,367,1,99),
 ('Belphoebe',446,176,1,99),('Belphoebe',446,181,1,99),('Belphoebe',446,186,1,99),('Belphoebe',446,191,1,99),('Belphoebe',446,196,1,99),('Belphoebe',446,201,1,99),
 ('Belphoebe',446,177,1,99),('Belphoebe',446,182,1,99),('Belphoebe',446,187,1,99),('Belphoebe',446,192,1,99),('Belphoebe',446,197,1,99),('Belphoebe',446,202,1,99),
 ('Belphoebe',446,178,1,99),('Belphoebe',446,183,1,99),('Belphoebe',446,188,1,99),('Belphoebe',446,193,1,99),('Belphoebe',446,198,1,99),('Belphoebe',446,203,1,99),
 ('Belphoebe',446,496,1,99),('Belphoebe',446,497,1,99),('Belphoebe',446,498,1,99),('Belphoebe',446,499,1,99),('Belphoebe',446,500,1,99),('Belphoebe',446,501,1,99);
-- immunity: sleep (0x01) + silence (0x10) [J]
UPDATE mob_pools SET skill_list_id=0, spellList=446, hasSpellScript=1, immunity=(immunity|17) WHERE poolid=5152;

-- [C] 2026-10-07: HP 61641 (hptrack 61026-61840); Spring Breeze (skill 2195 anim 1583) and Thunder V (168) seen.
UPDATE mob_groups SET HP=61641 WHERE groupid=13782;
DELETE FROM mob_spell_lists WHERE spell_list_id=446 AND spell_id=168;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES ('Belphoebe',446,168,1,255);
DELETE FROM mob_skill_lists WHERE skill_list_id=1174;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Belphoebe',1174,2195);
UPDATE mob_pools SET skill_list_id=1174 WHERE poolid=5152;
