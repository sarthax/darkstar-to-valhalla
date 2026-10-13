-----------------------------------------
-- ID: 6499
-- Item: Patio design plan document
-- Grants key item: Mog Patio design document (3051)
-----------------------------------------
require("scripts/globals/keyitems");
require("scripts/globals/npc_util");

function onItemCheck(target)
    if (target:hasKeyItem(MOG_PATIO_DESIGN_DOCUMENT)) then
        return 56; -- unable to use
    end
    return 0;
end;

function onItemUse(target)
    npcUtil.giveKeyItem(target, MOG_PATIO_DESIGN_DOCUMENT);
end;
