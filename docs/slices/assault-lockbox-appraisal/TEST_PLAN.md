# Assault Lockbox Appraisal - Live Test Plan

NPCs: Drahbah, Chochoroon, Memeroon (existing npc_list rows; no SQL). Package REPLACES DSP's disabled stubs; keep DSP's own intro csids (e.g. Chochoroon 0x0104). Deliberately partial.

| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | Click each NPC | Intro cutscene plays with DSP csid, no hang | |
| 2 | Trade "??? Earring" + gil fee to NPC | Thinking line, then result text ~2s later, real earring reward | |
| 3 | Repeat ~20 times | Reward weights look like the confirmed drop weights | |
| 4 | Trade "??? Box" | One of 14 items (equal chance) | |
| 5 | Trade any unsupported "???" (Ring/Cape/Necklace/Axe/Polearm/Headpiece/Sword/Gloves/Bow) | Item returned untouched, "cannot be appraised yet" message, nothing eaten | |
| 6 | Trade without enough gil | Refused, item and gil returned | |
| 7 | Solo player | Item delivered directly | |
| 8 | Party member | Reward goes through Treasure Pool | |
| 9 | Full inventory | Defined behavior, no lost item | |
| 10 | Wrong item / extra items in trade | Refused cleanly | |
| 11 | Check map log | No nil errors from `appraisal.lua` / `npc_util` | |

Known gaps: only 2 of 7 types have pools; result item name is plain text, not a client dialogue; solo-vs-party routing has only one use case.
