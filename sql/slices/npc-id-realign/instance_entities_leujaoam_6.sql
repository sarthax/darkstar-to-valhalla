-- Instance 6 (Leujaoam Sanctum, Supplies Recovery) door/prop registration follows the npc_id_realign moves.
-- Run once on a DB that still has the old ids. Two-phase (park, then set) to avoid primary-key collisions.
UPDATE instance_entities SET id = id + 1000000000 WHERE instanceid = 6 AND id IN (17060110,17060115,17060116,17060118,17060119);
UPDATE instance_entities SET id = CASE id
  WHEN 1017060110 THEN 17060118 WHEN 1017060115 THEN 17060119 WHEN 1017060116 THEN 17060100
  WHEN 1017060118 THEN 17060105 WHEN 1017060119 THEN 17060106 END
WHERE instanceid = 6 AND id IN (1017060110,1017060115,1017060116,1017060118,1017060119);
