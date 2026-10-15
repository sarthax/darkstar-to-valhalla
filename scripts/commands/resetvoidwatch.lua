-----------------------------------
-- func: resetvoidwatch <player>
-- desc: Resets ALL Voidwatch officer/refiner progress for testing: every Stratum Abyssite key item, voidstones,
--       tier-completion records (VWO_TIERS/VWO_TIERS2), officer voidstone stock clock (VWO_STOCK/_TS),
--       atmacite enrichment levels (VWA0..VWA39) and infused atmacite slots (VWA_INF1..3).
--       Deleting the key items alone does NOT reset the refiner: progress lives in these charvars.
--       Does NOT touch periapts, atmacite key items or cruor.
-----------------------------------

require("scripts/globals/status")
require("scripts/globals/keyitems")
require("scripts/globals/voidwatch_officer")

cmdprops =
{
    permission = 1,
    parameters = "s"
}

local function error(player, msg)
    player:PrintToPlayer(msg)
    player:PrintToPlayer("!resetvoidwatch {player}")
end

onTrigger = function(player, target)
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

    local removed = 0
    for _, path in ipairs(VWO.PATHS) do
        for _, ki in ipairs(path.ki) do
            if targ:hasKeyItem(ki) then targ:delKeyItem(ki); removed = removed + 1 end
        end
    end
    for _, ki in ipairs(VWO.VOIDSTONES) do
        if targ:hasKeyItem(ki) then targ:delKeyItem(ki); removed = removed + 1 end
    end

    targ:setVar("VWO_TIERS", 0)
    targ:setVar("VWO_TIERS2", 0)
    targ:setVar("VWO_STOCK", 0)
    targ:setVar("VWO_STOCK_TS", 0)
    for i = 0, 39 do targ:setVar("VWA" .. i, 0) end
    for i = 1, 3 do targ:setVar("VWA_INF" .. i, 0) end

    player:PrintToPlayer(string.format("%s's Voidwatch progress reset. Removed %i key item(s); cleared tier records, stock clock, atmacite levels and infusions.", targ:getName(), removed))
end
