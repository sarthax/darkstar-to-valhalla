-- Hide the stock Symphonic Curator rows in city zones (status 0 = visible in the street). The Mog House spawn code unhides it on demand.
-- Uninstall: UPDATE npc_list SET status=0 WHERE name='SymphonicCurat' AND status=2;
UPDATE npc_list SET status=2 WHERE name='SymphonicCurat' AND status=0;
