-----------------------------------
-- Voidwatch: fallback for Planar Rifts whose NM is not built yet.
-- Zone scripts: require("scripts/globals/voidwatch_unbuilt"); onTrigger -> vwUnbuiltRift(player, "<NM list>")
-----------------------------------
function vwUnbuiltRift(player, nmNames)
    player:PrintToPlayer("The rift shimmers faintly, but nothing answers. (" .. nmNames .. " has not been implemented on this server yet.)", 0xD);
end
