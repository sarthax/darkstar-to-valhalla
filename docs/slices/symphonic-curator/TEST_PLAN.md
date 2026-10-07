# Symphonic Curator — Live Test Plan

Tester fills in Result (PASS/FAIL/N-A) and notes. Use a NON-GM character (GM flag can unlock every song/instrument and invalidates results). Restart the map server after applying the package (Lua globals are cached).

## Setup
- [ ] Patches applied, server rebuilt, new-files copied, server restarted
- [ ] Test char has a Mog House with free furniture slots

## Cases
| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | Enter MH with nothing placed | No Curator NPC | |
| 2 | Place Spinet (3677) only | Curator still NOT shown | |
| 3 | Place Nanaa Mihgo statue (286/287) only | Curator NOT shown | |
| 4 | Place Orchestrion (426) | Curator appears at its spot (no zone needed) | |
| 5 | Remove Orchestrion | Curator disappears | |
| 6 | Re-place Orchestrion, zone out and back | Curator persists | |
| 7 | Trade/click Curator | Menu opens | |
| 8 | Menu with only Orchestrion | Only Orchestrion shown as instrument | |
| 9 | Add Spinet + Orchestrion | Spinet appears in menu | |
| 10 | Add statues | Statue entries appear in menu | |
| 11 | Menu song list, no sheet-music key items | Only default (bit 0) songs available | |
| 12 | Give one wired key item (e.g. 2152) via GM, relog | Matching song pack unlocks; others stay locked | |
| 13 | Select each unlocked song | Music plays; matches the song named | |
| 14 | Select a locked song | Not selectable / does not play | |
| 15 | Cancel menu | Normal music restored, no hang | |
| 16 | Zone with music playing | No hang, no disconnect | |
| 17 | Repeat 1-7 in each of the other 9 city MHs | Same behavior | |
| 18 | Remove all instruments while music set | Curator hidden, no lockout on re-place | |

## Record
- Option -> song mapping mismatches (table is from LSB, unverified):
- Retail event param layout differences:
- Cities tested (of 10):
