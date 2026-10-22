-- Hide the stock Symphonic Curator npc rows at the Mog House position (2,-1,-7.5); status 0 leaves them standing in city streets.
-- CZoneEntities::SpawnMoogle unhides the curator inside the Mog House on demand, so status 2 is correct for these rows.
-- Matches by position + polutils_name, not name: Whitegate's row is 'Symphonic_curator' (lowercase c). 11 rows expected.
-- Re-run after any npc_list.sql reimport (dbtool resets status to 0). Stop the map server first, restart after.
-- Uninstall: UPDATE npc_list SET status=0 WHERE polutils_name='Symphonic Curator' AND status=2 AND pos_x=2 AND pos_y=-1 AND pos_z=-7.5;
UPDATE npc_list SET status=2 WHERE polutils_name='Symphonic Curator' AND status=0 AND pos_x=2 AND pos_y=-1 AND pos_z=-7.5;
