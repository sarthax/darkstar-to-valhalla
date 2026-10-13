-- Instance 6 (Leujaoam Sanctum, Supplies Recovery) door/prop registration follows the npc_id_realign moves.
-- Run once on a DB that still has the old ids (single statement, so no transient collisions).
UPDATE instance_entities SET id = CASE id
  WHEN 17060110 THEN 17060118 WHEN 17060115 THEN 17060119 WHEN 17060116 THEN 17060100
  WHEN 17060118 THEN 17060105 WHEN 17060119 THEN 17060106 END
WHERE instanceid = 6 AND id IN (17060110,17060115,17060116,17060118,17060119);
