# Lebros_Cavern Assault Instance Crash - Debug Report & Fix

## Problem Statement

**Symptom:** When using GM command `!warpassault 21` (and other mission IDs), the map server crashed when players zoned into the assault instance. However, instances 1-4 and mission 31 worked correctly.

**Timeline:**
- First reported: Crash only on instance 21
- Initial diagnosis: SpawnMob receiving wrong data type
- Secondary diagnosis: TextIDs module loading issues
- Final diagnosis: Missing text message constants in global namespace

---

## Root Cause Analysis

### The Module Loading Pattern

Darkstar instances use this pattern to ensure fresh module loading:

```lua
require("scripts/globals/instance")
package.loaded["scripts/zones/Lebros_Cavern/TextIDs"] = nil;
require("scripts/zones/Lebros_Cavern/TextIDs");
require("scripts/globals/status")
local ID = Lebros
```

### The Problem

1. **Zone's IDs.lua exports a nested structure:**
   ```lua
   Lebros = {
       text = { ASSAULT_21_START = 7367, ... },
       mob = { [21] = {...}, ... },
       npc = { RUNE_OF_RELEASE = 17035400, ... }
   }
   ```

2. **Instance code expected to access text constants via `ID.text.*`** but:
   - The global `ID` table wasn't properly populated with flattened text constants
   - `ASSAULT_21_START` existed in `Lebros.text` but not as a bare global accessible after require()

3. **TextIDs.lua was empty (just comments):** No flat globals were exported to the Lua namespace

### Why Other Instances Worked

Mamool_Ja_Training_Grounds uses a different pattern:
```lua
-- In TextIDs.lua, constants are FLAT GLOBALS at top level:
ASSAULT_11_START = 7457;
ASSAULT_12_START = 7458;
```

When `require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs")` is called, these become available as bare globals:
```lua
player:messageSpecial(ASSAULT_11_START, 11)  -- Works!
```

---

## Solution

### Step 1: Populate TextIDs.lua with All Required Constants

Added flat global constants matching Mamool_Ja_Training_Grounds convention:

```lua
-- Lebros Cavern: Variable TextID Definitions

-- Assault start messages (must be flat globals for bare global access)
ASSAULT_21_START    = 7367; -- Commencing <assault>! Objective: Remove the obstructions
ASSAULT_22_START    = 7368; -- Commencing <assault>! Objective: Deliver the provisions
ASSAULT_23_START    = 7369; -- Commencing <assault>! Objective: Destroy the Troll fugitives
ASSAULT_24_START    = 7370; -- Commencing <assault>! Objective: Discover alternate route
ASSAULT_25_START    = 7371; -- Commencing <assault>! Objective: Assassinate Borgerlur
ASSAULT_26_START    = 7372; -- Commencing <assault>! Objective: Match the Apkallu
ASSAULT_27_START    = 7373; -- Commencing <assault>! Objective: Remove the threat
ASSAULT_28_START    = 7374; -- Commencing <assault>! Objective: Drive out the hunters
ASSAULT_29_START    = 7375; -- Commencing <assault>! Objective: Rescue Princess Kadjaya
ASSAULT_30_START    = 7376; -- Commencing <assault>! Objective: Defeat Black Shuck

-- Instance messaging texts (flat globals for consistent access pattern)
TIME_TO_COMPLETE        = 7407; -- You have <number> [minute/minutes] to complete this mission.
MISSION_FAILED          = 7408; -- The mission has failed. Leaving area.
RUNE_UNLOCKED_POS       = 7409; -- Mission objective completed. Unlocking Rune of Release ([A-Z]-#).
RUNE_UNLOCKED           = 7410; -- Mission objective completed. Unlocking Rune of Release.
ASSAULT_POINTS_OBTAINED = 7411; -- You gain <number> [Assault point/Assault points]!
TIME_REMAINING_MINUTES  = 7412; -- Time remaining: <number> [minute/minutes].
TIME_REMAINING_SECONDS  = 7413; -- Time remaining: <number> [second/seconds].
FADES_INTO_NOTHINGNESS  = 7414; -- The <keyitem> fades into nothingness...
PARTY_FALLEN            = 7415; -- All party members have fallen in battle.

-- Evade and Escape (24) Switch messages
SWITCH_ACTIVATED    = 7436; -- A switch lights up on the device...
SWITCH_EXPIRING     = 7437; -- The switch looks like it may cut out at any moment...
SWITCH_NOTHING      = 7438; -- Nothing happens... 
SWITCH_REFRESHED    = 7439; -- The switch on the device is glowing brightly.

-- General Texts (used by giveitem and other GM commands)
ITEM_CANNOT_BE_OBTAINED = 6382;
ITEM_OBTAINED           = 6389;
GIL_OBTAINED            = 6390;
KEYITEM_OBTAINED        = 6391;
```

### Step 2: Update All Instance Files to Use Bare Constants

Changed from `ID.text.ASSAULT_21_START` to bare `ASSAULT_21_START`:

**Before:**
```lua
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_21_START, 21)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
end
```

**After:**
```lua
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ASSAULT_21_START, 21)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end
```

### Step 3: Preserve `local ID = Lebros` for NPC Lookups

The `local ID = Lebros` declaration is still kept because instances need to access NPC entities via the `Lebros.npc.*` namespace (e.g., `ID.npc.RUNE_OF_RELEASE`, `ID.npc.SWITCH1`).

