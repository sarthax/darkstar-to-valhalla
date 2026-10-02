-----------------------------------
-- func: addnyzultokens <points> {player}
-- desc: adds Nyzul Isle Assault Points (the real per-run "tokens" the Vending Box/Rune of
--       Transfer floor-select menu spend) to the player, for testing without a live run.
--       NYZUL_ISLE_ASSAULT_POINT = 5, real region constant (scripts/globals/besieged.lua),
--       same player:addAssaultPoint API Rune_of_Transfer.lua/vending_box.lua already use.
-----------------------------------
require("scripts/globals/besieged")
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "is"
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!addnyzultokens <points> {player}")
end

function onTrigger(player, points, target)
    if (points == nil) then
        error(player, "Invalid points value.")
        return
    end

    local targ
    if (target == nil) then
        targ = player
    else
        targ = GetPlayerByName(target)
        if (targ == nil) then
            error(player, string.format("Player named '%s' not found!", target))
            return
        end
    end

    targ:addAssaultPoint(NYZUL_ISLE_ASSAULT_POINT, points)
    player:PrintToPlayer(string.format("%s now has %i Nyzul Isle tokens.", targ:getName(), targ:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT)))
end
