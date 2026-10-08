-- Pashhow Marshlands (109): DSP npc_list is 2 below the client for the Voidwatch block [V/C]. Shift the tail (17224369..17224379) by +2,
-- descending so ids never collide. Rifts 369-371 -> 371-373, Pyxis 372-374 -> 374-376; Fount/Hume/Passage/Survival Guide ride along.
UPDATE npc_list SET npcid=npcid+2 WHERE npcid BETWEEN 17224369 AND 17224379 ORDER BY npcid DESC;
