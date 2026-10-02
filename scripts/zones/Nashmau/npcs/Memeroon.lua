-----------------------------------
-- Area: Nashmau
--  NPC: Memeroon
-- Standard Info NPC / Appraiser
-----------------------------------
-- Appraisal proof-of-concept (2026-08-17): trade a "???" item, pay the fee, get an identified
-- item back. See scripts/globals/appraisal.lua for the shared pool/roll/routing logic and
-- caveats. Fee confirmed by the user: 500 gil.
-- 2026-08-18: onTrigger passed no parameters, so the client's dialogue defaulted its fee token to
-- 0 (and the self-naming token misresolved too) -- see Aht_Urhgan_Whitegate/npcs/Drahbah.lua for
-- the full root-cause writeup (confirmed against a real dialog-table export + LandSandBoat's own
-- Memeroon.lua, which calls `player:startEvent(272, 500)`).
-----------------------------------
require("scripts/globals/appraisal")
-----------------------------------
local APPRAISAL_FEE = 500

-- 2026-08-27: see Drahbah.lua (Aht_Urhgan_Whitegate) for the CS re-trigger attempt this reverts --
-- live-tested and disproven, see appraisal.lua's header note for the full history.
function onTrade(player, npc, trade)
    -- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
    Appraisal.tryAppraise(player, npc, trade, APPRAISAL_FEE)
end

function onTrigger(player, npc)
    player:startEvent(272, APPRAISAL_FEE)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

