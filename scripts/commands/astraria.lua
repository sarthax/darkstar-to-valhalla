-----------------------------------
-- func: astraria <tier> <set|add|clear> [N] {player}
-- desc: GM debug command -- adds/sets/clears a player's Uncharted Area Survey (instance 52)
--       astraria fragment char_var for testing, without grinding out real boss kills.
--       Operates on the same Nyzul.astraria table (scripts/globals/nyzul.lua) used by the
--       real fragment-gain/redemption logic, so tier names/max fragments always stay in sync.
--
--       !astraria <tier> set <N> {player}   -- sets the tier's fragment char_var directly to N
--                                               (0 to maxFragments-1; use redeem to grant/clear
--                                               the completed KI itself, this command only ever
--                                               touches the fragment counter).
--       !astraria <tier> add <N> {player}   -- adds N (can be negative) to the tier's current
--                                               fragment count, clamped to [0, maxFragments-1].
--       !astraria <tier> clear {player}     -- resets the tier's fragment char_var to 0.
--       !astraria <tier> redeem {player}    -- removes the completed KI (if held) and resets the
--                                               fragment char_var to 0 (Nyzul.unchartedAstrariaRedeem).
--       !astraria <tier> grant {player}     -- force-grants the completed KI directly (bypasses
--                                               fragment counting entirely, for reward testing).
--
--       <tier> is one of: bronze, silver, mythril, gold, platinum.
--       {player} is optional -- omit to target yourself.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "ssss"
}

local function printUsage(player)
    player:PrintToPlayer("Usage: !astraria <bronze|silver|mythril|gold|platinum> <set|add|clear|redeem|grant> [N] {player}")
end

function onTrigger(player, tierArg, action, arg3, arg4)
    if not tierArg or not action then
        printUsage(player)
        return
    end

    local data = Nyzul.astraria[string.upper(tierArg)]
    if not data then
        player:PrintToPlayer("[ASTRARIA] Unknown tier. Use one of: bronze, silver, mythril, gold, platinum.")
        printUsage(player)
        return
    end

    local target = player
    action = string.lower(action)

    if action == "set" or action == "add" then
        local n = tonumber(arg3)
        if not n then
            player:PrintToPlayer("[ASTRARIA] Missing/invalid N.")
            printUsage(player)
            return
        end
        if arg4 and arg4 ~= "" then
            target = GetPlayerByName(arg4) or player
        end

        local fragments = target:getVar(data.charvar)
        if action == "set" then
            fragments = n
        else
            fragments = fragments + n
        end
        if fragments < 0 then
            fragments = 0
        elseif fragments > data.maxFragments - 1 then
            fragments = data.maxFragments - 1
        end
        target:setVar(data.charvar, fragments)
        player:PrintToPlayer(string.format("[ASTRARIA] %s's %s fragments set to %u/%u.", target:getName(), data.name, fragments, data.maxFragments))
    elseif action == "clear" then
        if arg3 and arg3 ~= "" then
            target = GetPlayerByName(arg3) or player
        end
        target:setVar(data.charvar, 0)
        player:PrintToPlayer(string.format("[ASTRARIA] %s's %s fragments cleared to 0.", target:getName(), data.name))
    elseif action == "redeem" then
        if arg3 and arg3 ~= "" then
            target = GetPlayerByName(arg3) or player
        end
        if Nyzul.unchartedAstrariaRedeem(target, string.upper(tierArg)) then
            player:PrintToPlayer(string.format("[ASTRARIA] %s's %s redeemed (KI removed, fragments reset).", target:getName(), data.name))
        else
            player:PrintToPlayer(string.format("[ASTRARIA] %s does not hold the %s.", target:getName(), data.name))
        end
    elseif action == "grant" then
        if arg3 and arg3 ~= "" then
            target = GetPlayerByName(arg3) or player
        end
        if target:hasKeyItem(data.ki) then
            player:PrintToPlayer(string.format("[ASTRARIA] %s already holds the %s.", target:getName(), data.name))
        else
            target:addKeyItem(data.ki)
            target:setVar(data.charvar, 0)
            player:PrintToPlayer(string.format("[ASTRARIA] %s granted the %s.", target:getName(), data.name))
        end
    else
        printUsage(player)
    end
end
