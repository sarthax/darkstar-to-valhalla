-- Voidwatch re-key of West Ronfaure (z100) npc_list to client ids (+33) [V: z100 entities.yml pull]
-- Descending order so no id collides mid-update. Unusually large offset: verify in game.
UPDATE npc_list SET npcid=17187594 WHERE npcid=17187561 AND name='Survival_Guide';
UPDATE npc_list SET npcid=17187593 WHERE npcid=17187560 AND name='Geomagnetic_Fount';
UPDATE npc_list SET npcid=17187592 WHERE npcid=17187559 AND name='RiftWorn_Pyxis';
UPDATE npc_list SET npcid=17187591 WHERE npcid=17187558 AND name='RiftWorn_Pyxis';
UPDATE npc_list SET npcid=17187590 WHERE npcid=17187557 AND name='RiftWorn_Pyxis';
UPDATE npc_list SET npcid=17187589 WHERE npcid=17187556 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17187588 WHERE npcid=17187555 AND name='Planar_Rift';
UPDATE npc_list SET npcid=17187587 WHERE npcid=17187554 AND name='Planar_Rift';
