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
-----------------------------------
require("scripts/globals/keyitems")
require("scripts/globals/nyzul")
require("scripts/globals/nyzul/pathos")
require("scripts/globals/besieged")
require("scripts/zones/Nyzul_Isle/IDs")
require("scripts/globals/status")
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
    if isRuneLocked(instance) then
        -- Real id confirmed via a decompiled client dialog-table dump (Dialog Table Entry 7479:
        -- "Transfer controls in operation by another user.").
        player:messageText(player, NyzulIsle.text.RUNE_IN_OPERATION)
        return
    end

    local nextFloor = instance:getLocalVar("Nyzul_Current_Floor") + 1
    if nextFloor > 100 then
        nextFloor = 1
    end

    lockRune(instance, player)
    instance:setLocalVar("pendingNextFloor", nextFloor)

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
    local slot0 = 7
    if instance:getLocalVar("menuChoice") <= 1 then
        slot0 = 27
    end
    player:startEvent(201, slot0, 0, nextFloor, 0, 5348, 0, 5348, 0)
end

local function openFloorSelectMenu(player, instance)
    local tokens = player:getAssaultPoint(NYZUL_ISLE_ASSAULT_POINT)
    local floorGroup = math.floor((player:getVar("NyzulFloorProgress") or 0) / 5)
    local floorProgress = 0xFFFFFFFC - bit.bxor(bit.lshift(2, floorGroup + 1) - 1, 3)
    print(string.format("[NYZUL RUNE DEBUG] openFloorSelectMenu: player=%s tokens=%s hasDisc=%s isRuneLocked=%s floorProgress=%s",
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
    local instance = player:getInstance()
    if not instance then
        print("[NYZUL RUNE DEBUG] onTrigger: player has no instance -- bailing")
        return
    end

    local currentFloor = instance:getLocalVar("Nyzul_Current_Floor")
    print(string.format("[NYZUL RUNE DEBUG] onTrigger: player=%s currentFloor=%s npcAnimSub=%s runeHandler=%s",
        player:getName(), tostring(currentFloor), tostring(npc:AnimationSub()), tostring(instance:getLocalVar("runeHandler"))))

    if not currentFloor or currentFloor == 0 then
        -- Lobby entrance -- always acts "lit" (its whole purpose is starting-floor selection,
        -- there's no objective to gate on here).
        openFloorSelectMenu(player, instance)
        return
    end

    if npc:AnimationSub() ~= 1 then
        -- Unlit -- objective not yet met. Per the wiki, examining shows the objective only, no
        -- menu. Real client objective text ids confirmed via a decompiled client dialog-table dump
        -- (NyzulIsle.text.OBJECTIVE_TEXT, IDs.lua) for all 5 real objective stages that HAVE one --
        -- FREE_FLOOR (6) genuinely has none ("Free floors will have no objective message", per the
        -- wiki, matching the dialog table's own gap).
        local objectiveText = NyzulIsle.text.OBJECTIVE_TEXT[instance:getStage()]
        if objectiveText then
            npc:messageText(player, objectiveText)
        end
        return
    end

    -- Lit -- objective met. Real behavior offers a separate "exit the assault" choice here too;
    -- not wired in (see file header) -- this always proceeds to the next floor.
    advanceToNextFloor(player, instance)
end

function onEventFinish(player, csid, option, npc)
    local instance = npc and npc:getInstance() or player:getInstance()
    if not instance then
        return
    end

    local chars = instance:getChars()

    print(string.format("[NYZUL RUNE DEBUG] onEventFinish: player=%s csid=%s option=%s runeHandler=%s (playerID=%s)",
        player:getName(), tostring(csid), tostring(option), tostring(instance:getLocalVar("runeHandler")), tostring(player:getID())))

    if
        csid == 94 and
        option > 0 and
        option < 21 and
        instance:getLocalVar("runeHandler") == player:getID()
    then
        local floorCost = Nyzul.floorCost[option]
        print(string.format("[NYZUL RUNE DEBUG] csid94: option=%s floorCost=%s (cost=%s level=%s) currentPoints=%s",
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

            -- 2026-09-15, DSP-only reposition-timing fix (v2 -- v1 reverted, see below).
            -- v1 (pickSetPoint() BEFORE startEvent(95)) fixed the "snap after full animation" bug but
            -- caused a NEW regression: an instant, unmasked teleport with zero fade -- confirmed live.
            -- v2: restored the original real click-driven order (startEvent() fires first, synchronously,
            -- matching Topaz's own working order and this file's header rule about startEvent() needing
            -- real click/target context) -- then pickSetPoint() is fired from a short timer instead of
            -- from either endpoint of the event, landing (approximately) mid-cutscene instead of before
            -- it starts or after it fully finishes. Topaz's engine genuinely fires onEventUpdate(csid 95)
            -- mid-cutscene and uses that for this same timing (see its own Rune_of_Transfer.lua) -- DSP's
            -- onEventUpdate is confirmed dead for this csid (live debug trace, never fires at all), so
            -- there's no real mid-event callback to hook here; this timer is an estimate standing in for
            -- that missing callback, not a confirmed capture value -- tune RUNE_REPOSITION_DELAY live if
            -- the old-rune snap-back is still visible (too short) or the teleport looks instant (too long
            -- relative to the fade) or too late (visible on the new floor before fade-in completes).
            for _, players in pairs(chars) do
                players:startEvent(95, 0, 0, 0, 0, 0, 0, 0, 0)
            end

            local anyChar94
            for _, players in pairs(chars) do
                anyChar94 = players
                break
            end
            if anyChar94 then
                anyChar94:timer(RUNE_REPOSITION_DELAY, function()
                    pickSetPoint(instance)
                end)
            else
                pickSetPoint(instance)
            end
        else
            -- Real id (Dialog Table Entry 7480: "Insufficient tokens.").
            print(string.format("[NYZUL RUNE DEBUG] csid94: floorCost check FAILED (floorCost=%s, points=%s) -- insufficient tokens branch",
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
        -- 2026-09-15, real bug found live (user-reported: "canceling out of the menu automatically
        -- uses the option for travel to next floor"): confirmed via debug trace that canceling this
        -- exact menu (the "Not yet / Exit / Next floor" 3-choice dialog) sends option=1073741824
        -- (0x40000000, bit 30 set) -- a real, consistently-reproduced client sentinel for "menu
        -- closed with no selection made," not junk/corruption. The old `option >= 2` catch-all had
        -- no upper bound, so this sentinel fell straight into the "Travel to next floor" branch
        -- below every time. Excluded explicitly -- treated the same as any other unrecognized
        -- nonzero option (release the lock, no action), matching this same csid's existing
        -- `elseif option ~= 0` fallback further down for any other unmapped value.
        if option == 1073741824 then
            instance:setLocalVar("runeHandler", 0)
        elseif option == 1 then
            local currentFloor = math.max(1, math.min(100, Nyzul.getRelativeFloor(instance)))
            local startFloor = instance:getLocalVar("Nyzul_Isle_StartingFloor")

            for _, players in pairs(chars) do
                local floorProgress = players:getVar("NyzulFloorProgress") or 0
                if (floorProgress + 1) >= startFloor and floorProgress < currentFloor then
                    players:setVar("NyzulFloorProgress", currentFloor)
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
            local nextFloor = instance:getLocalVar("pendingNextFloor")
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
                if option > 2 and math.random(1, 100) >= 50 then
                    Nyzul.queuePathos(instance)
                end

                -- 2026-09-15, same v2 timer-based reposition fix as the csid 94 success branch above
                -- -- see that comment for the full reasoning.
                for _, players in pairs(chars) do
                    players:startEvent(95, 0, 0, 0, 0, 0, 0, 0, 0)
                end

                local anyChar201
                for _, players in pairs(chars) do
                    anyChar201 = players
                    break
                end
                if anyChar201 then
                    anyChar201:timer(RUNE_REPOSITION_DELAY, function()
                        pickSetPoint(instance)
                    end)
                else
                    pickSetPoint(instance)
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
    else
        instance:setLocalVar("runeHandler", 0)
    end
end

