# Crash Diagnosis for Assault Mission 11 (Imperial Agent Rescue)

## Issue Report

**Symptom:** GM command `!warpassault 11` crashes the map server when attempting to enter assault mission 11 (Imperial Agent Rescue, Mamool Ja Training Grounds).

**Working:** Missions 1-4 (Leujaoam Sanctum) work perfectly.
**Failing:** Mission 11 and other Mamool Ja missions crash.

---

## Root Cause Analysis

### Primary Finding: Zone ID Mismatch in onInstanceCreated

**Location:** `scripts/zones/Mamool_Ja_Training_Grounds/Zone.lua` (lines 90-94)

```lua
function onInstanceCreated(player, target, instance)
    if (instance) then
        player:setInstance(instance);
        player:setPos(0, 0, 0, 0, 66);  -- Zone 66 is MAMOOT_JA
    end
end
```

**Issue:** When `!warpassault` spawns an instance via GM command, the fallback handler in `Zone.lua:onInstanceCreated()` sets the player's zone to **zone ID 66**, but the actual assault instance expects zone **ID 69** (Leujaoam Sanctum) as specified in `wa.lua`.

### Evidence from wa.lua:

From `scripts/commands/wa.lua` line 42-51:
```lua
[1] = { zone = 69, entrance = 79, name = 'leujaoam_cleansing' },   -- Mission 1
[2] = { zone = 69, entrance = 79, name = 'orichalcum_survey' },   -- Mission 2
...
[11] = { zone = 66, entrance = 52, name = 'imperial_agent_rescue' }, -- Mission 11
```

**This is correct** - mission 11 SHOULD be in zone 66 (Mamool Ja). The issue is elsewhere.

---

### Secondary Finding: onInstanceZoneIn Temp Item Mismatch

**Location:** `scripts/zones/Mamool_Ja_Training_Grounds/Zone.lua` (lines 36-43)

```lua
function onInstanceZoneIn(player, instance)
    local pos = player:getPos();
    if (pos.x == 0 and pos.y == 0 and pos.z == 0) then
        local entrypos = instance:getEntryPos();
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot);
    end

    player:addTempItem(5344);  -- Mamool Ja temp item
end;
```

**Issue:** The temp item ID **5344** was ported from Topaz but may not be the correct item for this zone. Leujaoam Sanctum uses **5343**. If these items have different effects or if item 5344 doesn't exist, it could cause:
- Inventory corruption warnings
- Entity spawn failures
- Potential crashes when trying to equip/use the item

---

### Third Finding: Missing onInstanceLoadFailed Handler Consistency

**Location:** `scripts/zones/Mamool_Ja_Training_Grounds/Zone.lua` (lines 78-80)

```lua
function onInstanceLoadFailed()
    return 66;  -- Returns Mamool Ja zone ID
end;
```

This is **correct** for Mamool Ja. The comparison with Leujaoam shows both zones handle this correctly with their respective zone IDs.

---

## Most Likely Crash Cause: Navigation/Door Prop Issues

### Preemptive Strike (Mission 12) Door Props Unregistered

From `preemptive_strike.lua` lines 30-33:
```lua
local DOOR_PROPS = {
    17047868, 17047869, 17047870, 17047871,
    17047874, 17047875, 17047876, 17047877, 17047878,
}
```

**Issue:** These 9 door props were documented as "never registered in sql/instance_entities.sql" (line 22-23). While this doesn't necessarily cause a crash, it could cause:
- Door props appearing in closed/corrupted state
- Navigation pathfinding issues if the client tries to interact with unregistered geometry
- Potential null reference errors when trying to set animation/status

---

## Recommended Fixes (In Priority Order)

### Fix 1: Verify Temp Item ID

**Action:** Check what temp item ID Topaz actually used for Mamool Ja.

**Files to check:**
```bash
cd D:\Claude\old-dsp-reference
# Compare with Topaz's implementation
git log --all --full-history -S "5344" -- scripts/zones/Mamool_Ja_Training_Grounds/Zone.lua
```

**Recommended change:** If item 5344 is incorrect, swap it for the correct ID.

---

### Fix 2: Ensure All Door Props Are Registered

**Action:** Check `sql/instance_entities.sql` (or equivalent) to ensure all door props are registered.

**For Preemptive Strike (Mission 12):**
```sql
-- Add missing registrations if not present:
INSERT INTO instance_entities (instance_id, npc_id, name, position_x, position_y, position_z)
VALUES 
    (12, 17047868, '_1u9', ...),
    (12, 17047869, '_1ua', ...),
    -- etc for all 9 props
```

---

### Fix 3: Add Crash-Safe Guards to onInstanceCreated

**Recommended addition to `Zone.lua:onInstanceCreated()`:**
```lua
function onInstanceCreated(player, target, instance)
    if (instance) then
        player:setInstance(instance);
        player:setPos(0, 0, 0, 0, 66);
        
        -- Crash-safe guard: ensure instance is properly initialized
        local instanceId = instance:getID();
        if not instanceId or instanceId <= 0 then
            -- Log error and return without crashing
            print("CRITICAL: Instance has invalid ID. Possible corruption.")
            player:setPos(player:getPosX(), player:getPosY(), player:getPosZ(), 0)
            return
        end
        
        -- Verify we have valid mob groups for this instance ID
        local mobGroup = _G["MOB_GROUP_" .. tostring(instanceId)] or nil;
        if mobGroup then
            -- Already handled in instance's own onInstanceCreated()
        end
    end
end
```

---

## Testing Procedure

1. **Test with Mission 1 (Working):**
   ```bash
   !warpassault 1
   # Verify: Instance loads, mobs spawn correctly, doors appear properly
   ```

2. **Test with Mission 11 (Crashing):**
   ```bash
   !warpassault 11
   # Before fix: Should crash
   # After fix: Should load without crashing
   ```

3. **Check Console Logs:**
   - Look for "undefined", "nil", or entity corruption warnings
   - Check navmesh/pathfinding errors

4. **Compare Entity Counts:**
   - Count mobs spawned in working instance
   - Count mobs spawned in failing instance
   - Differences indicate missing registrations

---

## Files Modified (After Fixes Applied)

- `scripts/zones/Mamool_Ja_Training_Grounds/Zone.lua` - Fix temp item ID, add crash guards
- `sql/instance_entities.sql` - Register missing door props for all missions

---

## Conclusion

The crash is most likely caused by:

1. **Navigation issues** from unregistered door props (especially Preemptive Strike)
2. **Invalid temp item** causing entity/equipment corruption
3. **Missing mob registrations** in one or more instances

These should be addressed systematically, starting with verifying the temp item ID and then registering all missing door props.
