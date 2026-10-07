-- Lord Asag (Jade III / Windurst Stage III, Meriphataud Mountains zone 119). Client ids (see rekey_119.sql) [V].
-- Rifts 17265315-17, Pyxis 17265318-20, mobs 17265130-32 (group 13828, pool 5189). Spawn rows already non-zero; NM appears at rift (vwSpawnAtRift setPos).
-- Skills (list 1165) [C,J,F]: Bloodrake 2106, Nosferatu's Kiss 2108, Heliovoid 2109, Wings of Gehenna 2110.
-- NOT built: Nocturnal Servitude (no DSP mob_skills row) - see UNIMPLEMENTED.md.
DELETE FROM mob_skill_lists WHERE skill_list_id=1165;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Lord_Asag',1165,2106),('Lord_Asag',1165,2108),('Lord_Asag',1165,2109),('Lord_Asag',1165,2110);
-- Spells [J,F]: Lua picks (tiered by HP). >=50%: Silencega 359, Paralyga 356, Addle 286, Fire IV 147, Firaga III 176; <50%: Death 367, Fire V 148, Firaga IV 177, Firaja 496.
DELETE FROM mob_spell_lists WHERE spell_list_id=448;
INSERT INTO mob_spell_lists (spell_list_name,spell_list_id,spell_id,min_level,max_level) VALUES
 ('Lord_Asag',448,359,1,99),('Lord_Asag',448,356,1,99),('Lord_Asag',448,286,1,99),('Lord_Asag',448,147,1,99),('Lord_Asag',448,176,1,99),
 ('Lord_Asag',448,367,1,99),('Lord_Asag',448,148,1,99),('Lord_Asag',448,177,1,99),('Lord_Asag',448,496,1,99);
-- immunity [F]: silence 0x10 (no dispel bit)
UPDATE mob_pools SET skill_list_id=1165, spellList=448, hasSpellScript=1, immunity=(immunity|16) WHERE poolid=5189;
