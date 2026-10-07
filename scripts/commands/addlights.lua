---------------------------------------------------------------------------------------------------
-- func: addlights <light> <amount> <player>
-- desc: Adds Abyssea lights to a player (default: self). Must be in an Abyssea zone for the message.
--       light: pearl, golden, silvery, ebon, azure, ruby, amber
---------------------------------------------------------------------------------------------------

require("scripts/globals/abyssea_lights");

cmdprops =
{
    permission = 1,
    parameters = "sis"
};

local lights = { pearl = LIGHT_PEARL, golden = LIGHT_GOLDEN, silvery = LIGHT_SILVERY, ebon = LIGHT_EBON,
                 azure = LIGHT_AZURE, ruby = LIGHT_RUBY, amber = LIGHT_AMBER };

function error(player, msg)
    player:PrintToPlayer(msg);
    player:PrintToPlayer("!addlights <pearl|golden|silvery|ebon|azure|ruby|amber> <amount> {player}");
end;

function onTrigger(player, light, amount, target)
    local targ = player;
    if (target ~= nil) then
        targ = GetPlayerByName(target);
        if (targ == nil) then
            error(player, string.format("Player named '%s' not found!", target));
            return;
        end
    end

    if (light == nil or lights[light] == nil) then
        error(player, "Invalid light type.");
        return;
    end
    if (amount == nil or amount < 1) then
        error(player, "Invalid amount.");
        return;
    end

    local total = addAbysseaLights(targ, lights[light], amount);
    player:PrintToPlayer(string.format("%s was given %d %s light, total now %d.", targ:getName(), amount, light, total));
end;
