-----------------------------------
-- Area: Lebros Cavern (Excavation Duty)
--  Mob: Qiqirn Mine
-----------------------------------
-- DSP port of Topaz mobs/Qiqirn_Mine.lua (2026-09-19). Placed by globals/items/qiqirn_mine.lua.
-- Cadence is from real capture: "10..." at +2s, "5..." at +7s, then 4/3/2/1/0 each 1s apart;
-- at "0" the mine detonates only if the player is still engaged with the same rock.
-- DSP differences (verified against src/map/lua, not assumed):
--   * mob_skills row 1838 (mine_blast) is commented out in DSP's SQL, so there is no
--     "readies Mine Blast" skill; the explosion uses the captured FourCC "bom0" animation
--     packet (entityAnimationPacket, exists in DSP) plus the real "The mine explodes!" text.
--   * no takeDamage binding: the rock is killed with delHP(maxHP). CBattleEntity::addHP leaves
--     hp==0 and the entity tick (battleentity.cpp:1654) runs Die(), which fires Brittle_Rock's
--     onMobDeath (prop hide + mission progress).
--   * player/rock are re-resolved by full id (GetPlayerByID / GetMobByID) inside the timers
--     instead of trusting captured references (stale-capture crash class).
-----------------------------------
local ID = Lebros
require("scripts/globals/status")
-----------------------------------

function onMobSpawn(mob)
    local instance = mob:getInstance()
    mob:setMobMod(MOBMOD_NO_MOVE, 1)
    mob:SetAutoAttackEnabled(false)

    local function countdown(n)
        return function(m)
            local inst = m:getInstance()
            if inst then
                for _, v in pairs(inst:getChars()) do
                    v:messageSpecial(ID.text.MINE_COUNTDOWN, n)
                end
            end
        end
    end

    mob:timer(2000, countdown(10))
    mob:timer(7000, countdown(5))
    mob:timer(8000, countdown(4))
    mob:timer(9000, countdown(3))
    mob:timer(10000, countdown(2))
    mob:timer(11000, countdown(1))

    mob:timer(12000, function(m)
        local inst = m:getInstance()
        if not inst then
            return
        end
        for _, v in pairs(inst:getChars()) do
            v:messageSpecial(ID.text.MINE_COUNTDOWN, 0)
        end

        -- resolve via the instance itself (GetPlayerByID keys on charid, not entity id)
        local player = nil
        for _, v in pairs(inst:getChars()) do
            if v:getID() == m:getLocalVar("PlayerID") then
                player = v
            end
        end
        local rock = inst:getEntity(bit.band(m:getLocalVar("RockID"), 0xFFF), TYPE_MOB)

        -- "Disengaging wastes the mine": only blast if the player is still engaged with that rock.
        if player and rock and rock:isAlive() and player:isEngaged()
            and player:getTarget() and player:getTarget():getID() == rock:getID() then
            m:timer(2000, function(mm)
                mm:entityAnimationPacket("bom0")
            end)
            m:timer(5000, function(mm)
                local inst2 = mm:getInstance()
                if inst2 then
                    for _, v in pairs(inst2:getChars()) do
                        v:messageSpecial(ID.text.MINE_EXPLODES)
                    end
                end
                local r = inst2 and inst2:getEntity(bit.band(mm:getLocalVar("RockID"), 0xFFF), TYPE_MOB)
                if r and r:isAlive() then
                    r:delHP(r:getMaxHP())
                end
                mm:timer(2000, function(m3)
                    m3:setStatus(STATUS_DISAPPEAR)
                end)
            end)
        else
            m:timer(2000, function(mm)
                mm:setStatus(STATUS_DISAPPEAR)
            end)
        end
    end)
end

function onMobDeath(mob, player, isKiller)
end
