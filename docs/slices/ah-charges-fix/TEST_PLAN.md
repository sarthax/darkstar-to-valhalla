# Valhalla AH Charges Fix - Live Test Plan

Verified on base DSP 2026-10-04; NOT yet applied to Valhalla. Build must be Release x64.

| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | Apply both snippets (`1_inventory_item.cpp.txt`, `2_packet_system.cpp.txt`), build Release x64, restart both 64-bit servers | Builds, starts | |
| 2 | `!additem 13688` and `15841` (new charged items) | Item posts to AH with no "Partially depleted" message | |
| 3 | Buy the item | Arrives with full charges | |
| 4 | Use a charge, try to post | Refused (error 197) | |
| 5 | Non-charged items | Post normally | |
| 6 | Recharging item (0x90 state) | Handled, not postable if depleted | |
| 7 | Bazaar/trade/inspect of charged items | Unaffected | |
| 8 | `inspect_char_charges.py --char <name> --item 13688` | Lists charges, flags PARTIAL correctly | |
| 9 | Stack-size mismatch (12 vs 99) items | Check the README table against live client DATs | |
