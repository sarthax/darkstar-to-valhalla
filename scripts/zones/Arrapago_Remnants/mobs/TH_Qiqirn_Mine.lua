-----------------------------------
-- Area: Arrapago Remnants
--  Mob: TH_Qiqirn_Mine (mob_groups groupid 22)
-----------------------------------
-- 2026-09-07: real, dynamically-instantiated ally mine used by Qiqirn_Treasure_Hunter.lua and
-- !testmine (both via instance:insertAlly(22)). Renamed off the pre-existing static
-- Qiqirn_Mine.lua's name to stop luautils::OnEntityLoad's name-based script resolution from
-- loading that file's onMobSpawn (setStatus(DISAPPEAR) on spawn) onto this entity instead --
-- see the mob_groups.sql row 22 comment for the full root-cause trace. No hooks needed here:
-- the Treasure Hunter script drives setSpawn/spawn/updateEnmity/timer/useMobAbility directly.
-----------------------------------
local entity = {}

return entity
