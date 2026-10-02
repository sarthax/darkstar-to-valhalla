-----------------------------------
-- func: checknav <x> <y> <z>
-- desc: Checks whether (x,y,z) is a valid position on the current zone's compiled navmesh, and
--       whether a path exists from the player's own current position to it. GM diagnostic tool --
--       added 2026-08-20 to find real, walkable spawn coordinates instead of guessing.
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "sss"
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!checknav {x} {y} {z}")
end

function onTrigger(player, arg1, arg2, arg3)
    local x = tonumber(arg1)
    local y = tonumber(arg2)
    local z = tonumber(arg3)

    if x == nil or y == nil or z == nil then
        error(player, "You must provide x, y, and z.")
        return
    end

    local zone = player:getZone()

    local validPos = zone:checkNavPosition(x, y, z)
    player:PrintToPlayer(string.format("checkNavPosition(%.4f, %.4f, %.4f) = %s", x, y, z, tostring(validPos)))

    local px, py, pz = player:getXPos(), player:getYPos(), player:getZPos()
    local pathFound, waypoints = zone:checkNavPath(px, py, pz, x, y, z)
    player:PrintToPlayer(string.format("checkNavPath from your position (%.4f, %.4f, %.4f) -> target = %s (waypoints=%u)",
        px, py, pz, tostring(pathFound), waypoints))
end
