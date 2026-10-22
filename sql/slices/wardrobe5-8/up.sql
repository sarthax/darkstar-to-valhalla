-- wardrobe5-8 V1 up migration. Idempotent. DO NOT apply to the running test DB without owner approval.
-- Back up first: mysqldump dspdb char_storage char_inventory > wardrobe5-8_pre_up.sql
-- Capacities default to 0 so no character gains Wardrobe 5-8 space until explicitly granted.
ALTER TABLE `char_storage`
  ADD COLUMN IF NOT EXISTS `wardrobe5` tinyint(2) unsigned NOT NULL DEFAULT '0',
  ADD COLUMN IF NOT EXISTS `wardrobe6` tinyint(2) unsigned NOT NULL DEFAULT '0',
  ADD COLUMN IF NOT EXISTS `wardrobe7` tinyint(2) unsigned NOT NULL DEFAULT '0',
  ADD COLUMN IF NOT EXISTS `wardrobe8` tinyint(2) unsigned NOT NULL DEFAULT '0';

-- Restore items parked by down.sql, if any, then drop the parking table.
CREATE TABLE IF NOT EXISTS `char_inventory_w58_backup` LIKE `char_inventory`;
INSERT IGNORE INTO `char_inventory` SELECT * FROM `char_inventory_w58_backup` WHERE `location` BETWEEN 13 AND 16;
DELETE FROM `char_inventory_w58_backup` WHERE `location` BETWEEN 13 AND 16
  AND (`charid`,`location`,`slot`) IN (SELECT `charid`,`location`,`slot` FROM `char_inventory`);

-- Restore capacities saved by down.sql, then drop that backup so a later re-run cannot apply stale values.
UPDATE `char_storage` s JOIN `char_storage_w58_backup` b ON b.`charid` = s.`charid`
  SET s.`wardrobe5` = b.`wardrobe5`, s.`wardrobe6` = b.`wardrobe6`, s.`wardrobe7` = b.`wardrobe7`, s.`wardrobe8` = b.`wardrobe8`;
DROP TABLE IF EXISTS `char_storage_w58_backup`;
