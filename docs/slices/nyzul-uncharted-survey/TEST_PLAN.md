# Nyzul Isle Uncharted Area Survey (Assault 52) - Live Test Plan

Delta package; apply `nyzul_isle_investigation` first (shared floor pools, NM scripts, `nyzul.lua`).

| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | Install (SQL order per manifest incl. instance_list, instance_entities 386 rows), restart | No errors | |
| 2 | Enter Assault 52 | Instance loads | |
| 3 | Rune of Transfer floor-cap menu | Menu works, caps apply | |
| 4 | 19 leader NMs | Spawn, fight, drop correctly | |
| 5 | 5 boss-floor HNMs | Spawn on correct floors, groups/pools correct | |
| 6 | Astraria | Behaves as designed | |
| 7 | Per-mission charvars and drops | Set and consumed correctly | |
| 8 | Whitegate reward NPCs (8 npc_list rows) | Present, rewards work | |
| 9 | Completion, timer failure, wipe | Clean | |
| 10 | Investigation (51) afterwards | Unaffected | |
