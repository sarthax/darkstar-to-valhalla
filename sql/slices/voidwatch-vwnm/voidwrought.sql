-- Voidwrought (Jade IV / Windurst, Outer Horutoto Ruins zone 194). Rifts 17572303-05, Pyxis 17572306-08 exist in DSP.
-- Client mob ids 17572219-21 [V fresh entities.yml pull 2026-10-07]. No DSP pool/group/spawn rows existed: created here.
-- Pool from LSB pool 6724 (BLM/RDM, family 350 Iron Giant model 0x5808 like DSP Ironclad Vaporizer); new ids 7058 / 18226 (live max was 7057 / 18225).
-- Spawns: LSB rows 219 (-260.682,-0.528,740.146) and 220 (-380,-0.508,740); LSB 221 was (0,0,0) (dropped by loaders), replaced
-- with the rift-2 position (-480,-0.5,760) [D, Y copied from sibling]: run !checknav -480 -0.5 760.
REPLACE INTO mob_pools VALUES (7058,'Voidwrought','Voidwrought',350,0x0000580800000000000000000000000000000000,4,5,4,240,100,0,1,1,0,2,23,0,1,135,0,1,455,1,0,1179);
REPLACE INTO mob_groups (groupid,poolid,zoneid,respawntime,spawntype,dropid,HP,MP,minLevel,maxLevel,allegiance) VALUES (18226,7058,194,0,128,0,0,9999,92,95,0);
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17572219,'Voidwrought','Voidwrought',18226,-260.682,-0.528,740.146,254),
 (17572220,'Voidwrought','Voidwrought',18226,-380.000,-0.508,740.000,26),
 (17572221,'Voidwrought','Voidwrought',18226,-480.000,-0.500,760.000,0);
-- Skills [J]: Incinerator 2621, Ballistic Kick 2623 (<=50%), Arm Cannon 2622 (>=75%), Seismic Impact 2620 (<=75%),
-- Turbine Hurricane = DSP 'turbine_cyclone' 2619 (<=75%), Eradicator 2625 (<=50%), Scapula Beam 2624 (<=50%). Lua gates by HP.
DELETE FROM mob_skill_lists WHERE skill_list_id=1179;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES
 ('Voidwrought',1179,2619),('Voidwrought',1179,2620),('Voidwrought',1179,2621),('Voidwrought',1179,2622),
 ('Voidwrought',1179,2623),('Voidwrought',1179,2624),('Voidwrought',1179,2625);
-- Spells [J]: common Silencega 359, Slowga 357, Paralyga 356, Bindga 362, Dispelga 360, Graviga 366, Sleepga 273, Stun 252, Addle 286;
-- >=75%: Thunder IV 167, Thundaga III 196; <75%: Thunder V 168, Thundaga IV 197; <=50% also Thundaja 500. Lua picks.
DELETE FROM mob_spell_lists WHERE spell_list_id=455;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Voidwrought',455,359,1,99),('Voidwrought',455,357,1,99),('Voidwrought',455,356,1,99),('Voidwrought',455,362,1,99),
 ('Voidwrought',455,360,1,99),('Voidwrought',455,366,1,99),('Voidwrought',455,273,1,99),('Voidwrought',455,252,1,99),
 ('Voidwrought',455,286,1,99),('Voidwrought',455,167,1,99),('Voidwrought',455,196,1,99),('Voidwrought',455,168,1,99),
 ('Voidwrought',455,197,1,99),('Voidwrought',455,500,1,99);
-- immunity [J]: sleep 1, gravity 2, bind 4, silence 16 = 23 (set in pool row above)
