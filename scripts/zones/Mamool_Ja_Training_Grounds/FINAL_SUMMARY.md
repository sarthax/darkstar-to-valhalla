# Assault Mission 11 Crash - Complete Diagnostic Report

## Executive Summary

**Issue:** GM command `!warpassault 11` crashes the DSP map server when attempting to enter assault mission "Imperial Agent Rescue" in Mamool Ja Training Grounds. Missions 1-4 (Leujaoam Sanctum) work correctly; all Mamool Ja missions crash.

**Root Causes Identified:**

1. **Missing Door Prop Registrations** - Several door props in Mamool Ja instances are not registered in instance_entities.sql, causing navigation/pathfinding issues
2. **Temp Item ID Mismatch** - Zone.lua uses item ID 5344 which may not exist or is incorrect for Mamool Ja
3. **Unbalanced Mob Spawn Groups** - Some mob definitions may be referenced but not properly spawned

**Primary Fix Required:** Register all missing door props in instance_entities.sql and verify the temp item ID used in Zone.lua

---

## Technical Details

### Instance Structure Comparison

#### Working (Leujaoam Sanctum - Mission 1):
- Zone: 69
- Entrance: 79 (Caedarva Mire)
- All door props registered in instance_entities.sql
- Temp item: 5343

#### Failing (Mamool Ja Training Grounds - Mission 11+):
- Zone: 66
- Entrance: 52 (Babaa'ula)
- Some door props MISSING from instance_entities.sql
- Temp item: 5344 (needs verification)

### Files Analyzed

| File | Purpose | Status |
|------|---------|--------|
| `scripts/commands/wa.lua` | GM warp command definition | OK |
| `scripts/zones/Mamool_Ja_Training_Grounds/Zone.lua` | Zone handlers | Needs fix (temp item) |
| `scripts/zones/Mamool_Ja_Training_Grounds/instances/*.lua` | Instance logic | Minor fixes needed |
| `sql/instance_entities.sql` | Entity registrations | Missing data |

---

## Fixes to Apply

### Fix 1: Update Zone.lua Temp Item ID

**File:** `scripts/zones/Mamool_Ja_Training_Grounds/Zone.lua`

**Line 43 Change:**
```lua
- player:addTempItem(5344);
+ player:addTempItem(5343);  -- Use same item as Leujaoam Sanctum
```

---

### Fix 2: Register Missing Door Props

**File:** `sql/instance_entities.sql` (or equivalent SQL file)

Add missing registrations for Preemptive Strike and other missions with unregistered props.

**Example entries to add:**
```sql
INSERT INTO instance_entities (instance_id, npc_id, name, position_x, position_y, position_z, status, animation)
VALUES 
-- Preemptive Strike (mission 12) door props
(12, 17047868, 'DOOR_PROP_1U9', -57.000, 1.000, -101.000, 0, 0),
(12, 17047869, 'DOOR_PROP_1UA', -58.000, 2.000, -102.000, 0, 0),
...

-- Imperial Agent Rescue (mission 11) additional doors if missing
(11, 17047898, 'DOOR_1U1', ..., ...),
...
```

---

### Fix 3: Verify Mob Spawn Groups

Check each instance's `MOB_GROUP_X` array against the actual spawn data to ensure:
- All mob IDs exist in npc_list.sql
- Mob positions match intended locations
- No null references or invalid entity IDs

---

## Testing Checklist

After applying fixes, test with:

```bash
# Test working mission first (baseline)
!warpassault 1
# Should enter Leujaoam Cleansing without issues

# Test previously crashing missions
!warpassault 11  -- Imperial Agent Rescue
!warpassault 12  -- Preemptive Strike  
!warpassault 13  -- Sagelord Elimination
!warpassault 14  -- Breaking Morale
```

Verify:
- [ ] Instance loads without crash
- [ ] All mobs spawn correctly
- [ ] Door props are visible and accessible
- [ ] Rune of Release appears at correct position
- [ ] Ancient Lockbox appears at correct position  
- [ ] Timer starts functioning
- [ ] Progress tracking works as expected

---

## Debug Commands

If issues persist after fixes:

```bash
# Check instance registration
!warpassault 11
-- Enter zone if prompted
!checknav  -- Verify navigation paths (Topaz command)

# Inspect spawned entities
!dumpinstance <instance_id>

# Check for entity errors in console logs
```

---

## Files Created by This Analysis

- `CRASH_DIAGNOSIS.md` - Detailed crash root cause analysis
- `ZONE_COMPARISON.md` - Mamool Ja vs Leujaoam comparison
- `ASSAULT_MISSION_ANALYSIS.md` - Instance structure documentation
- `verify_instances.lua` - Diagnostic script for instances
- `FINAL_SUMMARY.md` - This file

---

## Next Steps

1. Apply Fix 1 (temp item ID change)
2. Register missing door props in SQL
3. Verify mob group integrity
4. Test all 4 Mamool Ja missions
5. Document any remaining issues

---

**Report Generated:** 2026-09-16  
**Analyst:** AI Assistant (Claude Code)  
**Status:** Analysis Complete - Fixes Pending Application
