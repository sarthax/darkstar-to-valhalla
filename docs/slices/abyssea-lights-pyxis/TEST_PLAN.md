# Abyssea Lights + Pyxis test plan
Needs a map-server rebuild. Use a GM for setup.

| # | Test | Expected | Status |
|---|---|---|---|
| 1 | Server starts, no Lua errors loading mobs.lua / abyssea_*.lua | clean log | untested |
| 2 | Enter an Abyssea zone, kill normal mobs | lights accumulate; `!showlights` shows them | untested |
| 3 | Kill with melee, a spell, a weaponskill | each credits the right light type | untested |
| 4 | Kill with a pet/avatar | known gap: no lights/Pyxis | known gap |
| 5 | Kill a non-NM mob repeatedly | Sturdy Pyxis can spawn at the mob | untested |
| 6 | Blue Pyxis: play the guessing game, open | treasure awarded; can be destroyed for cruor | CONFIRMED 2026-10-06 |
| 7 | Red Pyxis | opens with rewards | untested |
| 8 | Gold Pyxis (needs Forbidden Key) | opens with rewards | untested |
| 9 | Augment drops from Pyxis | augments apply to item | untested |
| 10 | `!addlights`, `!resetlights` | adjust / clear lights | untested |
| 11 | Rest (healing) and Visitant status in Abyssea | no errors; light hooks run | untested |
| 12 | Non-Abyssea mob kill still works (EXP, drops) | unchanged | untested |
| 13 | Message text in Abyssea zones | readable; if shifted ~2 lines, take textids-sweep | untested |
