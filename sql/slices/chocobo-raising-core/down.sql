-- chocobo-raising-core down: DESTRUCTIVE, drops raised chocobo data.
ALTER TABLE `char_pet` DROP COLUMN IF EXISTS `chocobo_user_data`;
DROP TABLE IF EXISTS `char_chocobos`;
