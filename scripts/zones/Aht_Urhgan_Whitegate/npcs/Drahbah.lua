-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Drahbah
-- Standard Info NPC / Appraiser
-----------------------------------
-- Appraisal proof-of-concept (2026-08-17): trade a "???" item, pay the fee, get an identified
-- item back. See scripts/globals/appraisal.lua for the shared pool/roll/routing logic and
-- caveats. Fee confirmed by the user: 500 gil.
-- 2026-08-18: onTrigger's dialogue was rendering "Hello, I'm Gwendy [the player's own name], and
-- I'll appraise any item... for the low, low price of 0 gil!" instead of introducing itself and
-- quoting the real fee. Root cause: the client-side event text for csid 678 (confirmed against a
-- real dialog-table export -- index 5206/5208, "...for the low, low price of <Numeric Parameter
-- 0> gil!") expects the fee as the first startEvent parameter, and the old `startEvent(678)` call
-- passed nothing, defaulting that slot to 0. Cross-checked against LandSandBoat's own Drahbah.lua
-- (`player:startEvent(678, 500)`) to confirm the fee belongs in that exact slot -- LSB doesn't
-- pass anything else either, so the "Gwendy" self-naming issue was very likely a downstream
-- symptom of the same missing parameter, not a separate bug needing its own fix.
-- 2026-08-18 (later, REVERTED): a Windower capture appeared to show `Event: 679, Params: 500`
-- for this interaction, and csid was changed 678 -> 679 on that basis. This was wrong: the
-- captures come from a newer FFXI client than the one this server/client pair targets, and per
-- the user this specific client is a confirmed, already-diagnosed off-by-one case -- captured
-- event ids here read one higher than the id this server actually needs. 678 was already the
-- correct, user-confirmed value before that "fix" clobbered it. Reverted back to 678.
-- Lesson: for this zone/NPC, a capture's raw event/csid number is not trustworthy on its own --
-- cross-check against the previously-confirmed value before "correcting" it.
-----------------------------------
require("scripts/globals/appraisal")
-----------------------------------
local APPRAISAL_FEE = 500

-- 2026-08-27: tried deferring the item grant to onEventFinish by re-triggering csid 678 with
-- (1, itemID), matching LandSandBoat's `player:startEvent(appraisalCsid, 1, appraisedItem)` --
-- LIVE-TESTED AND DISPROVEN (see appraisal.lua's header note): the client just replayed the intro
-- dialogue from scratch instead of branching to a result. Reverted to a synchronous grant with a
-- real "thinking" line (messageSpecialFrom) + plain-text result -- see appraisal.lua for the
-- full history of what was tried.
function onTrade(player, npc, trade)
    -- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
    Appraisal.tryAppraise(player, npc, trade, APPRAISAL_FEE)
end

function onTrigger(player, npc)
    player:startEvent(678, APPRAISAL_FEE)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

