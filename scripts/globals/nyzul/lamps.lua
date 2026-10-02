-----------------------------------
-- Nyzul Isle: Runic Lamp floor setup (ACTIVATE_ALL_LAMPS objective, all 3 sub-variants)
-----------------------------------
-- 2026-09-03: ported from LandSandBoat's floor_generation.lua's local lampsActivate() (now
-- public, Nyzul.lampsActivate, since it needs to be called from
-- instances/nyzul_isle_investigation.lua's pickSetPoint). Uses the real lamp coordinate data in
-- floor_layouts.lua (Nyzul.lampSpawnPoints), ported verbatim earlier this session.
-- Only 5 real Runic Lamp entities exist in our npc_list (RUNIC_LAMP_OFFSET..+4) -- same pooled/
-- reposition pattern as the Rune of Transfer and Armoury Crate already use. The REGISTER/ORDER
-- variants below are LSB's real logic, unchanged structurally; ACTIVATE_ALL is the one confirmed
-- earlier this session against a real Nyzul Isle capture (CSID 3 for the lamp's own interaction,
-- see npcs/Runic_Lamp.lua).
-----------------------------------
require("scripts/globals/nyzul/floor_layouts")
require("scripts/zones/Nyzul_Isle/IDs")
require("scripts/globals/status")
-----------------------------------
tpz = tpz or {}
Nyzul = Nyzul or {}

-- Park all 5 lamp entities back at the origin, hidden -- called at the start of every new floor
-- before (maybe) re-placing some of them for an ACTIVATE_ALL_LAMPS floor.
Nyzul.resetLamps = function(instance)
    for i = NyzulIsle.npcs.RUNIC_LAMP_OFFSET, NyzulIsle.npcs.RUNIC_LAMP_OFFSET + 4 do
        local lamp = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)
        if lamp then
            lamp:resetLocalVars()
            lamp:AnimationSub(0)
            lamp:setStatus(STATUS_CUTSCENE_ONLY)
        end
    end
end

Nyzul.lampsActivate = function(instance)
    local floorLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local lampsObjective = instance:getLocalVar("[Lamp]Objective")
    local partySize = utils.clamp(instance:getLocalVar("partySize"), 3, 5)
    local layoutPoints = Nyzul.lampSpawnPoints[floorLayout]

    if not layoutPoints then
        return
    end

    local dTableLampPoints = Nyzul.getLampPoints(floorLayout)

    if lampsObjective == Nyzul.lampsObjective.REGISTER then
        local spawnPoint = math.random(1, #dTableLampPoints)
        local runicLamp1 = instance:getEntity(bit.band(NyzulIsle.npcs.RUNIC_LAMP_OFFSET, 0xFFF), TYPE_NPC)

        if runicLamp1 then
            local pos = dTableLampPoints[spawnPoint]
            runicLamp1:setPos(pos[1] or pos.x, pos[2] or pos.y, pos[3] or pos.z)
            runicLamp1:setStatus(STATUS_NORMAL)
        end

        instance:setLocalVar("[Lamp]PartySize", instance:getLocalVar("partySize"))
    elseif lampsObjective == Nyzul.lampsObjective.ACTIVATE_ALL then
        local runicLamps = math.random(2, math.max(2, partySize - 1))

        for i = NyzulIsle.npcs.RUNIC_LAMP_OFFSET, NyzulIsle.npcs.RUNIC_LAMP_OFFSET + runicLamps do
            local spawnPoint = math.random(1, #dTableLampPoints)
            local lamp = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)

            if lamp then
                local pos = dTableLampPoints[spawnPoint]
                lamp:setPos(pos[1] or pos.x, pos[2] or pos.y, pos[3] or pos.z)
                lamp:setStatus(STATUS_NORMAL)
                table.remove(dTableLampPoints, spawnPoint)
            end
        end

        instance:setLocalVar("[Lamp]count", runicLamps)
    elseif lampsObjective == Nyzul.lampsObjective.ORDER then
        local runicLamps = math.random(2, 4)
        local dTableLampOrder = {}

        for j = 1, runicLamps + 1 do
            table.insert(dTableLampOrder, j)
        end

        for i = NyzulIsle.npcs.RUNIC_LAMP_OFFSET, NyzulIsle.npcs.RUNIC_LAMP_OFFSET + runicLamps do
            local spawnPoint = math.random(1, #dTableLampPoints)
            local lampRandom = math.random(1, #dTableLampOrder)
            local lamp = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)

            if lamp then
                local pos = dTableLampPoints[spawnPoint]
                lamp:setPos(pos[1] or pos.x, pos[2] or pos.y, pos[3] or pos.z)
                lamp:setStatus(STATUS_NORMAL)
                lamp:setLocalVar("[Lamp]order", dTableLampOrder[lampRandom])

                table.remove(dTableLampOrder, lampRandom)
                table.remove(dTableLampPoints, spawnPoint)
            end
        end

        instance:setLocalVar("[Lamp]count", runicLamps)
        instance:setLocalVar("[Lamp]lampRegister", 0)
    end
end

return Nyzul
