-----------------------------------------
-- ID: 5346
-- Item: Dvucca Fireflies
-- Real "give up" item, NOT an entry item -- usable only while already inside Periqia (the
-- onItemCheck's getZoneID()==56 guard means it does nothing anywhere else), lets the player
-- abandon the Assault mission and warp back out to the real-world staging point before it
-- resolves pass/fail. Ported directly from Topaz's own working
-- scripts/globals/items/cage_of_dvucca_fireflies.lua (sol2 item_object shape,
-- tpz.zone.PERIQIA / tpz.teleport.id.DVUCCA), converted the same way as the already-real sibling
-- cage_of_zhayolm_fireflies.lua: bare literal zone id (56, confirmed via Topaz's own
-- scripts/globals/zone.lua: PERIQIA = 56) and bare FIREFLIES_DVUCCA constant (teleports.lua)
-- instead of the tpz.* tables.
-----------------------------------------
require("scripts/globals/status");
require("scripts/globals/teleports");
-----------------------------------------
function onItemCheck(target)
    if (target:getZoneID() == 56) then
        return 0;
    end
    return 56;
end;

function onItemUse(target)
    target:addStatusEffectEx(EFFECT_TELEPORT,0,FIREFLIES_DVUCCA,0,1);
end;
