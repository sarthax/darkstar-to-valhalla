# Mog House 2F / Remodel / Patio — Live Test Plan

Use a fresh non-GM character per nation where possible. Edit `mhflag` in DB only while the character is logged out.

## Setup
- [ ] Patches applied, rebuilt, SQL run, server restarted

## Cases
| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | `mhflag=7`, zone into home-nation MH | Unlock CS plays; mhflag gains 0x20 + style bits | |
| 2 | Repeat per nation (San d'Oria, Bastok, Windurst) | CS ids correct per zone table; if hang, set `cs = nil` | |
| 3 | Zone into MH without flag | No unlock CS, 2F unavailable | |
| 4 | Exit menu -> 2F | Moves to 2F, correct position | |
| 5 | Exit menu on 2F -> 1F | Returns correctly | |
| 6 | Remodel NPC: each style | Style applies; persists after zone | |
| 7 | Remodel while standing on 2F (rezone path) | Known untested; note outcome | |
| 8 | Mog Safe 2 on 2F | Note whether gated (known not gated on 0x20) | |
| 9 | GM-give item 6499, use it | KI 3051 granted | |
| 10 | Patio remodel option | Appears only with KI 3051 | |
| 11 | Apply Patio remodel | Patio renders, persists | |
| 12 | Relog | All states persist | |
| 13 | Non-home-nation chars / other nations' MH | No wrong-nation unlock | |

## Record
- Nation flag quests (Growing Flowers, A Lady's Heart, Flower Child) not played through; test with real quest completion when possible.
