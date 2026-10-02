-----------------------------------
-- func: addassaultpoints <points> <player>
-- desc: adds assault/mercenary rank promotion points to the player (capped at 25),
--       for testing the mercenary rank promotion system (Naja Salaheem)
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "is"
}

function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!addassaultpoints <points> {player}")
end

function onTrigger(player, points, target)
    -- validate points
    if (points == nil) then
        error(player, "Invalid points value.")
        return
    end

    -- validate target
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

    -- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
    -- add points, capped at 25 (matches tpz.besieged.PROMOTION_POINTS_CAP)
    local current = targ:getVar("AssaultPromotion") or 0
    local newPoints = math.min(current + points, 25)

    targ:setVar("AssaultPromotion", newPoints)
    player:PrintToPlayer(string.format("%s's AssaultPromotion points set to %i.", targ:getName(), newPoints))
end
