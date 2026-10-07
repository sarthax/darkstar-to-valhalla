-- Nyzul Isle door prop _253 (17093353) was blocking level progress: seeded animation 9 (closed),
-- needed animation 8 (open/passable). Fixed live in dspdb and dspdb_fresh on 2026-09-21;
-- this row makes the same fix importable. REPLACE INTO, no DROP/CREATE.
REPLACE INTO `npc_list` (`npcid`, `name`, `polutils_name`, `pos_rot`, `pos_x`, `pos_y`, `pos_z`, `flag`, `speed`, `speedsub`, `animation`, `animationsub`, `namevis`, `status`, `entityFlags`, `look`, `name_prefix`, `content_tag`, `widescan`) VALUES (17093353, '_253', '_253', 0, 366.500, -3.933, -531.000, 1, 40, 40, 8, 0, 0, 0, 6147, 0x0200000000000000000000000000000000000000, 0, 'TOAU', 0);
