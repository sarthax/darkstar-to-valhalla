-----------------------------------
-- Area:  Nyzul Isle
--  NPC:  Rune of Transfer
-- Notes: Lobby entrance rune (RUNE_OF_TRANSFER_ENTRANCE, npc_list 17093429) -- opens the
--        floor-select menu. Ported from LandSandBoat's Rune_of_Transfer_Start.lua, adapted to
--        this codebase's API (player:getAssaultPoint/delAssaultPoint instead of getCurrency/
--        delCurrency string calls, matching Sorrowful_Sage.lua's existing convention).
-- !pos -20.000 -4.000 -11.000
-----------------------------------
-- csid 94/95 and the RUNIC_DISC gate are ported from LSB as-is. NEW_USER/IN_OPERATION/
-- INSUFFICIENT_TOKENS text ids not present in our own Nyzul_Isle/IDs.lua are NOT fabricated here --
-- messaging is left out at those call sites rather than guessed.
--
-- csid 96 (2026-09-22, Item 3): Uncharted Area Survey's (mission 52) own real destination-floor-cap
-- menu, decoded via explore_event.py against our own client DAT -- NOT an LSB port (LSB has no
-- Uncharted mission at all) and NOT a repurposing of csid 94 (94's floorCost table is Investigation's
-- Runic-Disc-progress floor-PURCHASE mechanic, a completely different real feature Uncharted doesn't
-- have -- it always starts floor 1, per the wiki). See openDestinationFloorMenu's own header comment
-- below for the full decode writeup.
--
-- Lit-state gating follows the real BG Wiki page (Nyzul Isle Investigation): "The Rune of Transfer
-- will initially only display the floor objective when examined. Upon meeting the objective, the
-- Rune will light up" -- and activating a LIT rune "presents options of exiting the assault or
-- proceeding to the next floor." The lobby entrance rune is a special case of this (no floor
-- objective to gate on, always acts as if "lit").
--
-- Floor advancement fires a genuinely separate real CSID, 201 (0x00C9), TARGETING THE RUNE ENTITY
-- ITSELF (confirmed via a real capture, "Floor 5 - Floor 100") -- not just csid 95 on the player,
-- which is all LSB/our earlier port did. The capture shows csid 201's params incrementing a
-- floor-number-shaped value and firing on whichever of the two Rune of Transfer entities
-- (17093330/17093331) is currently placed, immediately followed by csid 95 on the player. Wired in
-- below: player:startEvent(201, nextFloor) fires from onTrigger, where the engine's m_event.Target
-- is correctly bound to this rune since the player just clicked it -- startEvent requires this; it
-- cannot fire "targeting" an NPC from a server-initiated timer/callback (confirmed via
-- src/map/lua/lua_baseentity.cpp's CLuaBaseEntity::startEvent, which dynamic_casts the caller to
-- CCharEntity and reads PChar->m_event.Target, only ever set by the real trigger-click dispatch
-- path). Only nextFloor is confirmed as meaningful among the 8 param slots -- the rest are passed
-- as 0. The wiki's real separate "exit the assault" choice on a lit rune still isn't wired in (no
-- confirmed distinct CSID/option for it) -- advanceToNextFloor always proceeds.
--
-- 2026-09-23 (Item 1): the exception to "always proceeds" above is mission 52 (Uncharted Area
-- Survey) -- a LIT rune there now shows a real 2-choice advancement menu instead ("Advance one
-- floor" vs "Advance ??? floors", the wiki's documented mechanic), decoded off this same csid 201/
-- dialog 7347 via explore_event.py (mask 99 = bits{0,1,5,6}, distinct from Investigation's 7/27
-- pair). See advanceToNextFloor's own header note and onEventFinish's option>=2 branch below for
-- the full decode/implementation writeup.
-----------------------------------
require("scripts/globals/debug_print")
require("scripts/globals/keyitems")
require("scripts/globals/nyzul")
require("scripts/globals/nyzul/pathos")
require("scripts/globals/besieged")
require("scripts/zones/Nyzul_Isle/IDs")
-- 2026-09-16, real dispatch bug found while chasing a "rune won't advance floor / warps back to
-- lobby, unresponsive" report: luautils::LoadEventScript (src/map/lua/luautils.cpp) resolves
-- onEventFinish by trying PChar->m_event.Script FIRST, falling back to the instance script only if
-- that lookup is INVALID (the function doesn't exist there at all). m_event.Script stays pinned to
-- whichever NPC the player last actually clicked -- the Rune of Transfer itself, for the entire
-- floor-transfer flow. This file defines its OWN onEventFinish (for csid 94/201), so it's always
-- valid -- csid 95's onEventFinish (fired later, from the startEvent(95) timer below, not a real
-- click) NEVER reaches nyzul_isle_investigation.lua's real handler; it silently fell into this
-- file's own generic `else` branch instead, skipping that real finalization logic entirely. (This
-- is a narrower case of the same class as onEventUpdate's own doc comment below -- that one happens
-- to work by accident, only because this file has no onEventUpdate of its own to shadow it.)
-- Required directly so onEventFinish can explicitly delegate csid 95 to it below.
local instanceScript = require("scripts/zones/Nyzul_Isle/instances/nyzul_isle_investigation")
-- Uncharted Area Survey (mission 52) shares this same physical Rune of Transfer entity (see
-- checklist: 17093429/17093330/17093331 + Vending Box 17093430 are shared infrastructure, not
-- mission-51-exclusive) -- required so its own pickSetPoint can be kicked off once a real
-- destination floor is chosen via csid 96 below.
local instanceScript52 = require("scripts/zones/Nyzul_Isle/instances/nyzul_isle_uncharted_area_survey")
-- 2026-10-02: pickSetPoint is defined as a global by BOTH instance scripts (last one loaded wins), so
-- the bare pickSetPoint() calls below could run the wrong mission's version. Dispatch explicitly.
local function runPickSetPoint(instance, assaultId)
    if assaultId == 52 then
        instanceScript52.pickSetPoint(instance)
    else
        instanceScript.pickSetPoint(instance)
    end
