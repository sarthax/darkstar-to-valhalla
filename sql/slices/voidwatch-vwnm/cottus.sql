-- Cottus (Crimson I, East Ronfaure [S] zone 81). Rift/Pyxis/mob ids already match the client (17109850-55 / 17109718-20): no re-key.
-- [J] wikiwiki.jp, [F] FFXIclopedia, [B] BG forum, [D] design guess.
-- Skills in DB [J]: Power Attack 666, Impact Roar 664, Grand Slam 665.
-- NOT built (see docs/voidwatch/UNIMPLEMENTED.md): Trebuchet, Mercurial Strike, Colossal Slam, ranged attack.
DELETE FROM mob_skill_lists WHERE skill_list_id=1162;
INSERT INTO mob_skill_lists (skill_list_name,skill_list_id,mob_skill_id) VALUES ('Cottus',1162,664),('Cottus',1162,665),('Cottus',1162,666);
UPDATE mob_pools SET skill_list_id=1162, spellList=0 WHERE poolid=4656;   -- [J] no spells
-- group: no timed respawn, no stock drops (vwOnKill grants the drop)
UPDATE mob_groups SET respawntime=0, dropid=0 WHERE groupid=11004;
