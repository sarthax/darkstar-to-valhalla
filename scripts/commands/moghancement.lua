---------------------------------------------------------------------------------------------------
-- func: moghancement <action> <keyitemid>
-- desc: Debug/test Mog House Moghancement effects without furnishing a house.
--
--   info                active key item, aura per element, held furniture key items, and the
--                       non-zero value of every modifier the Moghancements use
--   set <keyitemid>     force-apply a Moghancement (swaps the key item and its modifiers)
--                       512-563 and 2849-2855; e.g. 538 Money, 520 Experience, 2850 Resist Paralysis
--   clear               remove the active Moghancement and its modifiers
--   recalc              recompute from the furniture currently installed (same as finishing furnishing)
--
-- Tip: !getmod <id> reads a single modifier. 'set' handles the key item, no !addkeyitem needed.
---------------------------------------------------------------------------------------------------

cmdprops =
{
    permission = 1,
    parameters = "si"
};

function onTrigger(player, action, value)
    local result = player:moghancementDebug(action or "info", value or 0);
    for line in string.gmatch(result, "[^\n]+") do
        player:PrintToPlayer(line);
    end
end;
