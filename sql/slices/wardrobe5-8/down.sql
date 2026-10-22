-- wardrobe5-8 V1 down migration. Run with the map server stopped. Items are PARKED, not deleted.
-- Back up first: mysqldump dspdb char_storage char_inventory > wardrobe5-8_pre_down.sql
CREATE TABLE IF NOT EXISTS `char_inventory_w58_backup` LIKE `char_inventory`;
INSERT IGNORE INTO `char_inventory_w58_backup` SELECT * FROM `char_inventory` WHERE `location` BETWEEN 13 AND 16;
-- Only remove rows that are verifiably in the backup.
DELETE ci FROM `char_inventory` ci
  JOIN `char_inventory_w58_backup` b ON b.`charid` = ci.`charid` AND b.`location` = ci.`location` AND b.`slot` = ci.`slot`
  WHERE ci.`location` BETWEEN 13 AND 16;
-- Gear worn from containers 13-16: an old binary would dereference a null container at login. Park those rows too.
CREATE TABLE IF NOT EXISTS `char_equip_w58_backup` LIKE `char_equip`;
INSERT IGNORE INTO `char_equip_w58_backup` SELECT * FROM `char_equip` WHERE `containerid` BETWEEN 13 AND 16;
DELETE ce FROM `char_equip` ce
  JOIN `char_equip_w58_backup` b ON b.`charid` = ce.`charid` AND b.`equipslotid` = ce.`equipslotid`
   AND b.`slotid` = ce.`slotid` AND b.`containerid` = ce.`containerid`
  WHERE ce.`containerid` BETWEEN 13 AND 16;
-- Capacities are lost on drop; record them first.
CREATE TABLE IF NOT EXISTS `char_storage_w58_backup` AS
  SELECT `charid`,`wardrobe5`,`wardrobe6`,`wardrobe7`,`wardrobe8` FROM `char_storage`;
ALTER TABLE `char_storage` DROP COLUMN IF EXISTS `wardrobe5`, DROP COLUMN IF EXISTS `wardrobe6`,
  DROP COLUMN IF EXISTS `wardrobe7`, DROP COLUMN IF EXISTS `wardrobe8`;
