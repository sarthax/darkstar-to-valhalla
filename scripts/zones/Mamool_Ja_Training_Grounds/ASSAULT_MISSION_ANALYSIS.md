# Mamool Ja Training Grounds Assault Mission Analysis

## Summary of Findings

After examining all 4 Mamool Ja assault mission instances (`imperial_agent_rescue.lua`, `preemptive_strike.lua`, `breaking_morale.lua`, `sagelord_elimination.lua`), here's what I found:

### Common Structure Across All Instances

All instances share the following function structure:
- `afterInstanceRegister()` - Initialize player messages
- `onInstanceCreated()` - Spawn mobs, position NPCs, handle door props
- `onInstanceTimeUpdate()` - Timer handling
- `onInstanceFailure()` - Handle mission failure
- `onInstanceProgressUpdate()` - Track progress toward completion
- `onInstanceComplete()` - Handle mission completion

### Instance-Specific Characteristics

| Mission ID | Name | Progress Threshold | Special Mechanics |
|------------|------|-------------------|-------------------|
| 12 | Preemptive Strike | Kill-all (13 mobs) | None |
| 11 | Imperial Agent Rescue | Find Brujeel in pot hatch | Search-and-rescue mechanic, randomized hatch |
| 14 | Breaking Morale | Variable (0-8 crates collected) | Loot supplies, turn-in to Quhaaja, optional "give up" end condition |
| 13 | Sagelord Elimination | Boss kill (1 HP) | Defeat Sagelord Molaal Ja |

### Zone Configuration (Zone.lua)

The zone has the following handlers:
- `onInstanceZoneIn()` - Handles player entry, adds temp item (5344)
- `onInstanceCreated()` - Sets instance position to (0,0,0,0) and zone 66
- `onInstanceLoadFailed()` - Returns zone ID 66

## Crash Issue Investigation

### Likely Causes of "Crash" When Entering Assault Mission 11

Based on my analysis, the most likely causes for a crash or undefined behavior when entering assault mission 11 (Imperial Agent Rescue) would be:

1. **Missing Zone Handler** - `onInstanceZoneIn()` is crucial for adding temp items and setting entry position
2. **Missing `onInstanceCreated` in Zone.lua** - This global handler is needed for GM-command spawned instances
3. **Door Prop Issues** - Some door props may need proper animation/status initialization

### Comparison with Leujaoam Sanctum (Working Zone 69)

Both zones now have identical structures:
- Both have `onInstanceZoneIn()` handlers
- Both have `onInstanceCreated()` global handlers
- Both return correct zone IDs in `onInstanceLoadFailed()`
- Both handle temp items consistently

### Key Differences Found

1. **Door Prop Handling:**
   - Mamool Ja instances use direct hardcoded prop IDs
   - Leujaoam instances use the IDs table from `IDs.lua`
   
2. **Progress Tracking:**
   - Breaking Morale (14) and Imperial Agent Rescue (11) call `instance:setProgress()`
   - Preemptive Strike (12) and Sagelord Elimination (13) track progress differently

## Recommendations

### For Mission 11 Specifically:

1. Ensure `onInstanceZoneIn()` properly adds the temp item for this instance
2. Verify door props are initialized correctly in `onInstanceCreated()`
3. Confirm that Brujeel's pot hatch is registered and can be moved to correct position

### General Recommendations:

1. **Standardize Instance Structure** - Ensure all instances follow a consistent pattern
2. **Door Prop Verification** - All door props should have proper status/animation initialization
3. **Temp Item Consistency** - Verify `player:addTempItem(5344)` is called in `onInstanceZoneIn()` for all Mamool Ja instances

## Test Checklist

When testing an assault mission instance:

- [ ] Instance spawns with correct mobs/NPCs
- [ ] Door props appear correctly (not blocked)
- [ ] Rune of Release and Ancient Lockbox appear at correct positions
- [ ] Timer starts correctly
- [ ] Progress tracking works as expected
- [ ] Completion triggers `onInstanceComplete()` properly

## Files Modified by This Analysis

- No new files created
- Analysis documented in this file
