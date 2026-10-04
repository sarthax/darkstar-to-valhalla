-----------------------------------
-- Area: Periqia (Saving Private Ryaaf)
--  NPC: Hunched Figure
-----------------------------------
-- One shared script for all 5 rooms' occupant. This engine resolves onTrigger scripts by the
-- npc_list `name` field, exact match to this file's name -- so, per the wiki's "figures do not
-- show names" and this engine having no way to hide a nameplate independent of that same field,
-- all 5 rooms' npc_list rows (17006811 Ryaaf, 17006812 Balarahb, 17006813 Rhagmakah, plus 2
-- dedicated Fomor-room decoys 17006818/17006819) share the identical name 'Hunched_Figure' and
-- this one file. Previously 3 separate files (Ryaaf.lua/Balarahb.lua/Rhagmakah.lua) plus a 4th
-- (Hunched_Figure.lua, but named 'HunchedFigure1'/'2' in npc_list -- a mismatch that meant the
-- engine could never find it at all, "No Valid Function for HunchedFigure1" in the map-server
-- log). Consolidated here, telling the 5 apart by numeric id via SURVIVOR_DIALOGUE below.
-----------------------------------
local ID = Periqia
-----------------------------------
-- Real dialogue, staggered 2s apart -- see IDs.lua for the capture-confirmed MesNum values.
local SURVIVOR_DIALOGUE =
{
    [ID.npc.RYAAF]     = { ID.text.RYAAF_LINE1, ID.text.RYAAF_LINE2, ID.text.RYAAF_LINE3, ID.text.RYAAF_LINE4, ID.text.RYAAF_LINE5 },
    [ID.npc.BALARAHB]  = { ID.text.BALARAHB_LINE1, ID.text.BALARAHB_LINE2, ID.text.BALARAHB_LINE3, ID.text.BALARAHB_LINE4 },
    [ID.npc.RHAGMAKAH] = { ID.text.RHAGMAKAH_LINE1, ID.text.RHAGMAKAH_LINE2, ID.text.RHAGMAKAH_LINE3, ID.text.RHAGMAKAH_LINE4 },
}

-- 2026-08-22: all 5 rooms' npc_list rows share the literal name 'Hunched_Figure' (required so the
-- engine can resolve this onTrigger call in the first place -- see header). Safe to rename to the
-- real survivor NOW, after that resolution already happened for this click (PChar->m_event.Script
-- is fixed for the duration of this interaction) -- renaming any earlier (e.g. at proximity-reveal
-- time, before any click) broke the NEXT click's onTrigger lookup instead. See
-- instances/saving_private_ryaaf.lua's revealOccupant() for the full writeup of that regression.
local SURVIVOR_NAMES =
{
    [ID.npc.RYAAF]     = "Ryaaf",
    [ID.npc.BALARAHB]  = "Balarahb",
    [ID.npc.RHAGMAKAH] = "Rhagmakah",
}

