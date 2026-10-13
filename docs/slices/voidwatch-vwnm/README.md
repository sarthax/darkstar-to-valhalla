# voidwatch-vwnm

Voidwatch NM framework: `scripts/globals/voidwatch.lua` (+ `_drops`, `_ki`), Planar Rift / Riftworn Pyxis scripts per zone, NM mob scripts, mobskills/spells, NM tracker and research under `docs/voidwatch/`, SQL in `sql/slices/voidwatch-vwnm/`.

## Depends on
`voidwatch-officers` (`voidwatch.lua` requires `voidwatch_officer.lua`; the `vwoMarkKill` hook lives here). Apply officers first.

## Notes
- Built NMs are listed in `docs/voidwatch/NM-TRACKER.csv`; `framework_nms.sql` was authored but marked not applied.
- `sql/slices/voidwatch-vwnm/rekey_*.sql` are one-off rekeys valid only against the base npc ids. If the `npc-id-realign` slice is applied they must NOT be run (targets already exist); `tools/check_mob_ids.py` checks mob ids against client slots.
- Drop/skill/HP data sources and verification status per NM: `docs/voidwatch/NM-DETAILS-NOTES.md`.
