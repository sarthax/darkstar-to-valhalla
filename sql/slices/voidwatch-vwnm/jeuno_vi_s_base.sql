-- Gaunab (Vunkerl_Inlet_[S] z83), base NM, no drops. PLACEHOLDER stats [D]: level 119-120 / HP 161800 aligned to Ig-Alima (Botulus Rex is 94-95 / 145000).
-- Mobs 17117891-17117893 spawn on rifts 17118042-17118044 (positions = rift positions [V entities/npc_list]); group 13814.
DELETE FROM mob_spawn_points WHERE mobid IN (17117891,17117892,17117893);
INSERT INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17117891,'Gaunab','Gaunab',13814,-277,-40.203,-726,0),
 (17117892,'Gaunab','Gaunab',13814,-155,-32.147,115,0),
 (17117893,'Gaunab','Gaunab',13814,-400,-32.0,520,0);
UPDATE mob_groups SET HP=161800, minLevel=119, maxLevel=120, respawntime=0, dropid=0 WHERE groupid=13814 AND zoneid=83;

-- Ocythoe (Grauberg_[S] z89), base NM, no drops. PLACEHOLDER stats [D]: level 119-120 / HP 161800 aligned to Ig-Alima (Botulus Rex is 94-95 / 145000).
-- Mobs 17142449-17142451 spawn on rifts 17142618-17142620 (positions = rift positions [V entities/npc_list]); group 13724.
DELETE FROM mob_spawn_points WHERE mobid IN (17142449,17142450,17142451);
INSERT INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17142449,'Ocythoe','Ocythoe',13724,-510,32.117,-795,0),
 (17142450,'Ocythoe','Ocythoe',13724,-80,-7.32,-385,0),
 (17142451,'Ocythoe','Ocythoe',13724,72,-47.691,285,0);
UPDATE mob_groups SET HP=161800, minLevel=119, maxLevel=120, respawntime=0, dropid=0 WHERE groupid=13724 AND zoneid=89;

-- Kalasutrax (Fort_Karugo-Narugo_[S] z96), base NM, no drops. PLACEHOLDER stats [D]: level 119-120 / HP 161800 aligned to Ig-Alima (Botulus Rex is 94-95 / 145000).
-- Mobs 17171004-17171006 spawn on rifts 17171280-17171282 (positions = rift positions [V entities/npc_list]); group 13750.
DELETE FROM mob_spawn_points WHERE mobid IN (17171004,17171005,17171006);
INSERT INTO mob_spawn_points (mobid,mobname,polutils_name,groupid,pos_x,pos_y,pos_z,pos_rot) VALUES
 (17171004,'Kalasutrax','Kalasutrax',13750,-650,-26.93,-425,0),
 (17171005,'Kalasutrax','Kalasutrax',13750,200,-44.259,-245,0),
 (17171006,'Kalasutrax','Kalasutrax',13750,445,-7.959,170,0);
UPDATE mob_groups SET HP=161800, minLevel=119, maxLevel=120, respawntime=0, dropid=0 WHERE groupid=13750 AND zoneid=96;

-- Gaunab pyxis 17118046 had y=-40.203 (copy of pyxis 1); its rift 17118043 is at y=-32.147 [V client]. Pyxis sits at rift pos elsewhere.
UPDATE npc_list SET pos_y=-32.147 WHERE npcid=17118046;
