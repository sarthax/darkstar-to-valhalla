-----------------------------------
-- Area: Wajaom Woodlands
--  NPC: Mythralline Wellspring
-----------------------------------
-- 2026-08-31, real "Promotion: Lance Corporal" mechanic (SP->LC mercenary rank, gated off in
-- Naja_Salaheem.lua since 2026-08-27 pending real quest content -- see that file's own comment).
-- Ported from a real LandSandBoat reference implementation (user-provided source,
-- scripts/quests/ahtUrhgan/Promotion_Lance_Corporal.lua), same porting precedent already used this
-- session for Imperial Treasure Retrieval. All real quest state (Stage/Prog/Option/Wait) lives on
-- charVars set from npcs/Nafiwaa.lua -- this file only handles the "fill an empty tube here" action
-- shared by all 5 real Mythralline Wellspring rows (4 here, 1 in Bhaflau Thickets), matching LSB's
-- own offset-by-entity-id convention.
-----------------------------------
package.loaded["scripts/zones/Wajaom_Woodlands/TextIDs"] = nil;
require("scripts/zones/Wajaom_Woodlands/TextIDs");
local questCommon = require("scripts/zones/Aht_Urhgan_Whitegate/npcs/lance_corporal_common")
-----------------------------------
-- Real npc_list id of the first of 4 Mythralline Wellspring rows in this zone (contiguous,
-- MYTHRALLINE_WELLSPRING_1..4 = 16986733-16986736 -- see this project's own sql/npc_list.sql).
-- Was ID.npc.MYTHRALLINE_WELLSPRING_1 under the old LandSandBoat-targeted IDs.lua; old-dsp-reference
-- has no npc-id file convention at all (confirmed for Ilrusi_Atoll -- see TextIDs.lua's own header),
-- so hardcoded directly here instead, same convention as old-dsp-reference's own
-- Rune_of_Release.lua/Ancient_Lockbox.lua.
local MYTHRALLINE_WELLSPRING_1 = 16986733
-----------------------------------
function onTrigger(player, npc)
    local stage = player:getVar("PromotionLC")

    -- Real LSB behavior once the mixture's been turned in and the day-gate is running: the spring
    -- has nothing left to offer ("You no longer need the water from this spring.").
    if stage == questCommon.stage.WAIT then
        player:messageSpecial(WELLSPRING + 2)
        return
    end

    -- Quest not accepted (or already fully complete, PromotionLC reset to NOT_STARTED) -- real LSB
    -- source has no handler for this case either, matching an ordinary unremarkable prop reaction.
    if stage ~= questCommon.stage.FIRST_MIX and stage ~= questCommon.stage.REMIX then
        return
    end

    local offset = npc:getID() - MYTHRALLINE_WELLSPRING_1 -- 0-3
    local tubeNum = offset + 1 -- tube.ONE..tube.FOUR

    if questCommon.canFillTube(player, tubeNum) then
        player:startEvent(4 + offset)
    else
        player:messageSpecial(WELLSPRING + 3)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if csid >= 4 and csid <= 7 then
        questCommon.fillTestTube(player, csid - 3) -- csid 4->tube 1, 5->tube 2, 6->tube 3, 7->tube 4
    end
end

