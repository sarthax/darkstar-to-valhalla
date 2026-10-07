-- Krabimanjaro (pool 5168) casts per BG wiki: Water IV, Water V, Waterga III, Waterga IV, Waterja.
-- Spell ids verified against live spell_list. "Various AoE enfeebling spells" are NOT included (spells unnamed on wiki).
-- Pool 5168 currently uses shared spellList 4 (white magic, shared by 167 pools) -- do not edit list 4.
-- spell_list_id 439 was unused (max was 438).
DELETE FROM mob_spell_lists WHERE spell_list_id = 439;
INSERT INTO mob_spell_lists (spell_list_name, spell_list_id, spell_id, min_level, max_level) VALUES
('Krabimanjaro', 439, 172, 1, 255),
('Krabimanjaro', 439, 173, 1, 255),
('Krabimanjaro', 439, 201, 1, 255),
('Krabimanjaro', 439, 202, 1, 255),
('Krabimanjaro', 439, 501, 1, 255),
('Krabimanjaro', 439, 273, 1, 255),
('Krabimanjaro', 439, 357, 1, 255),
('Krabimanjaro', 439, 359, 1, 255),
('Krabimanjaro', 439, 366, 1, 255),
('Krabimanjaro', 439, 214, 1, 255);
-- 273 sleepga, 357 slowga, 359 silencega, 366 graviga: confirmed cast in capture/video (live spell_list names checked)
UPDATE mob_pools SET spellList = 439 WHERE poolid = 5168;
