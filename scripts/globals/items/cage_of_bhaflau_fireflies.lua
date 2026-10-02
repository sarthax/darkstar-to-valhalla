-----------------------------------------
-- ID: 5344
-- Item: Bhaflau Fireflies
-- Real "give up" item, NOT an entry item -- usable only while already inside Mamool Ja Training
-- Grounds (the onItemCheck's getZoneID()==66 guard means it does nothing anywhere else), lets the
-- player abandon the Assault mission and warp back out to the real-world staging point before it
-- resolves pass/fail. Ported directly from Topaz's own working
-- scripts/globals/items/cage_of_bhaflau_fireflies.lua (sol2 item_object shape,
-- tpz.zone.MAMOOL_JA_TRAINING_GROUNDS / tpz.teleport.id.BHAFLAU), converted the same way as the
-- already-real sibling cage_of_zhayolm_fireflies.lua: bare literal zone id (66, confirmed via
-- Topaz's own scripts/globals/zone.lua: MAMOOL_JA_TRAINING_GROUNDS = 66) and bare
-- FIREFLIES_BHAFLAU constant (teleports.lua) instead of the tpz.* tables.
-----------------------------------------
require("scripts/globals/status");
require("scripts/globals/teleports");
-----------------------------------------
function onItemCheck(target)
    if (target:getZoneID() == 66) then
        return 0;
    end
    return 56;
end;

function onItemUse(target)
    target:addStatusEffectEx(EFFECT_TELEPORT,0,FIREFLIES_BHAFLAU,0,1);
end;
