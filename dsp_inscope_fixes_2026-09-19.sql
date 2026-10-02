UPDATE mob_groups SET poolid=6995,minLevel=75,maxLevel=75 WHERE groupid=1962 AND zoneid=56; -- Excaliace was Merrow_No16 lvl1
DELETE FROM instance_entities WHERE instanceid=33 AND id IN (17006814,17006815,17006816,17006817,17006822); -- stray Bridge_Switch/Adeeha (Building Bridges/Wake the Puppet)
UPDATE npc_list SET flag=6,status=0 WHERE npcid=17002656; -- Uzhahn had status 6 (hidden) flag 0
UPDATE mob_spawn_points SET pos_z=315 WHERE mobid=17002537; -- stray leech z=3747.511 (Topaz 315)
UPDATE mob_pools SET aggro=1,links=1 WHERE poolid IN (254,3119,649,652,654,655,4093,4094,4095,4096); -- match Topaz for Ilrusi 43/44 + Periqia 31/34 mobs

-- 2026-09-20 mission 31: crab 17006597 to Topaz pos; Debaucher 17006603 moved per user LOGPOS
UPDATE mob_spawn_points SET pos_x=-305.0,pos_y=-15.4,pos_z=258.0,pos_rot=255 WHERE mobid=17006597;
UPDATE mob_spawn_points SET pos_x=-296.1283,pos_y=-15.1792,pos_z=97.006 WHERE mobid=17006603;
