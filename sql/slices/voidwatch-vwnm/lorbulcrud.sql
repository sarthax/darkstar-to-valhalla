-- Lorbulcrud (Indigo II, Gusgen Mines zone 196). Rifts 17580410-12, Pyxis 17580413-15, mobs 17580342-44 (group 14088, pool 5311).
-- Pool/group existed from LSB with a misspelled name ('Lorbulcrub') -> renamed so the mob script resolves. Capture HP ~46776 [C hptrack].
-- Level 99 (wiki F says 100; server cap). BLM main so the caster script can cast (LSB had 9/9).
-- Skills [C]: Fluid Spread 2548 (anim 1768), Mucus Spread 2551 (anim 1771) -- LSB has these commented out with wrong anims; rows use the CAPTURE anims.
-- Spells [C]: Addle 286, Water IV 172, Silencega 359, Aeroga III 186, Aero IV 157 (Lua picks).
UPDATE mob_pools SET name='Lorbulcrud', packet_name='Lorbulcrud', mJob=4, sJob=4, hasSpellScript=1, spellList=456, skill_list_id=1181 WHERE poolid=5311;
UPDATE mob_groups SET HP=46776, MP=9999, respawntime=0, dropid=0, minLevel=99, maxLevel=99 WHERE groupid=14088;
REPLACE INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17580342,'Lorbulcrud','Lorbulcrud',14088,40.0,-11.0,436.0,0),
 (17580343,'Lorbulcrud','Lorbulcrud',14088,-115.0,-60.452,-100.0,178),
 (17580344,'Lorbulcrud','Lorbulcrud',14088,160.0,-40.25,-20.0,121);
DELETE FROM mob_skills WHERE mob_skill_id IN (2548,2551);
INSERT INTO mob_skills VALUES
 (2548,1768,'fluid_spread',0,7.0,2000,1500,4,0,0,0,0,0,0),
 (2551,1771,'mucus_spread',0,7.0,2000,1500,4,0,0,0,0,0,0);
DELETE FROM mob_skill_lists WHERE skill_list_id=1181;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Lorbulcrud',1181,2548),('Lorbulcrud',1181,2551);
DELETE FROM mob_spell_lists WHERE spell_list_id=456;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Lorbulcrud',456,286,1,99),('Lorbulcrud',456,172,1,99),('Lorbulcrud',456,359,1,99),('Lorbulcrud',456,186,1,99),('Lorbulcrud',456,157,1,99);
