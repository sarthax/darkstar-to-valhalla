-----------------------------------
-- Command: nyzulflorlayout
-- Desc: Displays the current Nyzul Isle floor layout number
-- Usage: !nyzulflorlayout
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = ""
};

function onTrigger(player, ...)
    -- Get zone ID to verify we're in Nyzul Isle (zone 77)
    if player:getZoneID() ~= 77 then
        player:PrintToPlayer("You must be in Nyzul Isle (zone 77) to use this command.")
        return
    end

    -- Try to access instance with error handling
    local instance
    local ok, err = pcall(function()
        instance = player:getInstance()
    end)

    if not ok then
        player:PrintToPlayer("Error accessing instance: " .. tostring(err))
        return
    end

    if not instance then
        player:PrintToPlayer("You are not in an active instance.")
        return
    end

    -- Get the floor layout
    local layout = instance:getLocalVar("Nyzul_Isle_FloorLayout") or 0
    local floor = instance:getLocalVar("Nyzul_Current_Floor") or 0

    if layout == 0 then
        player:PrintToPlayer("Floor layout not initialized.")
        return
    end

    player:PrintToPlayer(string.format("[Nyzul] Floor: %d | Layout: %d", floor, layout))
end
