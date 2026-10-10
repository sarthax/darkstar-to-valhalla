# TEST_PLAN salvage-zhayolm
1. Run sql/slices/salvage-zhayolm/01..05 in order; re-run once to confirm idempotent.
2. Restart map server; no Lua load errors for Zhayolm_Remnants or globals/salvage.lua.
3. Enter instance 62 from Zhayolm: arrive at (340,0,-593), SALVAGE_START text, timer messages.
4. Mobs of loaded stage spawn at positions; kill progress advances stage; doors unseal.
5. Cell item use/removal, temp chest open, Slot/Socket/Armoury Crate (17076579) respond.
6. Failure (timeout / party fallen) ejects with correct text.

## Apply order (v3)
Apply sql/slices/salvage-zhayolm/00..06 in numeric order (06_mob_droplist.sql is new). Regression: compare spawn count, positions, pools and drops against the live Topaz DB (validate2.py reports 0 errors).
