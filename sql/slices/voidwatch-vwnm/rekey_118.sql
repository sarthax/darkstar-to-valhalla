-- Voidwatch re-key of Buburimu Peninsula (z118) npc_list to client ids (+2) [V: z118 entities.yml pull]
-- Descending order so no id collides mid-update.
UPDATE npc_list SET npcid=17261225 WHERE npcid=17261223 AND name='Survival_Guide';
UPDATE npc_list SET npcid=17261224 WHERE npcid=17261222 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17261223 WHERE npcid=17261221 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17261222 WHERE npcid=17261220 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17261221 WHERE npcid=17261219 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17261220 WHERE npcid=17261218 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17261219 WHERE npcid=17261217 AND name='Planar_Rift';
