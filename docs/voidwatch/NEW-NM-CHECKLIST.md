# New Voidwatch NM checklist

Run through this whenever a Voidwatch NM is added. Skipping the shared lists silently drops rewards.

1. **Petrifact paths** (`VW_PETRIFACTS` in `scripts/globals/voidwatch.lua`). Rate is `VW_PETRIFACT_RATE` (5%, design guess).
   - Beguiling 1556: Ashen (`region = "ZILART"`), Jeuno (`"JEUNO"`), city (`"THREE"`).
   - Seductive 1557: Hyacinth/Tavnazia (`"HYACINTH"`), Jeuno, city.
   - Maddening 1558: Aht Urhgan (`"AMBER"`), Jeuno, city.
   - "City" = every Indigo/Crimson/Jade NM (`region = "THREE"`). Set the new NM's `region` in `vwOnKill`'s cfg correctly and it is picked up automatically.
   - New path (Hyacinth, Amber, ...): use the region string above in cfg; the table rows already exist.
2. **Per-item drop rates**: add `dropRates = {[itemId] = percent}` to the cfg (source: FFXIclopedia/BG/JP wiki item pages). Without it the NM falls back to the flat 10% rare roll.
3. **NM key items**: its own KI via `cfg.keyitem`, extras via `vwExtraKeyItem` (`voidwatch_ki.lua`).
4. **`onMagicHit` must `return 0`** after `vwOnMagicHit(...)`.
5. **Mob MP**: if it casts, main or sub job must be a mage job (PLD/WHM/BLM/RDM/DRK/BLU/SCH/SMN) or `CalculateStats` ignores the group MP.
6. **Ids**: spawn/Pyxis/rift ids from a fresh client dat pull (see NM-TRACKER); own skill list id, not a shared stock list.
7. Update `NM-TRACKER`, `NM-DETAILS-NOTES.md` (then regenerate `NM-DETAILS`) and republish the pinned artifact.
