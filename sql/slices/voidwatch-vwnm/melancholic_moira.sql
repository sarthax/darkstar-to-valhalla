-- Melancholic Moira (Indigo III, Pashhow Marshlands [S] zone 90). Rifts 17146651-53, Pyxis 17146654-56, mobs 17146510-12
-- (group 13728, pool 4683): ids already match the client [V fresh entities/dialog pull]; spawn rows all non-zero and
-- within a few yalms of their rifts, so no spawn edits. Capture: Raguza 2021.03.27 (killed mob 17146512, rift 2).
-- HP ~50796 [C hptrack 50290~55747, est 50796]
UPDATE mob_groups SET HP=50796, respawntime=0, dropid=0 WHERE groupid=13728 AND zoneid=90;
-- Skills. The capture (~80 s fight) shows NO mob TP moves, so every row below is from forum/LSB, not [C]:
--  2392 Bad Breath (Moira): new id, fixed ~600-800 damage [B #106], radial [B #611]. The shared Morbol Bad Breath (319)
--       is HP-scaled and would hit for thousands on a 50k mob, so Moira gets her own copy.
--  2575 Tainting Breath: id/anim 63 from the commented LSB row, effect [D].
--  316/317 Impale / Vampiric Lash and the Morbol list are kept from the LSB pool list 186 [LSB, unverified for Moira];
--  Sweet Breath (320) dropped: HP-scaled like 319 and not named in any Moira report.
-- "EBB" [B #106,#611] (AoE, "may be NPC self-targeted") has no resolved name or skill row: NOT BUILT.
DELETE FROM mob_skills WHERE mob_skill_id IN (2392,2575);
INSERT INTO mob_skills VALUES
 (2392,63,'melancholic_bad_breath',1,15.0,2000,1500,4,0,0,0,0,0,0),
 (2575,63,'tainting_breath',1,15.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1173;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES
 ('Melancholic_Moira',1173,316),('Melancholic_Moira',1173,317),('Melancholic_Moira',1173,2392),('Melancholic_Moira',1173,2575);
-- No spellcasting reported [B]: no spell list.
UPDATE mob_pools SET skill_list_id=1173, spellList=0 WHERE poolid=4683;
