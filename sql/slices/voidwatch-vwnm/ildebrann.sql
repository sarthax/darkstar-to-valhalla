-- Ildebrann (Zilart Stage I / Ashen I, Ifrit's Cauldron z205). Client ids [V]; npc_list/mob rows already match.
-- Rifts 17617261-63, Pyxis 17617264-66, mobs 17617166/169/172 (group 13815, pool 5175); Hraun Dragon pets at mob+1/+2 (group 13816, pool 5176).
-- HP ~129300 [C hptrack 128730-129824 (a second kill read 116407-117241, unexplained)]; pets ~15900 [C 15172-17651]
UPDATE mob_groups SET HP=129300, respawntime=0 WHERE groupid=13815 AND zoneid=205;
UPDATE mob_groups SET HP=15900, respawntime=0 WHERE groupid=13816 AND zoneid=205;
-- Baleful Roar [C: id 2696, anim 660]; conal [B]
DELETE FROM mob_skills WHERE mob_skill_id=2696;
INSERT INTO mob_skills VALUES (2696,660,'baleful_roar',4,18.0,2000,1500,4,0,0,0,0,0,0);
-- Skills [C ids]: Fiery Breath 1281, Touchdown 1282, Inferno Blast 1283, Tebbad Wing (air) 1284, Absolute Terror 1285 [F], Baleful Roar 2696
DELETE FROM mob_skill_lists WHERE skill_list_id=1168;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Ildebrann',1168,1281),('Ildebrann',1168,1282),('Ildebrann',1168,1283),('Ildebrann',1168,1284),('Ildebrann',1168,1285),('Ildebrann',1168,2696);
-- Spells [C]: Firaga IV 177, Fire V 148, Firaja 496
DELETE FROM mob_spell_lists WHERE spell_list_id=451;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES ('Ildebrann',451,177,1,99),('Ildebrann',451,148,1,99),('Ildebrann',451,496,1,99);
UPDATE mob_pools SET skill_list_id=1168, spellList=451, hasSpellScript=1 WHERE poolid=5175;
