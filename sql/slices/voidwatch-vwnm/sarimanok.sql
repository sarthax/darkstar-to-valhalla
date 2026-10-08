-- Sarimanok (East Ronfaure, pool 5165, group 13806). Rift positions per npc_list: 665 (288,368), 666 (183,-315), 667 (434,315).
-- Spawn rows 17191335 / 17191337 already exist in the live DB; 17191336 is the missing third (draft_vw_missing_spawns.sql).
REPLACE INTO `mob_spawn_points` VALUES (17191336,'Sarimanok','Sarimanok',13806,183.0,-20.601,-315.0,141);
-- Spells per BG wiki: Aero IV (157), Aeroga II (185), Silencega (359). Aeroga III (186) is cast only as Ill Wind's follow-up (Lua).
-- spell_list_id 440 unused (max was 439).
DELETE FROM mob_spell_lists WHERE spell_list_id = 440;
INSERT INTO mob_spell_lists (spell_list_name, spell_list_id, spell_id, min_level, max_level) VALUES
('Sarimanok', 440, 157, 1, 255),
('Sarimanok', 440, 185, 1, 255),
('Sarimanok', 440, 359, 1, 255);
UPDATE mob_pools SET spellList = 440 WHERE poolid = 5165;

-- HP [C] hptrack kill estimate 37254 (35765-40074); was formula (0).
UPDATE mob_groups SET HP=37254 WHERE groupid=13806;
