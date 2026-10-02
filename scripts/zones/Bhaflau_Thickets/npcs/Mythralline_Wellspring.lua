-----------------------------------
-- Area: Bhaflau Thickets
--  NPC: Mythralline Wellspring
-----------------------------------
-- 2026-08-31, real "Promotion: Lance Corporal" mechanic -- see Wajaom_Woodlands' own copy of this
-- file (4 of the 5 real wellsprings) for the full header/porting writeup. Only one real wellspring
-- exists in this zone (tube.FIVE), real event id 10.
-----------------------------------
package.loaded["scripts/zones/Bhaflau_Thickets/TextIDs"] = nil;
require("scripts/zones/Bhaflau_Thickets/TextIDs");
local questCommon = require("scripts/zones/Aht_Urhgan_Whitegate/npcs/lance_corporal_common")
-----------------------------------
function onTrigger(player, npc)
    local stage = player:getVar("PromotionLC")

    if stage == questCommon.stage.WAIT then
        player:messageSpecial(WELLSPRING + 2)
        return
    end

    if stage ~= questCommon.stage.FIRST_MIX and stage ~= questCommon.stage.REMIX then
        return
    end

    if questCommon.canFillTube(player, questCommon.tube.FIVE) then
        player:startEvent(10)
    else
        player:messageSpecial(WELLSPRING + 3)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if csid == 10 then
        questCommon.fillTestTube(player, questCommon.tube.FIVE)
    end
end

