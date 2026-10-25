# chocobo-raising-core

Phase 0 of the Chocobo Raising port (LandSandBoat -> DSP). Branch `feature/chocobo-raising-core`. Audit: Toolkit PR 1149, issue 1129.

## Contents
- `CItem` exdata Lua accessors: `item:getExData()`, `item:setExData(t)`; `player:addItemExData(id, t[, silence])`, `player:saveItemExData(loc, slot)`.
- Schema: `char_chocobos` (new), `char_pet.chocobo_user_data` blob. Migration: `sql/slices/chocobo-raising-core/up.sql` / `down.sql`.
- `CCharEntity::m_chocoboUserData` (32 bytes) loaded in `LoadChar`.
- Bindings: getChocoboRaisingInfo, setChocoboRaisingInfo, deleteRaisedChocobo, getChocoboUserData, setChocoboUserData, registerChocobo, getFieldChocobo.
- Character delete removes the `char_chocobos` row (login/lobby.cpp).

## Not included
Trainer scripts, mount packet/model, whistle, racing. `ChocoboCustomProperties` bit layout is unverified for this client.

## Status
Syntax-checked (VS2019 /Zs) only. Migration NOT applied to the live DB. No runtime evidence yet.
