-- DRAFT, NOT APPLIED. Fixes the two item_furnishing rows that differ from LSB (2026-10-23).
-- Ours: (295,1,0,0,6) and (396,1,515,2,4). LSB: 295 storage1 mog2850 FIRE aura6; 396 storage2 mog515 EARTH aura4.
-- Element is 0-based here (fire 0, earth 3). Verify storage/mog against client DAT before applying.
UPDATE item_furnishing SET moghancement=2850 WHERE itemid=295;
UPDATE item_furnishing SET storage=2, element=3 WHERE itemid=396;
