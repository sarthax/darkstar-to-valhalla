-- Crimson/Indigo/Jade NM audit 2026-10-12. Sources: [J] wikiwiki.jp VW route pages, [C] captures, [V] live DB rows with Lua.
-- 1. Impossible-to-gauge: Cottus was the only mobType 0 (all others already 2).
UPDATE mob_pools SET mobType=2 WHERE poolid IN (4656,4683,4684,4687,4711,5148,5152,5153,5161,5164,5165,5168,5189,5311,5312,6820,6890,7058);
-- 2. HP: no source found for Pancimanci/Akupara/Voidwrought; 45000 ESTIMATE [U user 2026-10-12, ~45k typical for these tiers], replace when captured.
UPDATE mob_groups SET HP=45000 WHERE groupid IN (13747,13729,18226) AND HP=0;
-- 3. Sarimanok: own list (was shared Puk list 198, 19 pools). JP: Crosswind 1718, Wind Shear 1720, Ill Wind 1723. Somnial Durance not available (commented row 2644).
DELETE FROM mob_skill_lists WHERE skill_list_id=1184;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Sarimanok',1184,1718),('Sarimanok',1184,1720),('Sarimanok',1184,1723);
UPDATE mob_pools SET skill_list_id=1184 WHERE poolid=5165;
-- 4. Add skills that already exist live with Lua.
-- Belphoebe: Summer/Autumn/Winter Breeze, Cyclonic Turmoil
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) SELECT 'Belphoebe',1174,s FROM (SELECT 2196 s UNION SELECT 2197 UNION SELECT 2198 UNION SELECT 2199) t WHERE NOT EXISTS (SELECT 1 FROM mob_skill_lists WHERE skill_list_id=1174 AND mob_skill_id=t.s);
-- Hahava: Yaksha Damnation, Raksha Judgement, Raksha Vengeance
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) SELECT 'Hahava',1175,s FROM (SELECT 2715 s UNION SELECT 2719 UNION SELECT 2721) t WHERE NOT EXISTS (SELECT 1 FROM mob_skill_lists WHERE skill_list_id=1175 AND mob_skill_id=t.s);
-- Kholomodumo: Thunderbolt 629; Ushumgal: Regurgitation 2153; Lorbulcrud: Epoxy Spread 1319 (name match to JP, unverified)
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) SELECT 'Kholomodumo',1172,629 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM mob_skill_lists WHERE skill_list_id=1172 AND mob_skill_id=629);
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) SELECT 'Ushumgal',1180,2153 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM mob_skill_lists WHERE skill_list_id=1180 AND mob_skill_id=2153);
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) SELECT 'Lorbulcrud',1181,1319 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM mob_skill_lists WHERE skill_list_id=1181 AND mob_skill_id=1319);
