-- Kholomodumo (Crimson III, Jugner Forest [S] zone 82). Rifts 17114040-42, Pyxis 17114043-45, mobs 17113826-28
-- (group 13783, pool 5153): all ids already match the client [V fresh entities.yml pull]; no re-key.
-- Evidence: [C] capture Raguza 2021.03.28, [B] BG forum, [D] design guess.
-- Row 0: capture spawn position (rift 0, rot 70) [C].
-- Row 1 WAS (0,0,0), which instance/zone loaders silently drop. Replaced with the rift-1 position (275, 564) [D];
--   Y -0.5 copied from row 0, NOT navmesh-checked: run !checknav 275 -0.5 564 in game.
-- Row 2: live LSB position kept (-329.225,-0.54,-142.08); not capture-verified.
UPDATE mob_spawn_points SET pos_x=78.000,pos_y=-0.500,pos_z=118.000,pos_rot=70 WHERE mobid=17113826;
UPDATE mob_spawn_points SET pos_x=275.000,pos_y=-0.500,pos_z=564.000,pos_rot=32 WHERE mobid=17113827;
-- HP ~60436 [C hptrack 57416~60987, est 60436]
UPDATE mob_groups SET HP=60436, respawntime=0, dropid=0 WHERE groupid=13783 AND zoneid=82;
-- Skills [C]: Accursed Armor 2390 anim 1663 msg 101, Amnesic Blast 2391 anim 1664 msg 185, Ecliptic Meteor 2586 anim 1684 msg 185.
-- (The commented LSB rows carry different anim ids: 2134/2135/2256; the capture values are used.)
-- aoe/distance columns are [D]: Armor self, Amnesic cone, Ecliptic Meteor AoE.
DELETE FROM mob_skills WHERE mob_skill_id IN (2390,2391,2586);
INSERT INTO mob_skills VALUES
 (2390,1663,'accursed_armor',0,7.0,2000,1500,1,0,0,0,0,0,0),
 (2391,1664,'amnesic_blast',4,10.0,2000,1500,4,0,0,0,0,0,0),
 (2586,1684,'ecliptic_meteor',1,20.0,2000,1500,4,0,0,0,0,0,0);
-- Pool list: Armor + Amnesic Blast picked by the engine; Thunderbolt 629 / Ecliptic Meteor 2586 are fired by Lua below 50% HP.
-- Listing 629/2586 here would let the engine use them above 50%, so they stay out of the list.
DELETE FROM mob_skill_lists WHERE skill_list_id=1172;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Kholomodumo',1172,2390),('Kholomodumo',1172,2391);
-- No spellcasting seen in the capture [C, ~2 min]: no spell list.
UPDATE mob_pools SET skill_list_id=1172, spellList=0 WHERE poolid=5153;
