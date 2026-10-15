-- Lebros Cavern 21 live-test fixes, 2026-09-19.  Back up dspdb first, then run against dspdb.
-- Issue 4: Brittle_Rock pool had skill_list_id=236 (Structure family skills: Gaea Stream / Cronos Sling) -> rock used mob skills.
UPDATE mob_pools SET skill_list_id=0 WHERE poolid=534;
-- Issue 3: Structure family mobsize 0 -> 3 (melee reach = 3 + mobsize; same fix as Topaz).
UPDATE mob_family_system SET mobsize=3 WHERE familyid=236;
-- Issue 2: Brittle Rock 2's wall prop (_1ry) was seeded animation 8 (open/invisible); all 5 must be 9 (closed).
UPDATE npc_list SET animation=9 WHERE npcid BETWEEN 17035537 AND 17035541;
-- Issue 5: Qiqirn Mine ally used by scripts/globals/items/qiqirn_mine.lua (insertAlly(10633)).
INSERT INTO mob_pools VALUES (5872,'Qiqirn_Mine','Qiqirn_Mine',236,0x0000FE0600000000000000000000000000000000,1,1,7,240,100,0,0,0,0,0,0,0,0,3,0,0,0,1,0,0);
INSERT INTO mob_groups VALUES (10633,5872,63,0,128,0,0,0,75,75,1);
