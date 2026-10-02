-----------------------------------
-- Area: Mamool Ja Training Grounds (Breaking Morale)
--  NPC: Supplies Crate
-----------------------------------
-- DSP port of the Topaz npcs/Supplies_Crate.lua. One shared script for all 8 crates. This file
-- did not exist in old-dsp-reference, so the crates did nothing when triggered.
-- Each crate is one-shot: opening it grants a random flavor temp item; the crate reopens only
-- when a Trainer strips that item from the player (see mobs/Mamool_Ja_Trainer.lua), not when it
-- is turned in to Quhaaja. Costume-strip on approach and the open-state render refresh are done
-- from instances/breaking_morale.lua's onInstanceTimeUpdate (a costumed player cannot trigger an
-- NPC on this engine -- packet_system.cpp blocks it -- so the strip must be server-driven).
-----------------------------------
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
require("scripts/globals/status")
-----------------------------------

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
    if npc:getLocalVar("opened") == 1 then
        player:PrintToPlayer("This crate has already been emptied.")
        return
    end

    -- already holding a supplies item: nothing happens
    for _, itemId in ipairs(LOOT_POOL) do
        if player:hasItem(itemId, LOC_TEMPITEMS) then
            return
        end
    end

    npc:setLocalVar("opened", 1)
    npc:entityAnimationPacket("open") -- one-shot open clip, same as Ancient_Lockbox + Topaz
    npc:AnimationSub(1) -- persisted open state (same convention as caskets)
    npc:updateAnimationSub() -- DSP AnimationSub() setter does not broadcast by itself

    local itemId = LOOT_POOL[math.random(#LOOT_POOL)]
    player:addTempItem(itemId)
    player:setLocalVar("suppliesCrateId", npc:getID())
    player:messageSpecial(PLAYER_OBTAINS_TEMP_ITEM, itemId)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end
