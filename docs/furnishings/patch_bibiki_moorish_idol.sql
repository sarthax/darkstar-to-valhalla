-- PATCH (not applied, not part of the server sql/). Bibiki Bay fishing guild (guild 519) is missing Moorish Idol.
-- Price: BG Wiki 2,142 gil min + LSB buyMax 14280. Stock numbers (30,6,12) copied from Noble Lady: ASSUMED.
-- Columns: guildid, itemid, min_price, max_price, max_quantity, daily_increase, initial_quantity
INSERT INTO `guild_shops` VALUES (519,5121,2142,14280,30,6,12);
