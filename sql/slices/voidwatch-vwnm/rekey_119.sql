-- Voidwatch re-key of Meriphataud Mountains (z119) npc_list to client ids (+2) [V: z119 entities.yml pull]
-- Descending order so no id collides mid-update.
UPDATE npc_list SET npcid=17265322 WHERE npcid=17265320 AND name='Survival_Guide';
UPDATE npc_list SET npcid=17265321 WHERE npcid=17265319 AND name='Geomagnetic_Fount';
UPDATE npc_list SET npcid=17265320 WHERE npcid=17265318 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17265319 WHERE npcid=17265317 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17265318 WHERE npcid=17265316 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17265317 WHERE npcid=17265315 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17265316 WHERE npcid=17265314 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17265315 WHERE npcid=17265313 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17265309 WHERE npcid=17265307 AND name='Moogle';
