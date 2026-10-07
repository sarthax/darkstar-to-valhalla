-- Voidwatch re-key of La Theine Plateau (z102) npc_list block 689-696 to client ids (-1) [V: z102 entities.yml pull]
-- Ascending order so no id collides mid-update (688 is free). Fount/Guide left alone (not used by VW scripts).
UPDATE npc_list SET npcid=17195688 WHERE npcid=17195689 AND name='Mogball-Local';
UPDATE npc_list SET npcid=17195689 WHERE npcid=17195690 AND name='Mog-Tablet';
UPDATE npc_list SET npcid=17195690 WHERE npcid=17195691 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17195691 WHERE npcid=17195692 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17195692 WHERE npcid=17195693 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17195693 WHERE npcid=17195694 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17195694 WHERE npcid=17195695 AND name='Riftworn_Pyxis';
UPDATE npc_list SET npcid=17195695 WHERE npcid=17195696 AND name='Riftworn_Pyxis';
