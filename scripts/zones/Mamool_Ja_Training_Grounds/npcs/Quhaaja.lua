-----------------------------------
-- Area: Mamool Ja Training Grounds (Breaking Morale)
--  NPC: Quhaaja
-----------------------------------
-- DSP port of the Topaz npcs/Quhaaja.lua (same mission). This file did not exist in
-- old-dsp-reference, so the NPC had no trigger script (no dialog, no turn-in, no give-up).
-- Turn-in: consumes one of the 8 Supplies Crate items (temp items) and advances progress by 1.
-- With nothing to turn in, offers the real csid 106 "End the mission?" menu (option 1 = give up)
-- once progress meets the minimum (1 solo / 2+ in a party). Text IDs are already in TextIDs.lua.
-----------------------------------
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
require("scripts/globals/status")
-----------------------------------

local QUHAAJA_GIVEUP_CSID = 106

local LOOT_POOL =
{
    222,  -- fighting_fish_tank
    542,  -- wild_rabbit_tail
    568,  -- goblin_die
    579,  -- gilt_glasses
    1683, -- piece_of_attohwa_ginseng
    584,  -- torn_epistle
    2227, -- mamool_ja_collar
    556,  -- divination_sphere
}

function onTrigger(player, npc)
    npc:lookAt(player:getPos())

    -- Supplies Crate items are temp items: check/delete with LOC_TEMPITEMS explicitly.
    for _, itemId in ipairs(LOOT_POOL) do
        if player:hasItem(itemId, LOC_TEMPITEMS) then
            player:delItem(itemId, 1, LOC_TEMPITEMS)
            player:setLocalVar("suppliesCrateId", 0)
            player:messageText(npc, QUHAAJA_ITEM_ACCEPTED)
            local instance = player:getInstance()
            if instance then
                instance:setProgress(instance:getProgress() + 1)
            end
            return
        end
    end

    local instance = player:getInstance()
    if not instance then
        return
    end

    local partySize = 0
    for _ in pairs(instance:getChars()) do
        partySize = partySize + 1
    end
    local minimum = (partySize <= 1) and 1 or 2

    if instance:getProgress() >= minimum then
        player:startEvent(QUHAAJA_GIVEUP_CSID, 0, 0, 0, 0, 0, 0, 0, 0)
    else
        player:messageText(npc, QUHAAJA_MISSION_INTRO)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if csid ~= QUHAAJA_GIVEUP_CSID or option ~= 1 then
        return
    end

    local instance = player:getInstance()
    if not instance then
        return
    end

    local npc = instance:getEntity(bit.band(17047821, 0xFFF), TYPE_NPC)
    -- QUHAAJA_SEIZED_COUNT has a numeric parameter -> messageSpecial, not messageText.
    player:messageSpecial(QUHAAJA_SEIZED_COUNT, instance:getProgress())
    if npc then
        player:messageText(npc, QUHAAJA_WORK_DONE)
    end
    instance:complete()
end
