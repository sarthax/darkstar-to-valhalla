-----------------------------------
-- func: logpos <optional label>
-- desc: Reports the player's current position (like !pos) and also prints it to the map-server's
--       own console/log output in an easy-to-copy CSV line, for building up a coordinate list
--       over a live play session (e.g. marking real checkpoints/triggers as you walk them)
--       without needing to hand-copy numbers out of the in-game chat log one at a time.
-- Log line format: LOGPOS,label,zone_id,x,y,z,rot
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "s"
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!logpos {optional label}")
end

function onTrigger(player, label)
    local x = player:getXPos()
    local y = player:getYPos()
    local z = player:getZPos()
    local rot = player:getRotPos()
    local zoneId = player:getZoneID()

    label = label or ""

    print(string.format("LOGPOS,%s,%d,%.4f,%.4f,%.4f,%d", label, zoneId, x, y, z, rot))

    player:PrintToPlayer(string.format("Logged: %s zone %d (%.4f, %.4f, %.4f) rot %d", label ~= "" and label or "(no label)", zoneId, x, y, z, rot))
end
