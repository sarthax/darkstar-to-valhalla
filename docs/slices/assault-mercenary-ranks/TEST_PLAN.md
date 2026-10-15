# Mercenary Rank Promotions - Live Test Plan

Shared infrastructure; test FIRST, before any zone Assault package. Rank resets: `!resetmercrank`, `!resetlcquest`. Funding: `!addassaultpoints`.

| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | Install: import `sql/npc_list.sql` (25 rows), copy Lua, restart | No errors; Whitegate NPCs present (Naja Salaheem, Abquhbah, Nafiwaa, Yahsra, Isdebaaq, Famad, Lageegee, Bhoy Yhupplo) | |
| 2 | Naja Salaheem: new char, PSC promotion | Granted with correct text/cost | |
| 3 | PFC promotion | Granted only after prerequisites | |
| 4 | Try promotion out of order / without points | Refused, no state change | |
| 5 | Lance Corporal quest (Abquhbah): start | Quest starts | |
| 6 | LC real-time gating: wait one full Vana'diel day, zone out and back into Whitegate | Quest advances only after wait + rezone | |
| 7 | LC quest across the 3 zones | Each stage fires; completion promotes to LC | |
| 8 | SP trial: examine Warhorse Hoofprint in each of the 4 zones | SP granted (Dark Rider NM not implemented, expected) | |
| 9 | Corporal: examine hoofprint with/without Quartz Transmitter | Branch wired but Corporal quest does not exist; note it cannot fire | |
| 10 | Per-zone givers (Yahsra/Isdebaaq/Famad/Lageegee/Bhoy Yhupplo): orders, shop | Grant `<ZONE>_ASSAULT_ORDERS`, open that zone's mission menu, shop sells expected items | |
| 11 | Promotion point cap (`capPromotionPoints`) after a mission | Points cap per rank as designed | |
| 12 | Mythralline Wellspring rows (4 Wajaom Woodlands + 1 Bhaflau Thickets) | Objects present and clickable | |
| 13 | `!resetmercrank` / `!resetlcquest` | Cleanly reset state | |
| 14 | DSP `besieged.lua` merge | Existing DSP Besieged still works; only added functions used | |

Known limits: per-zone IDs.lua must define `ASSAULT_POINTS_OBTAINED` and the zone point constant; LC-Captain not implemented.
