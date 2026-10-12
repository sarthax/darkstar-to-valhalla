---------------------------------------------------------------------------------------------------
-- func: resetlights {player}
-- desc: Zeroes a player's Abyssea lights (default: self) and shows the result if in Abyssea.
---------------------------------------------------------------------------------------------------

require("scripts/globals/abyssea_lights");

cmdprops =
{
    permission = 1,
    parameters = "s"
};

function onTrigger(player, target)
    local targ = player;
    if (target ~= nil) then
        targ = GetPlayerByName(target);
        if (targ == nil) then
            player:PrintToPlayer(string.format("Player named '%s' not found!", target));
            return;
        end
    end
    resetAbysseaLights(targ);
    player:PrintToPlayer(string.format("Reset Abyssea lights for %s.", targ:getName()));
end;