end
-----------------------------------
-- Advance to the next floor of a run already in progress -- free, no menu (see header note).
-- Floor 100 wraps to floor 1, per the wiki ("Choosing 'Proceed to the next floor' on floor 100
-- will send you to floor 1").
-- runeHandler is a hard lock with no release path except a fully-recognized option value (1 or 2)
-- -- if a menu choice sends some other option (or none at all, a real native-bypass behavior on
-- some client versions), runeHandler would stay locked to that player forever, and the guard below
-- would refuse to even open the menu again. RUNE_LOCK_TIMEOUT treats a lock older than 15s as
-- abandoned and releases it, regardless of what caused it to stick.
local RUNE_LOCK_TIMEOUT = 15

-- 2026-09-15, DSP-only: how long (ms) after firing startEvent(95) to wait before repositioning the
-- player/rune/mobs (pickSetPoint()). This engine has no real mid-cutscene callback for this event
-- (onEventUpdate confirmed dead via live debug trace) -- this is a stand-in estimate, not a real
-- captured value, meant to land the reposition roughly mid-fade instead of before the cutscene
-- starts (instant unmasked teleport, confirmed regression) or after it fully finishes (visible
-- snap-back, the original bug). Tune live against the actual fade duration.
local RUNE_REPOSITION_DELAY = 3300

local function isRuneLocked(instance)
    if instance:getLocalVar("runeHandler") == 0 then
        return false
    end
    if os.time() - instance:getLocalVar("runeHandlerTime") > RUNE_LOCK_TIMEOUT then
        instance:setLocalVar("runeHandler", 0)
        return false
    end
    return true
end

local function lockRune(instance, player)
    instance:setLocalVar("runeHandler", player:getID())
    instance:setLocalVar("runeHandlerTime", os.time())
end

local function advanceToNextFloor(player, instance)
    dbgPrint(string.format("[RUNE DEBUG] advanceToNextFloor: player=%s currentFloor=%s isRuneLocked=%s",
        player:getName(), tostring(instance:getLocalVar("Nyzul_Current_Floor")), tostring(isRuneLocked(instance))))

    if isRuneLocked(instance) then
        -- Real id confirmed via a decompiled client dialog-table dump (Dialog Table Entry 7479:
        -- "Transfer controls in operation by another user.").
        dbgPrint("[RUNE DEBUG] advanceToNextFloor: rune locked -- showing RUNE_IN_OPERATION, aborting")
        player:messageText(player, NyzulIsle.text.RUNE_IN_OPERATION)
        return
    end

    local nextFloor = instance:getLocalVar("Nyzul_Current_Floor") + 1
    if nextFloor > 100 then
        nextFloor = 1
    end

    lockRune(instance, player)

    -- Real capture ("Floor 5 - Floor 100") shows csid 201's 8 params as
    -- [7, 0, <floor>, 0, 5348, 0, 5348, 0] -- the floor number is in SLOT 2. 5348 (slots 4/6) is
    -- the Undersea Ruins Fireflies temp item id (same one Zone.lua's onInstanceZoneIn already
    -- grants) -- passed through as-is since it matches a real known id.
    -- A SECOND real slot0 value (27) is confirmed in a different capture ("Lamp Order") -- real LSB
    -- source ties this exact pair (7 vs 27) to a "normal menu" vs "left/right menu" choice
    -- (player:startOptionalCutscene(201, {[0]=7 or 27, cs_option={1,2}})), and that capture directly
    -- confirms option 3 gets chosen on a real 27-menu -- exactly what this file's own onEventFinish
    -- option>2 branch (the pathos-queue roll) expects.
    -- 2026-09-12 CORRECTED: the 50/50 coin flip previously here was a fabricated estimate --
    -- LandSandBoat's real source (Nyzul_Isle/npcs/Rune_of_Transfer.lua) does set the trigger for
    -- this, `menuChoice`, in nyzul_isle_investigation.lua's own pickSetPoint
    -- (`instance:setLocalVar("menuChoice", math.random(1, 20))`, re-rolled every floor) -- checked
    -- there via `menuChoice > 1`. That's a real 1-in-20 (5%) chance of the left/right menu (27),
    -- 19-in-20 (95%) the normal menu (7), not 50/50. Decoding this dialog's own real bitmask
    -- structure (dialog 7347: bit0=Not yet, bit1=Exit, bit2=Next floor, bit3=Right, bit4=Left,
    -- bit5=specific floor N, bit6=???) confirms 7=bits{0,1,2} and 27=bits{0,1,3,4} are exactly
    -- "Not yet/Exit/Next floor" vs "Not yet/Exit/Right/Left" -- consistent with both real captures.
    --
    -- 2026-09-23 (Item 1): Uncharted Area Survey (mission 52) fires its own real advancement-choice
    -- menu instead of Investigation's 7/27 pair -- mask 99 = bits{0,1,5,6} = "Not yet/Exit the
    -- Assault area/Travel to Floor ${number:1}/Travel to Floor ???", CONFIRMED via explore_event.py
    -- decompiling this same real csid 201/dialog 7347 against our own client DAT (events.yml entity
    -- 17093331, csid 201 -- same physical dialog Investigation's 7/27 masks already use, just
    -- selecting a different pair of real lines). This matches the wiki's documented Uncharted
    -- mechanic exactly: "Advance one floor" (bit5, the numbered line) vs "Advance ??? floors"
    -- (bit6, random 2-11 capped at the chosen destination floor) -- Investigation has no such
    -- documented choice on the wiki, so its own 7/27 menuChoice roll below is untouched.
    -- Per the standard FFXI selection-dialog convention (same one already relied on for masks 7/27
    -- and csid 96's destFloors table), option is the ordinal position among the VISIBLE lines in
    -- this mask, not the raw bit value: for mask 99 that's 0=Not yet(ack), 1=Exit, 2=Floor N (advance
    -- one), 3=Floor ??? (random jump) -- resolved in onEventFinish below.
    -- nextFloor here is only the fallback "advance one" value; the actual floor sent to the client
    -- is decided AFTER the player's real menu choice for mission 52 (see onEventFinish), so
    -- pendingNextFloor is deliberately not preset for it below.
    local slot0
    local slot1 = 0
    if player:getCurrentAssault() == 52 then
        slot0 = 99
        -- 2026-09-23: fixes the live "Travel to Floor 0." display bug -- mask 99's
        -- "Travel to Floor ${number: 1}." line was showing 0 because slot1 was always hardcoded
        -- to 0 while the real floor value only ever went into slot2 (confirmed real slot for the
        -- non-mask-99 masks, which don't use this placeholder at all). Mirroring nextFloor into
        -- slot1 as well costs nothing for the other masks (unused there) and fixes the display
        -- for mask 99 regardless of which of the two slots the "${number: 1}" macro actually reads.
        slot1 = nextFloor
    else
        slot0 = 7
        if instance:getLocalVar("menuChoice") <= 1 then
            slot0 = 27
        end
        instance:setLocalVar("pendingNextFloor", nextFloor)
    end
    player:startEvent(201, slot0, slot1, nextFloor, 0, 5348, 0, 5348, 0)
end

-- Item 3 (2026-09-22): real destination-floor-selection menu for Uncharted Area Survey (mission 52),
-- CONFIRMED via explore_event.py against our own client DAT (Nyzul_Isle zone, entity 17093429,
-- csid 96) -- previously left blocked after captures 234/235/236 looked inconclusive (identical
-- option=5 across all 3 runs). That's now explained, not a capture-pipeline artifact: the decoded
-- event is systemMessage(7463, "...confirmed. Please select your destination...") followed by
-- npc:dialog(7473, 0, 0), whose real text is "Select a floor. [Selection] None. 20. 40. 60. 80.
-- 100.[Prompt]" -- a 6-line selection dialog (None/20/40/60/80/100), option = selection-line index
-- per the standard FFXI selection-dialog convention. All 3 real captures showing option=5 is
-- consistent with every captured player choosing Floor 100 as their destination -- the wiki's own
-- documented meta strategy ("Choose 100, then 1") -- not noise. Both dialog_text ids (7463/7473)
-- independently cross-checked OK against our own dat-extractor index, not just xi-tinkerer's
-- disassembly.
local function openDestinationFloorMenu(player, instance)
    if isRuneLocked(instance) then
        player:messageText(player, NyzulIsle.text.RUNE_IN_OPERATION)
        return
    end
    lockRune(instance, player)
    player:startEvent(96, 0, 0, 0, 0, 0, 0, 0, 0)
end

local function openFloorSelectMenu(player, instance)
    local tokens = player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT)
    -- 2026-09-22: NyzulFloorProgress is now mission-scoped (Nyzul.floorProgressVar) -- this
    -- function is only ever reached for assault 51 (Investigation; Uncharted's onTrigger branches to
    -- openDestinationFloorMenu instead), but reads via the real active assault id rather than
    -- assuming 51 so it stays correct if that ever changes.
    local floorGroup = math.floor((player:getVar(Nyzul.floorProgressVar(player:getCurrentAssault())) or 0) / 5)
    local floorProgress = 0xFFFFFFFC - bit.bxor(bit.lshift(2, floorGroup + 1) - 1, 3)
    dbgPrint(string.format("[NYZUL RUNE DEBUG] openFloorSelectMenu: player=%s tokens=%s hasDisc=%s isRuneLocked=%s floorProgress=%s",
        player:getName(), tostring(tokens), tostring(player:hasKeyItem(RUNIC_DISC)), tostring(isRuneLocked(instance)), tostring(floorProgress)))

    if not player:hasKeyItem(RUNIC_DISC) then
        -- Real id: dialog_text zoneid 77 idx 7461, "New user confirmed. Issuing <item name>." Same
        -- param shape as RUNE_FLOOR_RECORD (7483): one item-name substitution slot.
        player:messageSpecial(NyzulIsle.text.RUNE_NEW_USER_CONFIRMED, RUNIC_DISC)
        npcUtil.giveKeyItem(player, RUNIC_DISC)
    elseif isRuneLocked(instance) then
        player:messageText(player, NyzulIsle.text.RUNE_IN_OPERATION)
        return
    else
        lockRune(instance, player)
        -- Real capture ("Assault - Nyzul Isle Investigation x2[WW] + Lamp Order") shows CSID 94's
        -- real params as [879, 23, 1757, 0, 0, 0, 0, 0] -- slot 0 confirms RUNIC_DISC (879),
        -- slot 1 is plausibly tokens (23), and slots 3-7 are ALL 0. floorProgress is sent in SLOT 7
        -- (matching LSB's own real source, Rune_of_Transfer_Start.lua) -- an earlier attempt to move
        -- it to slot 2 caused a live regression (floor-select menu listed every floor regardless of
        -- real Runic Disc progress); the capture's own slot-2 value (1757) is real but its meaning
        -- isn't independently confirmed (could be a different field, e.g. a preferred-items charvar,
        -- specific to that captured player).
        player:startEvent(94, RUNIC_DISC, tokens, 1, 0, 0, 0, 0, floorProgress)
    end
end

function onTrigger(player, npc)
    -- 2026-09-23, debug logging added live per user request -- "rune of transfer not responding,
    -- still no action when interacting." Prints unconditionally at entry so it's visible even if
    -- onTrigger is never reached at all (npc untargetable / click not dispatched by client) --
    -- that silence is itself the diagnostic signal.
    dbgPrint(string.format("[RUNE DEBUG] onTrigger: player=%s npc=%d status=%s animSub=%s",
        player:getName(), npc:getID(), tostring(npc:getStatus()), tostring(npc:AnimationSub())))

    local instance = player:getInstance()
    if not instance then
        dbgPrint("[RUNE DEBUG] onTrigger: player:getInstance() returned nil -- aborting")
        return
    end

    local currentFloor = instance:getLocalVar("Nyzul_Current_Floor")
    dbgPrint(string.format("[RUNE DEBUG] onTrigger: currentFloor=%s runeHandler=%s",
        tostring(currentFloor), tostring(instance:getLocalVar("runeHandler"))))

    -- 2026-09-23, real bug found live: mission 52's lockStartingFloor hardwires
    -- Nyzul_Current_Floor=1 at onInstanceCreated (it has no per-player Runic-Disc-progress floor
    -- to read, unlike 51), so `currentFloor == 0` is never true for it -- the lobby menu could
    -- never open. Uncharted Area Survey now tracks "has the player actually left the lobby" via
    -- its own separate flag (instanceScript52.hasLeftLobby); 51 still uses the real currentFloor
    -- nil/0 check, since it never pre-sets the floor at creation.
    local stillInLobby
    if player:getCurrentAssault() == 52 then
        stillInLobby = not instanceScript52.hasLeftLobby(instance)
    else
        stillInLobby = not currentFloor or currentFloor == 0
    end

    if stillInLobby then
        -- Lobby entrance -- always acts "lit" (its whole purpose is starting-floor selection,
        -- there's no objective to gate on here). Uncharted Area Survey (mission 52) uses its own
        -- real destination-floor-cap menu (csid 96) instead of Investigation's Runic-Disc-progress
        -- floor-purchase menu (csid 94) -- see Item 3 header note above.
        if player:getCurrentAssault() == 52 then
            openDestinationFloorMenu(player, instance)
        else
            openFloorSelectMenu(player, instance)
        end
        return
    end

    if npc:AnimationSub() ~= 1 then
        -- Unlit -- objective not yet met. Per the wiki, examining shows the objective only, no
        -- menu. Real client objective text ids confirmed via a decompiled client dialog-table dump
        -- (NyzulIsle.text.OBJECTIVE_TEXT, IDs.lua) for all 5 real objective stages that HAVE one --
        -- FREE_FLOOR (6) genuinely has none ("Free floors will have no objective message", per the
        -- wiki, matching the dialog table's own gap).
        dbgPrint(string.format("[RUNE DEBUG] onTrigger: mid-floor, animSub~=1 (unlit) -- showing objective text only, stage=%s",
            tostring(instance:getStage())))
        local objectiveText = NyzulIsle.text.OBJECTIVE_TEXT[instance:getStage()]
        if objectiveText then
            npc:messageText(player, objectiveText)
        end
        return
    end

    -- Lit -- objective met. Real behavior offers a separate "exit the assault" choice here too;
    -- not wired in (see file header) -- this always proceeds to the next floor.
    dbgPrint("[RUNE DEBUG] onTrigger: mid-floor, animSub==1 (lit) -- calling advanceToNextFloor")
    advanceToNextFloor(player, instance)
end

function onEventFinish(player, csid, option, npc)
    local assaultId = player:getCurrentAssault() -- captured now; timers below must not touch `player` later
    dbgPrint(string.format("[RUNE DEBUG] onEventFinish: player=%s csid=%s option=%s npc=%s",
        player:getName(), tostring(csid), tostring(option), npc and tostring(npc:getID()) or "nil"))

    local instance = npc and npc:getInstance() or player:getInstance()
    if not instance then
        dbgPrint("[RUNE DEBUG] onEventFinish: instance is nil -- aborting")
        return
    end

    dbgPrint(string.format("[RUNE DEBUG] onEventFinish: instance runeHandler=%s player:getID()=%s match=%s",
        tostring(instance:getLocalVar("runeHandler")), tostring(player:getID()),
        tostring(instance:getLocalVar("runeHandler") == player:getID())))

    local chars = instance:getChars()

    dbgPrint(string.format("[NYZUL RUNE DEBUG] onEventFinish: player=%s csid=%s option=%s runeHandler=%s (playerID=%s)",
        player:getName(), tostring(csid), tostring(option), tostring(instance:getLocalVar("runeHandler")), tostring(player:getID())))

    if
        csid == 94 and
        option > 0 and
        option < 21 and
        instance:getLocalVar("runeHandler") == player:getID()
    then
        local floorCost = Nyzul.floorCost[option]
        dbgPrint(string.format("[NYZUL RUNE DEBUG] csid94: option=%s floorCost=%s (cost=%s level=%s) currentPoints=%s",
            tostring(option), tostring(floorCost), floorCost and tostring(floorCost.cost) or "nil",
            floorCost and tostring(floorCost.level) or "nil", tostring(player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT))))

        if floorCost and player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT) >= floorCost.cost then
            player:delAssaultPoint(NYZUL_ISLE_ASSAULT_POINT, floorCost.cost)
            instance:setLocalVar("Nyzul_Isle_StartingFloor", floorCost.level)
            instance:setLocalVar("Nyzul_Current_Floor", floorCost.level)
            instance:setLocalVar("diskHolder", player:getID())

            local playerCount = 0
            for _, players in pairs(chars) do
                playerCount = playerCount + 1
            end
            instance:setLocalVar("partySize", playerCount)

            -- 2026-09-15 REVERTED: this session briefly moved pickSetPoint() to fire before
            -- startEvent() here (an attempted fix for a DSP-only timing bug), but that broke Topaz's
            -- own reposition timing, which was already correct -- user-confirmed live regression (an
            -- instant, unmasked teleport with no fade at all). Restored to the original real working
            -- order: fires from instance_object.onEventUpdate(csid 95) (see
            -- nyzul_isle_investigation.lua), matching LSB -- user-reported live proof that
            -- teleporting BEFORE the cutscene plays makes the client visibly warp the player, play
            -- the arrival animation, then snap back to the pre-cutscene position, confirming the
            -- compiled csid 95 event has its own real position-handling tied to update. The 50ms
            -- delay here is our own arbitrary Lua pacing before starting csid 95, not something the
            -- client's own event needs. DSP's equivalent onEventUpdate is confirmed dead (live debug
            -- trace) so this same approach doesn't carry over there -- see that engine's own
            -- Rune_of_Transfer.lua for its separate, diverged fix.
            -- DSP: onEventUpdate(95) never fires, so reposition via a timer after startEvent (see dsp-master Rune_of_Transfer.lua).
            for _, players in pairs(chars) do
                players:startEvent(95, 0, 0, 0, 0, 0, 0, 0, 0)
            end
            local anyCharRune
            for _, players in pairs(chars) do
                anyCharRune = players
                break
            end
            if anyCharRune then
                anyCharRune:timer(RUNE_REPOSITION_DELAY, function()
                    runPickSetPoint(instance, assaultId)
                end)
            else
                runPickSetPoint(instance, assaultId)
            end
        else
            -- Real id (Dialog Table Entry 7480: "Insufficient tokens.").
            dbgPrint(string.format("[NYZUL RUNE DEBUG] csid94: floorCost check FAILED (floorCost=%s, points=%s) -- insufficient tokens branch",
                tostring(floorCost), tostring(player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT))))
            player:messageText(player, NyzulIsle.text.RUNE_INSUFFICIENT_TOKENS)
            instance:setLocalVar("runeHandler", 0)
        end
    elseif csid == 201 and instance:getLocalVar("runeHandler") == player:getID() then
        -- Option mapping resolved via real LSB source (Rune_of_Transfer.lua's own onEventFinish) --
        -- LSB fires this same csid 201 with a real `cs_option = {1, 2}` menu (param[0]=7 for the
        -- normal 2-choice menu, matching our real capture's confirmed param[0]=7; param[0]=27 for a
        -- "left/right" pathos-choice variant, see openFloorSelectMenu/advanceToNextFloor above).
        -- LSB's real business logic: option==1 = "Leave Assault" (pays out tokens, saves Runic Disc
        -- progress); option>=2 = "Travel to next floor" (option>2 is the left/right variant's 2nd
        -- choice, which also queues a pathos on the new floor). Ported here, adapted to this
        -- codebase's real API (player:addAssaultPoint instead of LSB's addCurrency string call) and
        -- this file's own lockRune/isRuneLocked scaffolding instead of LSB's npc-localvar
        -- cued/runCompleted flags (same real invariant: resolve once per menu open).
        --
        -- 2026-09-15, real bug found live on DSP (identical client-side menu protocol, so the same
        -- fix applies here): canceling this exact menu ("Not yet / Exit / Next floor") sends
        -- option=1073741824 (0x40000000, bit 30 set) -- a real, consistently-reproduced client
        -- sentinel for "menu closed with no selection made," not junk. The old `option >= 2`
        -- catch-all had no upper bound, so this sentinel fell straight into "Travel to next floor."
        -- Excluded explicitly, same as any other unrecognized nonzero option (release the lock, no
        -- action).
        if option == 1073741824 then
            instance:setLocalVar("runeHandler", 0)
        elseif option == 1 then
            local currentFloor = math.max(1, math.min(100, Nyzul.getRelativeFloor(instance)))
            local startFloor = instance:getLocalVar("Nyzul_Isle_StartingFloor")

            for _, players in pairs(chars) do
                -- 2026-09-22: NyzulFloorProgress is now mission-scoped (Nyzul.floorProgressVar),
                -- keyed by each player's own real current assault id (51 or 52) rather than the old
                -- flat shared charvar.
                local playersProgressVar = Nyzul.floorProgressVar(players:getCurrentAssault())
                local floorProgress = players:getVar(playersProgressVar) or 0
                if (floorProgress + 1) >= startFloor and floorProgress < currentFloor then
                    players:setVar(playersProgressVar, currentFloor)
                    -- Same real 2-param bug fixed in scripts/globals/nyzul.lua's own handleProgress
                    -- -- entry 7483 needs the Runic Disc key item id in slot 0 (drives the "on your
                    -- <item>" name substitution) and the floor number in slot 1, confirmed against
                    -- our own client's real dialog_text dump.
                    players:messageSpecial(NyzulIsle.text.RUNE_FLOOR_RECORD, RUNIC_DISC, currentFloor)

                    -- Real Mercenary Rank promotion points -- per BG Wiki (Nyzul Isle Investigation,
                    -- Rewards): "Completing one or more floors... as long as you exit via the Rune
                    -- of Transfer will reward you with 5 points... Subsequent completions... will
                    -- reward you with 1 point." Real binding (getRankPoints/addRankPoints ->
                    -- CCharEntity::profile.rankpoints) already exists and is used elsewhere
                    -- (besieged.lua) -- just never wired to Nyzul. Reuses the same per-player "did
                    -- they actually clear a floor this run" gate as the disc-save condition above.
                    -- Confirmed this mechanic has NO LSB equivalent (searched LSB's entire
                    -- Nyzul_Isle folder, zero matches) -- verified against only the BG Wiki text
                    -- quoted above, not cross-checked against a second source (LSB simply never
                    -- implemented this feature, same class of gap as their own admitted
                    -- nyzul_boss_drops.lua stub).
                    if (players:getVar("NyzulRankPointsAwarded") or 0) == 0 then
                        players:setVar("NyzulRankPointsAwarded", 1)
                        players:addRankPoints(5)
                    else
                        players:addRankPoints(1)
                    end
                end

                local tokens = math.max(0, instance:getLocalVar("potential_tokens") - Nyzul.getTokenPenalty(instance))
                if players:getID() == instance:getLocalVar("assaultInitiator") then
                    tokens = math.floor(tokens * 1.1)
                end

                players:setVar("AssaultComplete", 1)
                players:addAssaultPoint(NYZUL_ISLE_ASSAULT_POINT, tokens)
                -- Real id (Dialog Table Entry 7482: "You obtain <N> token[/s]!").
                players:messageSpecial(NyzulIsle.text.RUNE_OBTAIN_TOKENS, tokens)
            end

            -- 2026-09-12, user-reported live: exiting via the Rune of Transfer didn't remove any
            -- positive or negative Pathos effects picked up during the run. Real confirmed pattern
            -- from the equivalent Salvage mechanic (Arrapago_Remnants/instances/
            -- arrapago_remnants.lua's stripPathos, called on every real exit path there): these
            -- effects are scoped to being inside the instance and should clear immediately on any
            -- real exit, not just on a floor-to-floor transfer. Nyzul.removePathos(instance) was
            -- already correctly wired to the mid-run floor-transition path (csid 95, see
            -- nyzul_isle_investigation.lua's own onEventFinish) but was missing here on the actual
            -- "Leave Assault" exit.
            Nyzul.removePathos(instance)
            -- 2026-09-12, user-reported live AGAIN after the above fix: a real DEBILITATION was
            -- still present after exit. Root cause: removePathos() only clears effects it itself
            -- tracked via the floorPathos bitmask -- i.e. ones actually applied by the Pathos
            -- system. DEBILITATION (and the other 4 effects Pathos can apply) are also real, common
            -- FFXI status effects mobs can inflict directly through ordinary combat, completely
            -- independent of Pathos -- that path never touches floorPathos, so removePathos alone
            -- can't see it. Arrapago Remnants' stripPathos doesn't have this gap: it unconditionally
            -- strips all 5 effects regardless of source or tracking state. Added the same
            -- unconditional sweep here as a safety net on top of the bitmask-driven removal above
            -- (which still matters for its per-effect PATHOS_REMOVED messaging).
            for _, players in pairs(chars) do
                players:delStatusEffectSilent(EFFECT_ENCUMBRANCE_I)
                players:delStatusEffectSilent(EFFECT_OBLIVISCENCE)
                players:delStatusEffectSilent(EFFECT_OMERTA)
                players:delStatusEffectSilent(EFFECT_IMPAIRMENT)
                players:delStatusEffectSilent(EFFECT_DEBILITATION)
                if players:hasPet() then
                    local pet = players:getPet()
                    pet:delStatusEffectSilent(EFFECT_DEBILITATION)
                    pet:delStatusEffectSilent(EFFECT_IMPAIRMENT)
                    pet:delStatusEffectSilent(EFFECT_OMERTA)
                end
            end
            instance:setLocalVar("runeHandler", 0)
            instance:complete()
        elseif option >= 2 then
            local nextFloor
            if player:getCurrentAssault() == 52 then
                -- 2026-09-23 (Item 1): mission 52's real 2-choice pair under mask 99 -- option==2 is
                -- "Travel to Floor ${number:1}" (raw option 5 live; deterministic, ascends exactly one floor, per the
                -- wiki: "Advance one floor: Ascends one floor"); option==3 is "Travel to Floor ???"
                -- (per the wiki: "Randomly ascends between 2 and 11 floors... will not advance beyond
                -- the destination floor chosen at the start of the run. The probabilities of each
                -- jump are evenly distributed" -- a flat math.random(2, 11), capped at
                -- Nyzul_DestinationFloor, matches this exactly). Computed here (after the real choice
                -- is known) rather than pre-set in advanceToNextFloor, since which floor to actually
                -- send the player to depends on which of these two options they pick.
                local currentFloor = instance:getLocalVar("Nyzul_Current_Floor")
                dbgPrint(string.format("[RUNE DEBUG] csid 201 mask99 option>=2: raw option=%s currentFloor=%s", tostring(option), tostring(currentFloor)))

                -- 2026-09-23 (Item 3 followup): floor 100 is the hard cap -- there is no floor 101,
                -- so neither the deterministic "+1" nor the random "???" jump has anywhere real to
                -- go. Gate both branches on currentFloor here instead of letting the deterministic
                -- branch wrap back to floor 1 (a real bug -- silently restarting the run) or the
                -- random branch's destFloor-clamp collapse to a same-floor no-op that reads as "does
                -- nothing." Once at 100, both options simply stay on 100; the real advancement out of
                -- floor 100 is via the boss kill completing the instance (isAtDestinationFloor), not
                -- through this menu.
                if currentFloor >= 100 then
                    nextFloor = 100
                elseif option == 6 then
                    -- 2026-09-26 (issue #3): live map-server log (25/Sep) shows mask 99 delivers the raw
                    -- BIT INDEX as option -- 5 = "Travel to Floor N" (bit5), 6 = "Travel to Floor ???"
                    -- (bit6) -- never the visible-line ordinal (2/3) assumed earlier, so the old
                    -- `option == 3` test never matched and "???" silently fell through to +1.
                    local destFloor = instance:getLocalVar("Nyzul_DestinationFloor")
                    nextFloor = currentFloor + math.random(2, 11)
                    if destFloor and destFloor > 0 and nextFloor > destFloor then
                        nextFloor = destFloor
                    end
                    if nextFloor > 100 then
                        nextFloor = 100
                    end
                else
                    nextFloor = currentFloor + 1
                    if nextFloor > 100 then
                        nextFloor = 100
                    end
                end
            else
                nextFloor = instance:getLocalVar("pendingNextFloor")
            end
            if nextFloor and nextFloor > 0 then
                instance:setLocalVar("Nyzul_Current_Floor", nextFloor)
                instance:setLocalVar("diskHolder", player:getID())
                instance:setLocalVar("pendingNextFloor", 0)

                -- Real per LSB: a still-active ACTIVATE_ALL_LAMPS objective clears its lamps when
                -- leaving the floor, since they don't carry over.
                if instance:getStage() == Nyzul.objective.ACTIVATE_ALL_LAMPS then
                    for i = NyzulIsle.npcs.RUNIC_LAMP_OFFSET, NyzulIsle.npcs.RUNIC_LAMP_OFFSET + 4 do
                        local lamp = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)
                        if lamp then
                            lamp:AnimationSub(0)
                        end
                    end
                end

                -- Real per LSB: option>2 (the left/right variant's 2nd choice) has a ~50% chance
                -- to queue a pathos on the new floor. LSB's own range here is hardcoded to 18-29
                -- (beneficial-only) -- 2026-09-12, user-requested: widened to the full 1-29 range
                -- (Nyzul.queuePathos itself excludes anything already active/queued) so this
                -- real "left or right" choice can genuinely land on either a beneficial OR
                -- detrimental effect, matching the wiki's own description ("beneficial or
                -- detrimental") rather than LSB's narrower actual implementation.
                if option > 2 and player:getCurrentAssault() ~= 52 and math.random(1, 100) >= 50 then
                    Nyzul.queuePathos(instance)
                end

                -- 2026-09-15 REVERTED, same as the csid 94 success branch above -- restored to the
                -- original working order (see that comment for the full reasoning).
                -- DSP: onEventUpdate(95) never fires, so reposition via a timer after startEvent (see dsp-master Rune_of_Transfer.lua).
                for _, players in pairs(chars) do
                    players:startEvent(95, 0, 0, 0, 0, 0, 0, 0, 0)
                end
                local anyCharRune
                for _, players in pairs(chars) do
                    anyCharRune = players
                    break
                end
                if anyCharRune then
                    anyCharRune:timer(RUNE_REPOSITION_DELAY, function()
                        runPickSetPoint(instance, assaultId)
                    end)
                else
                    runPickSetPoint(instance, assaultId)
                end
            else
                instance:setLocalVar("runeHandler", 0)
            end
        elseif option ~= 0 then
            -- Unrecognized nonzero option -- release the lock rather than leaving it stuck (the
            -- real root cause of an earlier "rune stops responding" bug).
            instance:setLocalVar("runeHandler", 0)
        end
        -- option == 0: just the menu-open ack, not a real choice -- ignore, keep the lock held.
    elseif csid == 95 then
        -- 2026-09-14, real dispatch bug found live: this engine resolves onEventFinish via
        -- PChar->m_event.Script (src/map/lua/luautils.cpp::LoadEventScript), which still points at
        -- THIS file from the original csid 94 click -- it is NEVER updated when a later csid (95)
        -- is fired mid-chain. Since this file defines its own global onEventFinish, LoadEventScript
        -- finds it first and never falls through to try instances/nyzul_isle_investigation.lua's
        -- own onEventFinish(csid 95) at all -- that function is effectively dead code for csid 95,
        -- confirmed via a live debug trace (its own debug print never fired; THIS file's did,
        -- landing in the old generic `else` below, which only reset runeHandler and skipped the
        -- pathos cleanup). Inlined the same logic that instance script's onEventFinish would have
        -- run, since engine dispatch will never actually reach it for this csid.
        --
        -- 2026-09-15: pickSetPoint() no longer fires here -- it now fires from a short timer started
        -- right after startEvent(95) (see the csid 94/201 branches above, RUNE_REPOSITION_DELAY) so
        -- it lands mid-cutscene instead of only once the client has ALREADY finished playing the
        -- whole thing (which is when onEventFinish(95) itself fires -- too late to matter here).
        -- Only post-event cleanup belongs in this branch now.
        if instance:getLocalVar("runeHandler") == player:getID() then
            Nyzul.removePathos(instance)
            Nyzul.addFloorPathos(instance)
            instance:setLocalVar("runeHandler", 0)
        end
    elseif csid == 94 or csid == 201 then
        -- Ignore a csid 94/201 call that didn't match the branches above (e.g. csid==94 with
        -- option==0, or a runeHandler mismatch on the ack packet specifically) -- this used to fall
        -- into the generic `else` below and reset runeHandler on the ack itself, which could release
        -- the lock before the real choice packet ever arrived. runeHandler only gets cleared by a
        -- real completed choice (see the branches above) or the instance's own timeout/failure path.
    elseif csid == 96 and instance:getLocalVar("runeHandler") == player:getID() then
        -- Item 3: real destination-floor menu resolution -- option is the selection-line index
        -- (0=None/cancel, 1=20, 2=40, 3=60, 4=80, 5=100), per the decoded csid 96 dialog (see
        -- openDestinationFloorMenu's header comment above).
        -- 2026-09-23, real bug found live via [RUNE DEBUG]: the client's actual response for this
        -- dialog is NOT a plain 1-5 -- it's 0x10001 (65537) for line 1, i.e. selection index in the
        -- LOW 16 bits with a flag/list-type bit set in the high word (same general class as this
        -- file's other real sentinel-decode cases, e.g. csid 201's 0x40000000 cancel). destFloors[
        -- option] was always nil against the raw value, so every real selection fell into the
        -- cancel/unrecognized branch below and silently released the lock with no startEvent(95) --
        -- "menu just resets, no action" was the actual live bug.
        local destFloors = { [1] = 20, [2] = 40, [3] = 60, [4] = 80, [5] = 100 }
        local dest = destFloors[bit.band(option, 0xFFFF)]

        if dest then
            instance:setLocalVar("Nyzul_DestinationFloor", dest)

            -- 2026-09-23, real bug found live: this used to clear runeHandler and call
            -- instanceScript52.pickSetPoint(instance) directly and synchronously, with no
            -- startEvent(95) at all -- unlike every other real floor-transition path in this file
            -- (csid 94 success, csid 201 option>=2), which fires csid 95 per player and lets
            -- pickSetPoint run from instanceScript52's own onEventUpdate once the client's real
            -- transfer cutscene actually plays. Without it, Nyzul_Current_Floor was never touched
            -- (stayed 1 forever) and the client got no cutscene/arrival transition at all --
            -- "won't advance to the floors" was literally correct, nothing was firing. Same real
            -- unpadded-startEvent() fix as the other two call sites (2026-09-14). Also: runeHandler
            -- must stay locked here (it's released later by onEventFinish once the real transfer
            -- actually completes), not cleared up front -- clearing it here would make the
            -- runeHandler==player:getID() guard in onEventUpdate/onEventFinish fail immediately.
            -- 2026-10-02 (user: lobby rune "takes you back to lobby when selecting a floor"): the
            -- floor itself was never generated -- DSP never fires onEventUpdate(95), so pickSetPoint
            -- (which sets Nyzul_Isle_HasTransferred and moves everyone) never ran, and the 50ms-timer
            -- startEvent left the player at the lobby. Same sequence as the csid 94/201 branches:
            -- startEvent(95) now, reposition after RUNE_REPOSITION_DELAY.
            local anyCharRune
            for _, players in pairs(chars) do
                players:startEvent(95, 0, 0, 0, 0, 0, 0, 0, 0)
                anyCharRune = anyCharRune or players
            end
            if anyCharRune then
                anyCharRune:timer(RUNE_REPOSITION_DELAY, function()
                    if instance:getLocalVar("Nyzul_RunComplete") ~= 1 then
                        runPickSetPoint(instance, 52)
                    end
                end)
            else
                runPickSetPoint(instance, 52)
            end
        else
            -- option == 0 (None/cancel) or any unrecognized value: release the lock, no action --
            -- same "leave it as it was" behavior as csid 94/201's own cancel/unrecognized-option paths.
            instance:setLocalVar("runeHandler", 0)
        end
    elseif csid == 95 then
        -- 2026-09-16: explicit delegation -- see this file's header comment. Engine dispatch can
        -- never reach the instance script's own onEventFinish for this csid on its own, since this
        -- file's onEventFinish is itself always valid and wins LoadEventScript's lookup.
        -- 2026-09-23, real bug found live: this always delegated to instanceScript (Investigation,
        -- mission 51) regardless of which assault was actually active -- a leftover from before
        -- mission 52 existed (instanceScript52 was already required above for exactly this, just
        -- never wired in here). A mission-52 player's own real onEventFinish
        -- (removePathos/addFloorPathos/clearing runeHandler, see
        -- nyzul_isle_uncharted_area_survey.lua) never ran; Investigation's ran against Uncharted's
        -- instance data instead. Same getCurrentAssault() branch already used at the top of
        -- onTrigger for the lobby menu choice.
        dbgPrint(string.format("[RUNE DEBUG] onEventFinish: csid==95, delegating to %s.onEventFinish",
            player:getCurrentAssault() == 52 and "instanceScript52" or "instanceScript"))
        if player:getCurrentAssault() == 52 then
            instanceScript52.onEventFinish(player, csid, option)
        else
            instanceScript.onEventFinish(player, csid, option)
        end
    elseif csid == 1 then
        -- 2026-09-23, real bug found live (log/map-server.log [EVENTFIX DEBUG], EventID=1 dispatched
        -- with m_event.Script still pinned to this file): same sticky-m_event.Script class as csid 95
        -- above -- engine dispatch can never reach the instance script's or Zone.lua's own
        -- onEventFinish for csid 1 (instance timeout/mission-failed eject) once this file's
        -- onEventFinish is pinned here from the player's last Rune of Transfer click. Without this
        -- branch it fell into the catch-all else below (runeHandler clear only, no setPos) -- the
        -- mission-failed cutscene plays, the client sends its ack, and the player is never actually
        -- removed from the failed instance: stuck at a black screen forever. Mirrors every zone's own
        -- Zone.lua onEventFinish csid==1 handler exactly (see Nyzul_Isle/Zone.lua).
        instance:setLocalVar("runeHandler", 0)
        player:setPos(0, 0, 0, 0, 72)
    else
        dbgPrint(string.format("[RUNE DEBUG] onEventFinish: fell through to catch-all else (unmatched csid=%s or runeHandler mismatch) -- clearing runeHandler",
            tostring(csid)))
        instance:setLocalVar("runeHandler", 0)
    end
end

