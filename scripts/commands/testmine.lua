-----------------------------------
-- func: testmine
-- desc: Directly triggers Arrapago Remnants' Qiqirn Mine drop sequence (instance:insertAlly(22)
--       + the same ability-timer chain Qiqirn_Treasure_Hunter.lua uses) at the GM's own position,
--       targeting their cursor target (or self if none). Built 2026-09-07 to let the mine-drop
--       fix be tested directly, without needing to engage/flee the real Treasure Hunter mob each
--       time -- same real insertAlly(22)/useMobAbility(1838, target) call, not a reimplementation,
--       so a result here reflects the real mob script's own behavior.
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = ""
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!testmine -- must be run inside an Arrapago Remnants (zoneid 74) instance")
end

function onTrigger(player)
    if player:getZoneID() ~= 74 then
        error(player, "Wrong zone -- Arrapago Remnants is zoneid 74, you are in " .. tostring(player:getZoneID()))
        return
    end

    local instance = player:getInstance()
    if not instance then
        error(player, "Not currently in an instance.")
        return
    end

    local target = player:getCursorTarget() or player
    local POS = player:getPos()

    player:PrintToPlayer(string.format("[TESTMINE] dropping mine at (%.1f,%.1f,%.1f), target=%s",
          POS.x, POS.y, POS.z, target:getName()))

    local mine = instance:insertAlly(22)
    print(string.format("[MINE DEBUG] insertAlly(22) returned %s", tostring(mine ~= nil)))
    if not mine then
        player:PrintToPlayer("[TESTMINE] insertAlly(22) returned nil -- group 22 not found or instance rejected it. Check server console for a real error.")
        return
    end

    print(string.format("[MINE DEBUG] mine spawned: name=%s id=%d pos=(%.1f,%.1f,%.1f) target=%s",
          mine:getName(), mine:getID(), POS.x, POS.y, POS.z, target:getName()))
    mine:setSpawn(POS.x, POS.y, POS.z, POS.rot)
    mine:spawn()
    -- 2026-09-07: throwaway diagnostic -- synchronous, no timer involved -- tells us whether the
    -- entity is already in a bad state (dead/despawned) the INSTANT after spawn() returns, before
    -- a single server tick has even run, versus something killing it on/after the first tick.
    print(string.format("[MINE DEBUG] immediately post-spawn: mine=%s alive=%s isSpawned=%s hp=%d maxhp=%d",
          mine:getName(), tostring(mine:isAlive()), tostring(mine:isSpawned()), mine:getHP(), mine:getMaxHP()))
    mine:updateEnmity(target)
    mine:setLocalVar("fixedBlastDamage", 50)

    -- 2026-09-07: throwaway diagnostic -- tells us whether ANY timer() callback fires on this
    -- entity at all, isolating "the 1000ms one specifically doesn't fire" from "no timer ever
    -- fires" (e.g. the entity gets reaped from the pet list before the AI even ticks it once).
    mine:timer(200, function(m)
        print(string.format("[MINE DEBUG] 200ms probe fired: mine=%s alive=%s status=%s",
              m:getName(), tostring(m:isAlive()), tostring(m:isSpawned())))
    end)

    mine:timer(1000, function(m)
        print(string.format("[MINE DEBUG] ability timer fired: mine=%s alive=%s target=%s targetAlive=%s dist=%.1f",
              m:getName(), tostring(m:isAlive()), target:getName(), tostring(target:isAlive()), m:checkDistance(target)))
        m:useMobAbility(1838, target)
    end)
    mine:timer(7500, function(m)
        print(string.format("[MINE DEBUG] despawning mine=%s alive=%s", m:getName(), tostring(m:isAlive())))
        m:setStatus(STATUS_DISAPPEAR)
    end)

    player:PrintToPlayer("[TESTMINE] mine spawned -- watch server console for [MINE DEBUG] lines over the next ~8 seconds.")
end
