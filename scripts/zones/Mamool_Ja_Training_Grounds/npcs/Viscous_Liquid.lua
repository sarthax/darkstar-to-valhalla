-----------------------------------
-- Area: Mamool Ja Training Grounds (Breaking Morale)
--  NPC: Viscous Liquid
-----------------------------------
-- DSP port of the Topaz npcs/Viscous_Liquid.lua. This file did not exist in old-dsp-reference, so
-- drinking never granted the costume. Real csid 103 = "Take a sip?" menu (option 1 = drink),
-- decoded from the Breaking Morale captures. Drinking grants EFFECT_COSTUME (Mamool Ja 1, id
-- 1600) for COSTUME_DURATION seconds; the heavy DoT, movement slow, and costume strip when
-- approaching a crate are run from instances/breaking_morale.lua's onInstanceTimeUpdate.
-----------------------------------
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
require("scripts/globals/status")
-----------------------------------

local VISCOUS_LIQUID_CSID  = 103
local MAMOOL_JA_COSTUME_ID = 1600
local COSTUME_DURATION     = 300 -- seconds; estimate, not capture-confirmed
local SPEED_REDUCTION      = 10  -- ESTIMATE ("slightly decreased" per wiki)

function onTrigger(player, npc)
    if player:hasStatusEffect(EFFECT_COSTUME) then
        player:messageText(npc, VISCOUS_LIQUID_DECLINED)
        return
    end
    player:startEvent(VISCOUS_LIQUID_CSID, 0, 0, 0, 0, 0, 0, 0, 0)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    if csid ~= VISCOUS_LIQUID_CSID then
        return
    end

    if option == 1 then
        player:addStatusEffect(EFFECT_COSTUME, MAMOOL_JA_COSTUME_ID, 0, COSTUME_DURATION)
        player:addMod(MOD_HASTE_MAGIC, -SPEED_REDUCTION)
        player:setLocalVar("vlSlow", 1)
        player:setLocalVar("vlDotAt", 0)
        player:messageSpecial(VISCOUS_LIQUID_COSTUME)
    else
        local instance = player:getInstance()
        local npc = instance and instance:getEntity(bit.band(17047812, 0xFFF), TYPE_NPC)
        if npc then
            player:messageText(npc, VISCOUS_LIQUID_DECLINED)
        end
    end
end
