-----------------------------------
-- Area: Mamool Ja Training Grounds (Imperial Agent Rescue)
--  Shared logic for the 3 Pot Hatch npcs (_jun/_jul/_jum) -- NOT an npc name itself, just a
--  require()'d helper, so the engine's per-npc-name script lookup never tries to load this file.
-----------------------------------
-- 2026-08-18: user confirmed the real mechanic in-game -- Brujeel is hidden behind one of the
-- 3 Dilapidated Gates. Break a gate to reach its pen, then search the pot hatch inside for a
-- 1-in-3 chance he's in it (assignment randomized once per instance in
-- instances/imperial_agent_rescue.lua via instance:setLocalVar("brujeelHatch", ...)).
--
-- The reveal-and-rescue sequence below is reconstructed directly from a real Thris Nov 2025
-- packet capture (Mamool Ja Training Grounds PSC - Imperial Agent Rescue.zip): a
-- CEntityAnimationPacket with FourCC "deru" fired on Brujeel (self->self) at 11:37:13, followed
-- by 6 CMessageTextPacket lines at 11:37:20/23/28/31/38/38 -- a real ~7s pause after the reveal
-- animation, then roughly 3-8s between lines (the last two land in the same captured second).
-- Text ids re-derived 2026-08-18 via dat-extractor against the real client dialog table after an
-- earlier guessed offset showed unrelated text -- see IDs.lua and topaz_client_id_offset memory.
-- Timing is reproduced with npc:timer() below since messageText() has no built-in delay -- firing
-- all 6 lines with no gap (the original bug the user reported) doesn't match the capture at all.
-- Mission completes immediately on a successful find; the dialogue afterward is flavor only --
-- confirmed live in-game that no separate "talk to Brujeel" step is needed.
-----------------------------------
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
require("scripts/globals/status")
-----------------------------------
function trySearchHatch(player, npc, hatchIndex)
    local instance = npc:getInstance()

    if npc:getLocalVar("searched") == 1 then
        player:PrintToPlayer("You have already searched this pot hatch.")
        return
    end

    npc:setLocalVar("searched", 1)
    -- 2026-08-27 CORRECTION: live diagnostic (since removed) confirmed the trigger fires
    -- correctly and `setAnimation(90)` really does apply server-side -- so the "stays shut"
    -- report wasn't a broken trigger, it was the wrong mechanism. Same real bug already found
    -- and fixed on the Ancient Lockbox this session: `setAnimation()` just flips a persisted
    -- pose/state field, not a one-shot canned animation clip -- this file's own comment
    -- ("same convention as this zone's Ancient Lockbox") was copying a pattern that turned out
    -- to be wrong for that lockbox too. Switched to the real mechanism confirmed via that same
    -- capture data (a `CEntityAnimationPacket` FourCC, same idea as Brujeel's own "deru" reveal).
    -- 2026-08-27 (later): user-confirmed live via `!fourccanim` that these FourCC transitions are
    -- genuinely state-dependent -- "deru" only visibly animates an entity that's actually in the
    -- DISAPPEAR status beforehand, and does nothing on an already-normal entity. "open" is very
    -- likely the same -- Ancient Lockbox (where this same "open" code is confirmed real capture
    -- data) spawns at `animation=0`, but this hatch's `npc_list` default is `animation=9` (the
    -- generic door-closed convention, semantically wrong for a container/lid prop, not a door) --
    -- a mismatched starting pose would explain the "opens abruptly, not fully animated" report.
    -- Explicit reset to match the Lockbox's own confirmed-correct baseline before firing "open".
    npc:setAnimation(0)
    npc:entityAnimationPacket("open")

    if instance:getLocalVar("brujeelFound") == 0 and instance:getLocalVar("brujeelHatch") == hatchIndex then
        instance:setLocalVar("brujeelFound", 1)

        local pos     = npc:getPos()
        local brujeel = instance:getEntity(bit.band(17047810, 0xFFF), TYPE_NPC)
        brujeel:setPos(pos.x, pos.y, pos.z, pos.rot)
        -- 2026-08-22, user-reported: Brujeel spawned facing an arbitrary direction (the hatch
        -- prop's own static rot, east in this instance) instead of the player who found him.
        -- Same pattern already used elsewhere in this codebase (e.g. Mining_Point.lua,
        -- Ifrits_Cauldron/qm4.lua) -- face him toward whoever searched the hatch.
        brujeel:lookAt(player:getPos())
        brujeel:setStatus(STATUS_NORMAL)
        brujeel:entityAnimationPacket("deru")

        -- 2026-08-22, user-reported: instance:complete() (which activates Rune of Release) was
        -- firing immediately, well before Brujeel's ~25s dialogue sequence below even started
        -- playing, let alone finished. Moved to the end of the last scheduled line instead of
        -- firing synchronously here.
        -- Real capture spacing: deru anim -> +7s -> line1 -> +3s -> line2 -> +5s -> line3 ->
        -- +3s -> line4 -> +7s -> line5 -> +0.5s -> line6 (last two landed in the same second).
        -- 2026-08-27: user-reported live -- Brujeel's name never prepended in the chat log.
        -- Root cause: `messageText`'s C++ (message_text.cpp) sources the shown-name/no-name
        -- decision from the "object" argument passed in, not the speaker -- "if a character is
        -- passed as the object, we will not display the name" (its own comment). Passing `player`
        -- as that argument unconditionally suppressed Brujeel's name, regardless of `showName`.
        -- Real working convention elsewhere in this codebase (GiantOrobon_Common.lua,
        -- QiqirnDiver_Common.lua) is `npc:messageText(npc, ...)` -- pass the NPC as its own
        -- object so the client shows its name. Fixed all 6 lines to match.
        brujeel:timer(7000, function() brujeel:messageText(brujeel, BRUJEEL_GLAD_TO_SEE_YOU) end)
        brujeel:timer(10000, function() brujeel:messageText(brujeel, BRUJEEL_SORRY_TROUBLE) end)
        brujeel:timer(15000, function() brujeel:messageText(brujeel, BRUJEEL_CANT_HANG_AROUND) end)
        brujeel:timer(18000, function() brujeel:messageText(brujeel, BRUJEEL_LATE_ASSIGNMENT) end)

        -- 2026-08-27, user-reported live: Brujeel is supposed to kneel, stand up as his dialogue
        -- plays (already covered -- "deru" is a single canned kneel-to-stand transition clip; the
        -- raw capture only ever shows this ONE animation event for him, confirmed via the raw
        -- 0x038 packet log, so there's no separate "kneel" event to add), then cast Warp on
        -- himself and vanish. That last part was genuinely missing entirely -- the sequence used
        -- to just call instance:complete() right after the last line, no cast, no despawn.
        -- Real capture (raw EView log, 0x03A CIndependentAnimationPacket): a fileNum=261 cast,
        -- self->self on Brujeel, at 11:37:33 -- exactly +20s from the "deru" reveal at 11:37:13,
        -- landing 2s after line4 (+18s). fileNum 261 = spellid 261 = 'warp' (confirmed via
        -- sql spell_list). The real "mission objective completed" message lands at 11:37:44,
        -- +31s from deru -- 11s after the cast starts, well past a normal ~5s Warp cast time,
        -- consistent with a vanish-buffer after the cast completes before the mission actually
        -- finalizes (same shape already used and live-tested for Sagelord Molaal Ja's own real
        -- Warp escape in this same zone -- mobs/Sagelord_Molaal_Ja.lua, WARP_CAST_MS/WARP_VANISH_MS
        -- -- reused that same two-stage pattern here).
        -- 2026-08-27 CORRECTION: `castSpell()` never actually did anything here. Traced its full
        -- call chain -- `CAIContainer::Internal_Cast()` (ai_container.cpp) does
        -- `dynamic_cast<CBattleEntity*>(PEntity)`; `CNpcEntity` (Brujeel's real type) does NOT
        -- inherit from `CBattleEntity` in this engine, so the cast correctly returns nullptr and
        -- the function just returns false -- a clean, silent no-op, not a crash. An NPC genuinely
        -- cannot cast a spell in this engine at all (unlike Sagelord Molaal Ja, a real TYPE_MOB,
        -- where this same call legitimately works). Getting the full client-side cast-bar/VFX
        -- sequence would mean converting Brujeel to a mob-backed entity -- bigger than this
        -- warrants. Dropped the non-functional cast; using "kesu" directly instead, the same
        -- FourCC user-confirmed live (via `!fourccanim`) to genuinely work as a real disappear
        -- transition -- less elaborate than a real Warp cast, but an actual visible effect
        -- instead of a silent no-op. Moved from +20s (mid-dialogue, matching the real capture's
        -- cast-start timing) to after the last line (+26s) -- that timing made sense for a real
        -- cast+VFX sequence playing out DURING the remaining dialogue, but "kesu" is an instant
        -- visible disappear, not a multi-second cast -- firing it at +20s would have made Brujeel
        -- visibly vanish while he was still audibly speaking his last 2 lines.
        brujeel:timer(25000, function() brujeel:messageText(brujeel, BRUJEEL_DONT_MENTION) end)
        brujeel:timer(25500, function() brujeel:messageText(brujeel, BRUJEEL_DIDNT_SEE_ANYTHING) end)
        -- 2026-08-27 CORRECTION: user-reported live -- dialogue completed fine but no warp/
        -- disappear ever happened. Root cause: `brujeel:isAlive()` (previously guarding this
        -- step) -- CLuaBaseEntity::isAlive() (lua_baseentity.cpp:8626) does an unchecked
        -- `static_cast<CBattleEntity*>(m_PBaseEntity)`. Brujeel is TYPE_NPC (CNpcEntity), which
        -- does NOT inherit from CBattleEntity in this engine (separate sibling hierarchies under
        -- CBaseEntity) -- that cast is undefined behavior on an NPC. Copied this guard straight
        -- from Sagelord_Molaal_Ja.lua (a real TYPE_MOB, where it's meaningful -- he can genuinely
        -- be killed by player damage before finishing his own escape) without accounting for
        -- Brujeel being a scripted NPC that can't die at all -- the check was both semantically
        -- meaningless and technically broken for his entity type, and the bad cast likely
        -- corrupted this whole callback silently (explaining why `instance:complete()`, sitting
        -- right below it in the same callback, never ran either). Removed entirely.
        -- 2026-08-27 (later) CORRECTION: user-reported live -- his nameplate lingered ~5s after
        -- he'd visually faded out. Root cause: "kesu" (the visual fade, client-side) and
        -- `setStatus(DISAPPEAR)` (what actually clears the nameplate/targetability, server-side)
        -- were on two separate timers 5s apart -- the model faded immediately but the nameplate
        -- stayed until the later timer caught up. Merged into one timer so both fire together.
        -- 2026-08-27 (even later) CORRECTION: user-reported live -- the fade now looks abrupt/
        -- fast instead of gradual. `"kesu"`'s own playback speed isn't something the server
        -- controls at all -- the raw packet (CEntityAnimationPacket) only carries the entity id
        -- and the 4-char code, no duration/speed field -- it's purely a fixed client-side clip.
        -- The real issue: firing `setStatus(DISAPPEAR)` in the exact same instant as "kesu"
        -- likely removes Brujeel from client rendering immediately, cutting the clip's own
        -- natural fade short before it can finish playing. Small buffer between them so the
        -- animation gets room to actually complete before the entity is removed for real, while
        -- staying short enough that the nameplate doesn't noticeably linger either.
        local KESU_FADE_MS = 2000
        brujeel:timer(26000, function()
            brujeel:entityAnimationPacket("kesu")
        end)
        brujeel:timer(26000 + KESU_FADE_MS, function()
            brujeel:setStatus(STATUS_DISAPPEAR)
            instance:complete()
        end)
    else
        player:PrintToPlayer("The pot hatch is empty.")
    end
end


return { trySearchHatch = trySearchHatch }
