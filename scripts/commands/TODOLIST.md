# Todo List - Nyzul Isle Investigation Fixes

## Completed
- [x] Fix `nyzuldebug.lua` indexing error for `nyzulInstance`
  - Issue: Module was required but the variable name conflicted with boolean checks
  - Solution: Renamed variable from `nyzulInstance` to `nyzulIsleInvestigation` and updated all references

## Items to Track (if needed)
- [ ] Test the fix in-game after deploy
- [ ] Verify !nyzuldebug layout <N> works correctly
- [ ] Verify !nyzuldebug reroll works correctly
- [ ] Verify !nyzuldebug leader <name> works correctly
