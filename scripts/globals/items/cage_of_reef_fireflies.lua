-----------------------------------------
-- ID: 5347
-- Item: Reef Fireflies
-- Real "give up" item, NOT an entry item -- usable only while already inside Ilrusi Atoll (the
-- onItemCheck's getZoneID()==55 guard means it does nothing anywhere else), lets the player
-- abandon the Assault mission and warp back out to the real-world staging point before it
-- resolves pass/fail. Ported directly from Topaz's own working
-- scripts/globals/items/cage_of_reef_fireflies.lua (sol2 item_object shape,
-- tpz.zone.ILRUSI_ATOLL / tpz.teleport.id.REEF), converted the same way as the already-real
-- sibling cage_of_zhayolm_fireflies.lua: bare literal zone id (55, confirmed via Topaz's own
-- scripts/globals/zone.lua: ILRUSI_ATOLL = 55) and bare FIREFLIES_REEF constant
-- (teleports.lua) instead of the tpz.* tables.
-----------------------------------------
require("scripts/globals/status");
require("scripts/globals/teleports");
-----------------------------------------
function onItemCheck(target)
    if (target:getZoneID() == 55) then
        return 0;
    end
    return 56;
end;

function onItemUse(target)
    target:addStatusEffectEx(EFFECT_TELEPORT,0,FIREFLIES_REEF,0,1);
end;
