---------------------------------------------------------------------------------------------------
-- func: showlights
-- desc: Prints your Abyssea lights to chat (works in any zone) and shows the in-game readout in Abyssea.
---------------------------------------------------------------------------------------------------

require("scripts/globals/abyssea_lights");

cmdprops =
{
    permission = 1,
    parameters = ""
};

function onTrigger(player)
    local l = getAbysseaLights(player);
    player:PrintToPlayer(string.format("pearl %d, golden %d, silvery %d, ebon %d, azure %d, ruby %d, amber %d",
        l[1], l[2], l[3], l[4], l[5], l[6], l[7]));
    if (isAbysseaLightZone(player:getZoneID())) then
        displayAbysseaLights(player);
    end
end;
