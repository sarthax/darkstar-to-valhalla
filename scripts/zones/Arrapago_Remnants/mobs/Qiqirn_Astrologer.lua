-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Qiqirn Astrologer
-----------------------------------
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/monstertpmoves")
require("scripts/globals/teleports")
require("scripts/globals/pathfind")
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------
function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_HP_STANDBACK, -1)
end

function onMobDisengage(mob)
    local run = mob:getLocalVar("run")
    local instance = mob:getInstance()
    local stage = instance:getStage()
    local prog = instance:getProgress()

    if run == 1 then
        mob:pathThrough(Arrapago.points[stage][prog - 1].point1, 9)
        mob:setLocalVar("run", 2)
    elseif run == 2 then
        mob:pathThrough(Arrapago.points[stage][prog - 1].point2, 9)
        mob:setLocalVar("run", 3)
    elseif run == 3 then
        mob:pathThrough(Arrapago.points[stage][prog - 1].point3, 9)
        mob:setLocalVar("run", 4)
    elseif run == 4 then
        mob:pathThrough(Arrapago.points[stage][prog - 1].point4, 9)
        mob:setLocalVar("run", 5)
    elseif run == 5 then
        mob:pathThrough(Arrapago.points[stage][prog - 1].point5, 9)
        mob:setLocalVar("run", 6)
    elseif run == 6 then
        mob:pathThrough(Arrapago.points[stage][prog - 1].point6, 9)
        mob:setLocalVar("run", 7)
    end
end

function onMobEngaged(mob)
    mob:setLocalVar("runTime", os.time())
end

function onMobFight(mob, target)
    local act = mob:getCurrentAction()
    local isBusy = false
    local runTime = mob:getLocalVar("runTime")
    local instance = mob:getInstance()
    local stage = instance:getStage()
    local prog = instance:getProgress()

    if act == ACTION_MOBABILITY_START or act == ACTION_MOBABILITY_USING or act == ACTION_MOBABILITY_FINISH or act == ACTION_MAGIC_START or act == ACTION_MAGIC_CASTING or act == ACTION_MAGIC_START then
        isBusy = true -- is set to true if mob is in any stage of using a mobskill or casting a spell
    end

    if mob:isFollowingPath() == false then
        if (os.time() - runTime > 10) then
            if (mob:actionQueueEmpty() == true and isBusy == false) then
                if mob:getLocalVar("run") <= 1 then
                    mob:setLocalVar("run", 1)
                    mob:setLocalVar("runTime", os.time())
                    -- 2026-09-05: real fix -- bare `onMobDisengage(mob)` calls a global that doesn't
                    -- exist (it's a field on the `entity` table, not a global function) -- confirmed
                    -- via real log: "attempt to call global 'onMobDisengage' (a nil value)", thrown
                    -- every single time this flee logic tried to trigger, meaning the custom
                    -- flee-toward-telepad behavior has never once executed successfully. Same class
                    -- of bug as Qiqirn_Treasure_Hunter.lua's onMobRoamAction fix earlier this
                    -- session -- fixed to call the real function directly.
                    onMobDisengage(mob)
                elseif mob:getLocalVar("run") <= 6 then
                    mob:setLocalVar("runTime", os.time())
                    onMobDisengage(mob)
                elseif mob:getLocalVar("run") == 7 then
                    DespawnMob(Arrapago.mobs[stage - 1][prog - 1].astrologer, instance)
                end
            end
        end
    end
end

-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- this mob already has
-- a real, non-zero dropid (2052) in mob_groups pointing to a real mob_droplist entry (with
-- genuine TH-tiered rows already present), which the native C++ DropItems()/GetDropList() path
-- already rolls (with real Treasure Hunter support). The Lua addTreasure() calls were stacking a
-- second, TH-blind drop system on top of that -- reverted pending a full mob_droplist audit/
-- correction instead (see chat).
function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
    mob:setLocalVar("run", 0)
end

