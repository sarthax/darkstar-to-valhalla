# voidwatch-officers

Voidwatch Officer, Atmacite Refiner and outland officer NPC scripts, built on `scripts/globals/voidwatch_officer.lua` (Voidstone stock/clock, tier gating, NM tier map, refiner menus, atmacite enrich/infuse/purge) and `voidwatch_warps.lua` (refiner teleport options).

Zones: Southern San d'Oria, Bastok Markets, Windurst Waters (officer + refiner); Norg (Kieran), Tavnazian Safehold (Owain), Kazham (Hildegard), Rabao (Gushing Spring), Wajaom Woodlands (refiner). Research: `docs/voidwatch/research/{ATMACITE-DATA,REFINER-CAPTURE-DECODE}.md`.

## Dependencies / notes
- Standalone: requires only `status` and `keyitems`; `voidwatch_warps` is loaded with pcall.
- The kill hook `vwoMarkKill(mob, player)` must be called from `voidwatch.lua` `vwOnKill`; that file belongs to the voidwatch-vwnm slice, which applies the hook.
- No SQL: officer/refiner npc rows already exist in `sql/npc_list.sql` on the base.
- Status in source: San d'Oria / Bastok / Windurst atmacite menus wired; other refiners and officers marked untested.
