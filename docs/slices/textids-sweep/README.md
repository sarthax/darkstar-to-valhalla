# TextIDs sweep

267 `scripts/zones/*/TextIDs.lua` files: general-block ids (ITEM_OBTAINED, GIL_OBTAINED, KEYITEM_OBTAINED, HOMEPOINT_SET, guild/fishing offsets, ...) shifted toward the real client dialog tables
(the Moghancement-era commit states these were verified against client dialog tables; the earlier baseline-commit portion was not separately re-verified here). 1196 ids changed: 1055 by +2, 132 by +3, a few by +4/+10, one zone (Bastok Markets [S]) corrected from a wrong 11219 to 6382.
No keys added or removed. The two `ALLIED_SIGIL` lines (Bastok Markets [S], Windurst Waters [S]) belong to the campaign slice and are not included here.

Pure data. No SQL, no rebuild. Restart or `!reloadzone` to pick up.
Test: in a few zones (incl. an Abyssea zone) pick up an item, receive gil, obtain a key item, set a home point; text must read correctly, not shifted by 2-3 lines.
Valhalla: only take this if your client's dialog tables match ours; their zone files may already be correct.
