-- Overwrite (2026-09-20): qiqirn_mine (Orichalcum Survey) animation is 55 in the tested live DB, 0 in the base row.
UPDATE `item_usable` SET `animation`=55 WHERE `itemid`=5331;
