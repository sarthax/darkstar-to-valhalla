-- Mob id realign 2026-10-12: move battlefield/campaign mob rows onto their client DAT slots.
-- Evidence: same-named entity at the target slot in fresh mission_toolkit pulls; no Lua / bcnm_battlefield refs to old ids.
-- Order matters only for zone 165 (Riko rows move before Ayame takes 17453313). Idempotent: WHERE old id.
UPDATE mob_spawn_points SET mobid=17453329 WHERE mobid=17453313;
UPDATE mob_spawn_points SET mobid=17453330 WHERE mobid=17453314;
UPDATE mob_spawn_points SET mobid=17453313 WHERE mobid=17453297;
UPDATE mob_spawn_points SET mobid=17453311 WHERE mobid=17453295;
UPDATE mob_spawn_points SET mobid=17383486 WHERE mobid=17383482;
UPDATE mob_spawn_points SET mobid=17399855 WHERE mobid=17399851;
UPDATE mob_spawn_points SET mobid=17399856 WHERE mobid=17399852;
UPDATE mob_spawn_points SET mobid=17445218 WHERE mobid=17445214 AND mobname='Shantotto';
UPDATE mob_spawn_points SET mobid=17445219 WHERE mobid=17445215 AND mobname='Shantotto';
UPDATE mob_spawn_points SET mobid=17445220 WHERE mobid=17445216 AND mobname='Shantotto';
UPDATE mob_spawn_points SET mobid=17465572 WHERE mobid=17465568;
UPDATE mob_spawn_points SET mobid=17465573 WHERE mobid=17465569;
UPDATE mob_spawn_points SET mobid=17465574 WHERE mobid=17465570;
UPDATE mob_spawn_points SET mobid=17347137 WHERE mobid=17347056;
UPDATE mob_spawn_points SET mobid=17347138 WHERE mobid=17347057;
UPDATE mob_spawn_points SET mobid=17347139 WHERE mobid=17347058;
UPDATE mob_spawn_points SET mobid=17347140 WHERE mobid=17347059;
UPDATE mob_spawn_points SET mobid=17347141 WHERE mobid=17347060;
UPDATE mob_spawn_points SET mobid=17347160 WHERE mobid=17347075;
UPDATE mob_spawn_points SET mobid=17375845 WHERE mobid=17375760;
UPDATE mob_spawn_points SET mobid=17347127 WHERE mobid=17347046;
UPDATE mob_spawn_points SET mobid=17347128 WHERE mobid=17347047;
UPDATE mob_spawn_points SET mobid=17375829 WHERE mobid=17375748;
UPDATE mob_spawn_points SET mobid=17375830 WHERE mobid=17375749;
UPDATE mob_spawn_points SET mobid=17465598 WHERE mobid=17465594;
UPDATE mob_spawn_points SET mobid=17465599 WHERE mobid=17465595;
UPDATE mob_spawn_points SET mobid=17465600 WHERE mobid=17465596;
UPDATE mob_spawn_points SET mobid=17465601 WHERE mobid=17465597;
