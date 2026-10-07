# `!garden` — Mog House gardening debug command (DSP)

Permission 1. Usage: `!garden <action> {value} {slot}`. Acts on every pot you own unless you give a slot number.

## Setup
1. Rebuild the map server and restart it (new C++: `gardenDebug` Lua binding in `lua_baseentity.cpp`, logic in `gardenutils.cpp`).
2. Import the gardening table if you haven't yet: `py -3 tools/DBtool.py` (or import `sql/gardening_results.sql` directly; it DROP/CREATEs the table).
3. Stand inside your Mog House with a pot placed in the Mog Safe or Safe 2. Pots only grow there.

## Actions
| Action | Effect |
|---|---|
| `info` | Lists plant, stage, crystals, strength, dried and examined flags, and time to the next stage |
| `plant 1-8` | Empties the pot and sows that type: fruit, herb, grain, vegetable, cactus, tree cuttings, tree saplings, wildgrass |
| `stage 1-11` | Jumps to that stage (10 is mature, 11 is wilted) |
| `grow [n]` | Advances n stages using the normal growth logic |
| `mature` / `wilt` | Jumps to the harvestable stage, or to wilted |
| `ready` | Makes the current stage due now, so the next tick advances it |
| `crystal1 0-8` / `crystal2 0-8` | Sets the first or second (tree) crystal element |
| `strength 0-31` | Sets the plant's hidden strength |
| `dry 0\|1` / `examined 0\|1` | Sets those flags |
| `results` | Shows what a harvest would give right now; it is a random roll |
| `clean` | Empties the pot |

Every change is saved to the database and re-sent to the client.

## Quick test run
```
!garden plant 1
!garden grow 3
!garden crystal1 6
!garden mature
!garden results
```
Then harvest from the pot normally to test the real harvest path.

## Caveats
- `grow` goes through the same code a crystal feed uses, so growing past a crystal stage skips the feed.
- The client may not redraw the pot model until you zone or re-enter the Mog House.
- Basic message ids 256-258 for the examine messages are still unverified against DSP's client.
- Tested in-game 2026-10-05: full plant -> feed -> mature -> harvest flow works. Not every pot/seed/crystal combination tested.

## Where the code lives
`gardenutils.cpp` (`DebugCommand`), `lua_baseentity.cpp` (`gardenDebug` binding), `scripts/commands/garden.lua`.
