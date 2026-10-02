# Mamool Ja vs Leujaoam Zone Comparison

## Key Differences Identified

### 1. Zone.lua Structure

| Feature | Mamool Ja (Zone 66) | Leujaoam Sanctum (Zone 69) | Status |
|---------|---------------------|---------------------------|---------|
| `onInstanceZoneIn` | Adds temp item (5344) | Adds temp item (5343) | ✓ Both present |
| `onInstanceCreated` | Sets zone to 66 | Sets zone to 69 | ✓ Both present |
| `onInstanceLoadFailed` | Returns 66 | Returns 69 | ✓ Both correct |
| `IDs.lua` dependency | No (hardcoded) | Yes | - Different approach |

### 2. TextIDs.lua

| Feature | Mamool Ja | Leujaoam Sanctum | Status |
|---------|-----------|------------------|---------|
| Assault start IDs (11-20) | Present (7457-7466) | Not applicable (uses different range) | ✓ |
| Zone ID correction note | Yes (-1 shift documented) | Yes (documented) | ✓ Both handled |

### 3. Instance Entity Registration

**Critical Issue Found in instance_entities.sql:**

Looking at the SQL data, some Mamool Ja door props may be missing registrations:
- Preemptive Strike uses props `_1u9` through `_1uj` which were never registered
- These props default to hidden (status=0) and are never revealed

**Recommendation:** All door prop families should have instance_entities.sql entries for proper registration.

### 4. Door Prop Handling

| Mission | Door Props Used | Registration Status |
|---------|-----------------|---------------------|
| Imperial Agent Rescue (11) | `GATE_1`, `GATE_2`, `GATE_3` + `_1u5` | Registered in instance_entities |
| Preemptive Strike (12) | `_1u9` through `_1uj` (9 props) | **MISSING from SQL** - never revealed! |
| Breaking Morale (14) | `_1ub`, `_1u5` + others | Partially registered |
| Sagelord Elimination (13) | `GATE_1-3` + Pot Hatch area | Registered in instance_entities |

### 5. Mob Groups

All instances use hardcoded mob ID arrays instead of an IDs.lua table:
```lua
-- All instances follow this pattern:
local MOB_GROUP_X = {
    mob_id_1, mob_id_2, ...
}

function onInstanceCreated(instance)
    for _, v in ipairs(MOB_GROUP_X) do
        SpawnMob(v, instance)
    end
end
```

**Note:** This differs from Leujaoam Sanctum which uses `local ID = Leujaoam` and references `ID.mob[1]`.

### 6. Temp Items Added

| Zone | Item ID in `onInstanceZoneIn` | Description |
|------|-------------------------------|-------------|
| Mamool Ja | 5344 | Unknown (from Topaz's implementation) |
| Leujaoam Sanctum | 5343 | Same type, different ID |

### Potential Crash Causes Analysis

Based on this comparison, potential crash-inducing issues include:

1. **Missing instance_entities.sql registrations** - Unregistered door props could cause navigation crashes
2. **Missing NPC in mob spawn list** - If a mission references a mob that isn't spawned properly
3. **Incorrect zone ID in `onInstanceCreated`** - Could cause zone mismatch errors
4. **Uninitialized door prop animations** - Could cause rendering/navigation issues

## Files to Review

- `sql/instance_entities.sql` - Check for missing door prop registrations
- `scripts/zones/Mamool_Ja_Training_Grounds/npcs/*.lua` - Verify all NPCs are registered
- `scripts/zones/Mamool_Ja_Training_Grounds/mobs/*.lua` - Verify all mobs are properly defined

## Conclusion

Both zones appear structurally sound. The main differences are:
- Mamool Ja uses hardcoded values while Leujaoam uses an IDs.lua table
- Some Mamool Ja door props are unregistered in SQL (Preemptive Strike mainly)

The "crash" mentioned in the issue likely stems from:
1. Unregistered door props blocking navigation
2. Missing mob registrations
3. Zone ID mismatches

These should be addressed by ensuring all door props and NPCs are properly registered in instance_entities.sql.
