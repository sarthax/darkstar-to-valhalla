-----------------------------------------
-- ID: 5331
-- Item: Qiqirn Mine
-- Assault: Excavation Duty (Lebros Cavern)
-----------------------------------------
-- DSP port of Topaz globals/items/qiqirn_mine.lua (2026-09-19). DSP had no item script at all, so
-- the item could not be used on a Brittle Rock (same class of gap as Nyzul Vending Chest items).
-- Job: confirm the user is engaged with a Brittle Rock, drop the mine ally (mob_groups 10633) on
-- it, and tag it with player + rock ids. Countdown/blast/kill live in mobs/Qiqirn_Mine.lua.
-- DSP differences: getShortID/getEntity are not used (full ids + GetMobByID/GetPlayerByID), and
-- the ally is spawned with instance:insertAlly(groupid) exactly like Topaz.
-----------------------------------------
require("scripts/globals/status")
local ID = Lebros
-----------------------------------------

local MINE_GROUP_ID = 10633
local LEBROS_ZONE_ID = 63

local function isBrittleRock(mobID)
    for i = 1, 5 do
        if ID.mob[21]["BRITTLE_ROCK" .. i] == mobID then
            return true
        end
    end
    return false
end

function onItemCheck(target)
    if target:getZoneID() ~= LEBROS_ZONE_ID then
        return 55
    end
    return 0
end

function onItemUse(target)
    local rock = target:getTarget()

    if not (target:isEngaged() and rock and isBrittleRock(rock:getID())) then
        -- Not engaged with a Brittle Rock: the mine is wasted (matches retail).
        return
    end

    local instance = target:getInstance()
    if not instance then
        return
    end

    local mine = instance:insertAlly(MINE_GROUP_ID)
    if not mine then
        return
    end

    mine:setSpawn(rock:getXPos(), rock:getYPos(), rock:getZPos(), 0)
    mine:spawn()
    -- must be AFTER spawn(): spawning resets local vars (DBG showed pid=0/rid=0 when set before)
    mine:setLocalVar("PlayerID", target:getID())
    mine:setLocalVar("RockID", rock:getID())
end