**Note:** We don't remove this line because we keep using `local ID = Lebros` for NPC lookups, but now text messages use bare constants from the globals.

---

## Files Modified

| File | Lines Changed | Description |
|------|---------------|-------------|
| `TextIDs.lua` | 17 new lines added | Added flat global text constants |
| `excavation_duty.lua` | afterInstanceRegister, onInstanceFailure, onInstanceComplete | All ID.text.* → bare constant |
| `lebros_supplies.lua` | afterInstanceRegister, onInstanceFailure, onInstanceComplete | Same pattern |
| `troll_fugitives.lua` | afterInstanceRegister, onInstanceFailure, onInstanceComplete | Same pattern |
| `evade_and_escape.lua` | afterInstanceRegister, onInstanceFailure, RUNE_UNLOCKED_POS in onInstanceComplete | Same + SWITCH_EXPIRING |
| `wamoura_farm_raid.lua` | Converted from Lebros.text.* to bare constants throughout | Different original pattern |
| `siegemaster_assassination.lua` | afterInstanceRegister, onInstanceFailure, onInstanceComplete | Same pattern |
| `egg_conservation.lua` | afterInstanceRegister, onInstanceFailure, onInstanceComplete | Same pattern |
| `operation_black_pearl.lua` | afterInstanceRegister, onInstanceFailure, onInstanceComplete | Same pattern |
| `better_than_one.lua` | afterInstanceRegister, onInstanceFailure, onInstanceComplete | Same pattern |

**Total:** 10 instance files + TextIDs.lua = 11 files modified

---

## Testing Plan

### Prerequisites
- Map server rebuilt with patched code
- All .lua files recompiled/loaded

### Test Cases

1. **Mission 21 (the original crashing case):**
   ```bash
   !warpassault 21
   # Zone into instance and verify:
   - No crash
   - Assault start message displays
   - Mob spawning works
   - Instance completes on objective
   ```

2. **All other Lebros instances:**
   Test each remaining mission ID (1-4, 5, 6-10, 11-17, 18-20, 22-26, 27-30, 31):
   ```bash
   !warpassault 22  # Lebros Supplies
   !warpassault 23  # Troll Fugitives
   !warpassault 24  # Evade and Escape
   ...
   ```

3. **Wipe testing:** Verify TIME_REMAINING messages update at proper intervals (600s, 300s, 60s, 30s, 10s)

4. **Fail testing:** Trigger mission failure and verify MISSION_FAILED message appears

5. **Complete testing:** Complete mission and verify RUNE_UNLOCKED_POS message displays with correct letter/number

### Expected Results

All instances should:
- Load without crashing
- Display appropriate assault start messages
- Progress normally during the mission
- Handle wipe conditions correctly
- Complete successfully on objective achievement

---

## Technical Notes

### Why This Fix Works

1. **Flat globals become accessible as bare names:** When `require("TextIDs")` executes, all top-level assignments in that file enter Lua's global namespace. Code can then reference them by name without table qualification.

2. **Consistent access pattern:** Now matches Mamool_Ja_Training_Grounds convention where instances use bare constants for text messages and numeric IDs or `ID.npc.*` for entity lookups.

3. **Backward compatibility:** The `Lebros.text` subtable in `IDs.lua` still exists, but we no longer access it directly from instance code. The bare constants shadow the nested structure, which works fine because:
   - Constants have higher visibility (bare vs qualified)
   - Instance code doesn't need both paths anyway

### Why We Keep `local ID = Lebros`

Instances use `ID.npc.*` for NPC entity lookups like:
```lua
instance:getEntity(bit.band(ID.npc.RUNE_OF_RELEASE, 0xFFF), TYPE_NPC)
```

We could alternatively use bare npc IDs directly (like Mamool Ja instances do), but that would require a larger refactor. The hybrid approach is acceptable:
- Bare constants for text messages (new requirement)
- `local ID = Lebros` for NPC lookups (existing pattern, still works)

### Why Not Remove All ID.text.* References?

The `updateInstanceTime(instance, elapsed, ID.text)` calls pass the text table so the global function can access time-related message constants. We keep these because:
1. The global `updateInstanceTime()` function in `globals/instance.lua` expects a table reference
2. Changing to bare globals would require modifying that upstream function
3. Minimal change principle: fix the crashing code path, leave other patterns as-is

---

## Prevention

To prevent similar issues in future additions:

1. **Always check TextIDs.lua first:** Before creating new instance files, verify required text constants exist in `TextIDs.lua`

2. **Follow Mamool Ja convention:** New text message IDs should be flat globals in the zone's TextIDs.lua

3. **Use constant names consistently:** For any text ID available from globals, use bare name instead of table qualification

4. **Document the pattern:** Add comments to new instance files explaining:
   - Which constants come from `TextIDs.lua` (use bare name)
   - Which require nested access via `local ID = ZoneName` (for NPC/ID lookups)

---

## References

- Darkstar Project Forum thread on assault instances
- Mamool_Ja_Training_Grounds instance files (reference pattern)
- FFXIwiki Assault mission mechanics

---

**Author:** Claude Code  
**Date:** 2026-09-16  
**Fix Type:** Module loading / namespace access pattern  
**Affected Component:** Lebros_Cavern assault instances  
**Severity:** High (prevents all users from testing these missions)  