function onTrigger(player, npc)
    npc:lookAt(player:getPos())
    -- 2026-08-22: defensive guard -- these are untargetable() until the proximity reveal fires
    -- (see instances/saving_private_ryaaf.lua's revealOccupant()), which should already prevent
    -- triggering pre-reveal on its own, but belt-and-suspenders in case untargetable() doesn't
    -- also block the trigger action specifically on this engine.
    if npc:getLocalVar("revealed") ~= 1 then
        return
    end

    -- 2026-08-20 (third live test): user-reported triggering a survivor more than once (impatient
    -- re-clicks during the 8-10s staggered dialogue, before the delayed setStatus(DISAPPEAR)/
    -- setProgress below ever ran) advanced progress once per trigger, completing the mission after
    -- finding only 1 real survivor instead of all 3 -- same guard pattern already used elsewhere
    -- in this codebase (Ancient_Lockbox.lua's "opened", Cursed_Chest.lua's "triggered"). The Fomor
    -- branch below was never affected -- it already sets DISAPPEAR immediately, before the mob
    -- even spawns.
    if npc:getLocalVar("triggered") == 1 then
        return
    end
    npc:setLocalVar("triggered", 1)

    local instance = npc:getInstance()
    local lines = SURVIVOR_DIALOGUE[npc:getID()]

    -- Fomor decoys never reach here (see instances/saving_private_ryaaf.lua's revealOccupant() --
    -- 2026-08-22, they now ambush automatically at proximity-reveal instead of waiting on a click,
    -- and setLocalVar("triggered", 1) there means this guard above already returns for them). Only
    -- real survivors trigger past this point.
    local realName = SURVIVOR_NAMES[npc:getID()]
    if realName then
        npc:setName(realName)
    end

    -- Real survivor: stagger the dialogue, then despawn + advance progress only after the
    -- last line -- firing those immediately would cut the dialogue off (same class of bug
    -- already caught once this session on Sagelord Molaal Ja's Warp animation).
    -- 2026-08-23: switched messageText() -> messageSpecialFrom(..., showName=true). The client's
    -- own text for these lines contains a <Speaker Name> placeholder (e.g. Rhagmakah's "My name is
    -- <Speaker Name>...", confirmed live -- rendered blank). messageText's packet has no name-
    -- embedding at all; CMessageSpecialPacket (0x2A) with ShowName=true does (writes the source
    -- entity's live GetName() into the packet, src/map/packets/message_special.cpp:47-52) -- which
    -- is exactly what the setName() rename above now feeds it.
    -- 2026-08-23 (live-test fix): the Topaz-side setName() this was originally written against
    -- only queues its UPDATE_NAME broadcast for the next natural tick -- it doesn't force it out
    -- immediately. Firing line 1 in the SAME call as the rename raced the rename packet:
    -- Rhagmakah's <Speaker Name> token is in line 1, and rendered blank because the dialogue
    -- packet could reach the client before the rename did. Balarahb's own <Speaker Name> token
    -- (line 2) was never affected -- it's already 2s behind the rename via the existing stagger.
    -- LINE_DELAY gives every line, including the first, a moment for the rename to land first.
    -- DSP-PORT: setName() (real DSP binding replacing the invented setName() -- see
    -- reports/remaining_7_packages_binding_audit_2026-09-13.md) sets the identical
    -- `updatemask |= UPDATE_NAME` queued-not-immediate flag (lua_base_entity.cpp:6100), so this
    -- same race and its LINE_DELAY workaround are expected to still apply -- not independently
    -- re-verified live against a DSP server as part of this rename.
    local LINE_DELAY = 500
    for i = 1, #lines do
        -- stale-player guard: re-resolve by id (a captured `player` crashes if they left the zone)
        local pid = player:getID()
        local nid = npc:getID()
        npc:timer(LINE_DELAY + (i - 1) * 2000, function()
            local p = GetPlayerByID(pid)
            -- re-resolve npc too: showText derefs its npc arg unchecked in C++
            local n = instance and instance:getEntity(bit.band(nid, 0xFFF), TYPE_NPC)
            if p and n and lines[i] then p:showText(n, lines[i], 0, 0, 0, 0, true) end
        end)
    end
    local nid2 = npc:getID()
    npc:timer(LINE_DELAY + #lines * 2000, function()
        -- re-resolve: the captured npc/instance wrappers can be null by now (setStatus derefs unchecked)
        local n = instance and instance:getEntity(bit.band(nid2, 0xFFF), TYPE_NPC)
        if n then
            -- one-shot vanish clip first (same 'kesu' the lockbox uses), then hide once it has played;
            -- a bare setStatus(DISAPPEAR) is an instant pop on this engine. Fade length is untested.
            n:entityAnimationPacket("kesu")
            n:timer(1500, function(n2)
                n2:setStatus(STATUS_DISAPPEAR)
            end)
        end
        if instance then
            instance:setProgress(instance:getProgress() + 1)
        end
    end)
end

function onEventUpdate(player, csid, option)
end

-- 2026-09-23: removed an empty onEventFinish stub -- part of the systemic
-- instance-timeout black-screen fix (see documentation/Assault_Fix_Log.md, the
-- 2026-08-18 'SYSTEMIC' entry, and Nyzul_Isle/npcs/Rune_of_Transfer.lua's own header
-- comment). An empty-but-defined onEventFinish here permanently pins
-- PChar->m_event.Script to this file whenever it's the last NPC a player clicked
-- (the custom EVENTFIX patch preserves that pin across resets), so LoadEventScript
-- never falls through to Zone.lua's real csid==102 handler on instance
-- timeout/mission-failed -- the eject cutscene plays, the client acks it, and the
-- player is never actually removed from the failed instance: stuck at a black
-- screen forever. Deleting the stub (this file has no real per-csid logic to keep)
-- lets dispatch reach the working fallback.

