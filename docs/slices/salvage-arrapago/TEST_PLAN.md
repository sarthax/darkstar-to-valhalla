# Test plan: salvage-arrapago
1. Apply earlier slices, then 00..05; restart map server (see topaz_map_server_restart_vs_reimport).
2. Enter instance 65; check SALVAGE_START text, timer messages, temp item.
3. Floors 1-6: mobs spawn per stage, no Lua errors; Archaic Rampart open/close animation cycles (rampart mixin), Archaic Gears change animation at 49%/25% HP (gears mixin).
4. Doors _220.._22i: sealed text, unseal on stage progress; _22g/_22h/_22i gateway handling.
5. Qiqirn Astrologer paths (points table) and Treasure Hunter routes run; chest drop via Armoury Crate pool.
6. Telepad regions 12/13/14 exit with csid 211; failure -> csid 1 exit.
7. Known: Lamia/Merrow no weapon-break animation.

## Apply order (v3)
Apply sql/slices/salvage-arrapago/00..06 in numeric order (06_mob_droplist.sql is new). Regression: compare spawn count, positions, pools and drops against the live Topaz DB (validate2.py reports 0 errors).
