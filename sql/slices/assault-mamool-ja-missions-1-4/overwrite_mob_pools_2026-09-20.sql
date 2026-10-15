-- Overwrite (2026-09-20): package mob_pools.sql INSERT hit a duplicate key on the base row and never replaced it.
-- Live tested value is 1151, base is 1149.
UPDATE `mob_pools` SET `skill_list_id`=1151 WHERE `poolid`=3437;
