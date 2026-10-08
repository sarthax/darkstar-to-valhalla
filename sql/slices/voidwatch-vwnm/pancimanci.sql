-- Pancimanci (Jade I, West Sarutabaruta [S] zone 95). Rift/Pyxis ids already match client (17167319-24); no re-key needed.
-- [V] client mob ids 17167113-115. [J] = wikiwiki.jp, [F] = FFXIclopedia, [D] design guess.
UPDATE mob_spawn_points SET pos_x=120.0,pos_y=4.0,pos_z=-440.0 WHERE mobid=17167113;
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17167114,'Pancimanci','Pancimanci',13747,-441.0,4.0,-357.0,0),
 (17167115,'Pancimanci','Pancimanci',13747,0.001,-28.0,560.0,0);
-- Skills [J]: Head Butt 300, Dream Flower 301 (AoE sleep), Petal Pirouette 2210 (AoE TP reset).
-- NOT built: Scream (live skill 306 is MND Down, retail is Terror), Fatal Scream (Doom, row commented w/ unverified anim), single-target hate-reset Dream Flower.
DELETE FROM mob_skill_lists WHERE skill_list_id=1161;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Pancimanci',1161,300),('Pancimanci',1161,301),('Pancimanci',1161,2210);
-- Spells [J]: Addle, Slowga, Silencega, Graviga, tier-III -ga elementals
DELETE FROM mob_spell_lists WHERE spell_list_id=444;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Pancimanci',444,286,1,99),('Pancimanci',444,357,1,99),('Pancimanci',444,359,1,99),('Pancimanci',444,366,1,99),
 ('Pancimanci',444,176,1,99),('Pancimanci',444,181,1,99),('Pancimanci',444,186,1,99),('Pancimanci',444,191,1,99),('Pancimanci',444,196,1,99),('Pancimanci',444,201,1,99);
-- immunity: sleep (0x01) [J "invalid: sleep"]
UPDATE mob_pools SET skill_list_id=1161, spellList=444, immunity=(immunity|1) WHERE poolid=4711;

-- Fix: mobname was truncated to 'Pancimani', so scripts/zones/West_Sarutabaruta_[S]/mobs/Pancimanci.lua never loaded
-- (no onMobDeath -> no cruor, no Riftworn Pyxis). Script lookup is by mobname.
UPDATE mob_spawn_points SET mobname='Pancimanci' WHERE groupid=13747;
-- Level 83, plain (non-NM) mob [U user-stated 2026-10-07]; mob_pools.mobType is already 0.
UPDATE mob_groups SET minlevel=83, maxlevel=83 WHERE groupid=13747;

-- [C] 2026-10-07: Scream seen (anim 50 = skill 306). Fatal Scream (capture id 2387 anim 1660) has no DB row.
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) SELECT 'Pancimanci',1161,306 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM mob_skill_lists WHERE skill_list_id=1161 AND mob_skill_id=306);
