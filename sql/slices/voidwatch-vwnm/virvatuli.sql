-- Virvatuli (Jade I, West Sarutabaruta zone 115). Evidence: [C] capture, [V] client pull, [W] BG wiki, [D] design guess.
-- 1) Re-key rifts/Pyxis/Fount/Guide to client ids (+37; zone 115 client events dump). Fount/Guide first to avoid collisions.
UPDATE npc_list SET npcid=17248951 WHERE npcid=17248914 AND name='Survival_Guide';
UPDATE npc_list SET npcid=17248950 WHERE npcid=17248913 AND name='Geomagnetic_Fount';
UPDATE npc_list SET npcid=17248949 WHERE npcid=17248912 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17248948 WHERE npcid=17248911 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17248947 WHERE npcid=17248910 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17248946 WHERE npcid=17248909 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17248945 WHERE npcid=17248908 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17248944 WHERE npcid=17248907 AND name='Planar_Rift';
-- 2) Spawn rows: 3 rifts -> 3 Virvatuli rows (spawn at rift pos). Rot only [C] for rift 0; others [D] 0.
UPDATE mob_spawn_points SET pos_y=4.0 WHERE mobid=17248625;
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17248626,'Virvatuli','Virvatuli',13778,-441.0,4.0,-357.0,0),
 (17248627,'Virvatuli','Virvatuli',13778,0.001,-28.0,560.0,0);
-- 3) Corpse Breath [C] skill 2511 anim 1775; aoe/params [D]. Skill list 1160, spell list 443.
REPLACE INTO mob_skills VALUES (2511,1775,'corpse_breath',4,10.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1160;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Virvatuli',1160,2511);
-- Spells: Blizzard IV/V [W ice nukes], Blizzaga III [C], Blizzaja [BG], Paralyga/Slowga/Blindga [W AoE enfeebles, ids D], Addle [W], Silencega [C], Death [W]
DELETE FROM mob_spell_lists WHERE spell_list_id=443;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Virvatuli',443,152,1,99),('Virvatuli',443,153,1,99),('Virvatuli',443,181,1,99),('Virvatuli',443,497,1,99),
 ('Virvatuli',443,286,1,99),('Virvatuli',443,356,1,99),('Virvatuli',443,357,1,99),('Virvatuli',443,359,1,99),
 ('Virvatuli',443,361,1,99),('Virvatuli',443,367,1,99);
UPDATE mob_pools SET skill_list_id=1160, spellList=443 WHERE poolid=5148;
