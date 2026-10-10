# salvage-silversea

Ports Silver Sea Remnants Salvage I (instance 71) from Topaz to DSP. Stacked on `feature/salvage-zhayolm` (needs `scripts/globals/salvage.lua`). Original work: valhalla branch `salvage-wip-2026-10-09`.

## Contents
- `scripts/zones/Silver_Sea_Remnants/` - `IDs.lua` (global `SilverSea`), `Zone.lua`, instance script, Armoury_Crate/Slot/Socket, 8 mob scripts. The stale DSP `TextIDs.lua` is removed.
- `sql/slices/salvage-silversea/00..05` - run in order, idempotent (DELETE then INSERT / UPDATE).

## Decisions
- Text ids checked by TEXT against a fresh zone-76 dialog.yml pull. Topaz values 6383/6389/6390/6392/7213 were off; the login-campaign ids 7000-7002 were dropped (they do not match the client).
- Unlike Zhayolm, the build positions 110 spawn rows DSP does not have: 95 are inserted, the rest updated. Groups are matched by pool to existing DSP zone-76 groups; 7 new groups use reserved ids 30000+ (all other slices < 18500). New groups have dropid 0.
- 5 build-only pools (6507 Haunt_SSR, 6533 Doom_Mage_SSR, 6555/6556 Guard_Skeleton_SSR, 6722 Orobon_AR) are inserted into `mob_pools`; they do not exist in DSP.
- Spawn rows in the build still at (0,0,0) are not carried (instance loader skips them).
- Long-Armed Chariot has two candidate ids (17088786 / 17089250); neither is confirmed, both listed.

## Known gaps
- 15 positioned mobs use live group pool 0 (Qiqirn x12, Apkallu Avenger, Seafarer Piliproon, Fomor Windwalker): no pool, so they are NOT carried and will not spawn.
- Only the entry, failure and exit mechanics exist; no floor/door progression (LSB has none; none invented).
- 4 Armoury Crate pool ids (17088820-17088823) and 2 Runic Lamps (17089356/7) are still unpositioned, so `spawnTempChest`'s pool loop does nothing beyond the fixed crate.
- Runic Lamps 17089354/5/67 are listed in IDs but may be Salvage II content.
- Slot position conflict (Slot vs Don Poroggo) unresolved.
