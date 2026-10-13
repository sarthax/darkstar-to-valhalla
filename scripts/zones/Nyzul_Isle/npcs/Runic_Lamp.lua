-----------------------------------
-- Area: Nyzul Isle
--  NPC: Runic Lamp
-- Notes: ACTIVATE_ALL_LAMPS objective (3 real sub-variants: Register/ActivateAll/Order).
--        Shared script for the pool at RUNIC_LAMP_OFFSET..+4 (positioned per-floor by
--        Nyzul.lampsActivate, scripts/globals/nyzul/lamps.lua).
-----------------------------------
-- 2026-09-03: ported from LandSandBoat's npcs/Runic_Lamp.lua. CSID 3 is real, confirmed earlier
-- this session against a real Nyzul Isle capture ("Uncharted Area Survey x2"). The option
-- encoding/cs_option table and ACTIVATE_LAMP_TIME are NOT confirmed against our own capture --
-- LSB uses player:startOptionalCutscene(3, { [0] = N, cs_option = {1, 2} }), a binding that
-- doesn't exist in Topaz (see documentation/research/Nyzul_Isle_Salvage_Scoping.md's open
-- question on this); substituted with a bare player:startEvent(3) here, same treatment as other
-- menu-style events this session (e.g. Qiqirn_Spy.lua's real bare-call fix). ACTIVATE_LAMP_TIME
-- uses the wiki's own updated real value (300s / 5 minutes -- the wiki explicitly notes this
-- superseded an older ~30s figure), not LSB's settings.lua constant.
-- 2026-09-03: LAMP_* text ids are now real, from an authoritative decompiled client dialog-table
-- dump (real Dialog Table Entries 7343-7367, user-supplied) -- see IDs.lua's header for the full
-- table. This SUPERSEDES an earlier packet-capture-inferred pass that got several of these ids
-- wrong (notably LAMP_ALREADY_ACTIVE/LAMP_NEEDS_OTHER_ACTION were off by a few slots).
-----------------------------------
require("scripts/globals/debug_print")
require("scripts/globals/nyzul")
require("scripts/zones/Nyzul_Isle/IDs")
require("scripts/globals/status")
-----------------------------------
local ACTIVATE_LAMP_TIME = 300000 -- 5 minutes, per BG Wiki's updated real value

function onTrigger(player, npc)
    -- 2026-09-23, debug logging added live per user request -- "lamps not responding at all,"
    -- no error/abnormal server output. Prints unconditionally at entry so it's visible even if a
    -- lamp is untargetable (CUTSCENE_ONLY, the expected state on any floor that didn't roll
    -- ACTIVATE_ALL_LAMPS as its objective -- see Nyzul.resetLamps) and onTrigger never runs at
    -- all -- that silence is itself the diagnostic signal, distinguishing "click never dispatched"
    -- from "dispatched but the objective/state branch did nothing."
    dbgPrint(string.format("[LAMP DEBUG] onTrigger: player=%s npc=%d status=%s animSub=%s",
        player:getName(), npc:getID(), tostring(npc:getStatus()), tostring(npc:AnimationSub())))

    local instance = npc:getInstance()
    if not instance then
        dbgPrint("[LAMP DEBUG] onTrigger: npc:getInstance() returned nil -- aborting")
        return
    end

    local lampObjective = instance:getLocalVar("[Lamp]Objective")
    local lampRegister = instance:getLocalVar("[Lamp]lampRegister")
    local lampOrder = npc:getLocalVar("[Lamp]order")
    local wait = npc:getLocalVar("[Lamp]Wait") - os.time()

    dbgPrint(string.format(
        "[LAMP DEBUG] onTrigger: instanceStage=%s [Lamp]Objective=%s [Lamp]lampRegister=%s [Lamp]order=%s wait=%s",
        tostring(instance:getStage()), tostring(lampObjective), tostring(lampRegister), tostring(lampOrder), tostring(wait)))

    if lampObjective == Nyzul.lampsObjective.REGISTER then
        if player:getLocalVar("Register") == 0 then
            player:setLocalVar("Register", 1)
            npc:messageText(player, NyzulIsle.text.LAMP_REGISTER_CONFIRMED)
            instance:setLocalVar("[Lamp]PartySize", instance:getLocalVar("[Lamp]PartySize") - 1)

            if instance:getLocalVar("[Lamp]PartySize") == 0 then
                npc:AnimationSub(1)
                -- 2026-09-15, real bug found live: AnimationSub() only broadcasts to players
                -- already in range -- a party member out of range at this moment (or who leaves
                -- and re-enters range later) never sees the lit state. updateAnimationSub() (new
                -- C++ binding) re-broadcasts the current value instance-wide instead.
                npc:updateAnimationSub()
                instance:setProgress(15)
            end
        else
            npc:messageText(player, NyzulIsle.text.LAMP_REGISTER_STATUS)
        end
    elseif lampObjective == Nyzul.lampsObjective.ACTIVATE_ALL then
        if npc:AnimationSub() == 1 then
            npc:messageText(player, NyzulIsle.text.LAMP_ALREADY_ACTIVE)
        elseif wait > 0 then
            npc:messageText(player, NyzulIsle.text.LAMP_COOLDOWN)
        else
            -- 2026-09-03, user-reported live: a bare startEvent(3) opened the CS with no
            -- selectable "activate?" option. LSB's real call is
            -- player:startOptionalCutscene(3, { [0] = 5, cs_option = { 1, 2 } }) -- a binding/
            -- table shape that doesn't exist in Topaz. Best-effort translation: pass LSB's [0]=5
            -- selector as the first positional arg, on the theory it picks which prompt/option-set
            -- the compiled client event shows. Confirmed live -- option 1 does activate this
            -- variant.
            -- 2026-09-12, user-reported live: "yes/no is popping up correctly AND spilling into
            -- chat also" -- root cause was the messageText(LAMP_ACTIVATE_PROMPT) call below.
            -- Confirmed via a fresh dialog.yml pull that 7349's real text is
            -- "Activate the lamp?\n${selection-lines}\nYes.\nYes.\nNo.${prompt}" -- a
            -- menu-with-embedded-options template meant to be rendered by the compiled cutscene
            -- itself (events_disasm.txt confirms csid 3 has a real CodeQUERY/CodeQUERYWAIT/CodeIF
            -- sequence baked in, same shape as other working Yes/No prompts like the Nyzul staging
            -- doors), not printed a second time via a flat Lua messageText call. Removed the
            -- redundant call -- startEvent(3, 5) alone now shows the real interactive prompt once.
            npc:messageText(player, NyzulIsle.text.LAMP_UNLIT_DESCRIPTION)
            -- 2026-09-27: REVERTED the 2026-09-27 padding change below (was briefly
            -- startEvent(3, 5, 0,0,0,0,0,0,0,0)). That padding was a mistake -- it was based on
            -- comparing to Arrapago_Remnants/Bhaflau_Remnants' OWN csid 3, but those are different
            -- zones, and csids are zone-scoped (events DAT = 5820+zoneid) -- their csid 3 is an
            -- unrelated compiled event, not a real sibling of THIS zone's csid 3. The bare call
            -- here was already confirmed live-working (see the 2026-09-03/09-12 comments above:
            -- "startEvent(3, 5) alone now shows the real interactive prompt once. Confirmed
            -- live."). Padding it regressed a working call -- caught while root-causing the
            -- unrelated-but-same-class Heroine_Rune_of_Transfer.lua bug (see
            -- [[topaz_startevent_padding_required]]).
            player:startEvent(3, 5)
        end
    elseif lampObjective == Nyzul.lampsObjective.ORDER then
        if bit.band(lampRegister, bit.lshift(1, lampOrder)) == 0 then
            -- Same translation as ACTIVATE_ALL above -- LSB's [0]=6 for this variant, confirmed
            -- live (option 2 activates). See the ACTIVATE_ALL branch above for why
            -- LAMP_ACTIVATE_PROMPT is no longer printed via messageText here too.
            npc:messageText(player, NyzulIsle.text.LAMP_UNLIT_DESCRIPTION)
            -- 2026-09-27: reverted, same reason as the ACTIVATE_ALL branch above.
            player:startEvent(3, 6)
        elseif npc:AnimationSub() == 1 then
            npc:messageText(player, NyzulIsle.text.LAMP_ALREADY_ACTIVE)
        else
            npc:messageText(player, NyzulIsle.text.LAMP_ORDER_REQUIRED)
        end
    end
end

function onEventFinish(player, csid, option, npc)
    local instance = npc and npc:getInstance()
    if not instance then
        return
    end

    local lampObjective = instance:getLocalVar("[Lamp]Objective")
    local lampCount = instance:getLocalVar("[Lamp]count") + 1
    local pressCount = instance:getLocalVar("[Lamp]pressCount")
    local lampOrder = npc:getLocalVar("[Lamp]order")
    local lampRegister = instance:getLocalVar("[Lamp]lampRegister")
    local winCondition = false

    if csid == 3 and option == 1 then
        if lampObjective == Nyzul.lampsObjective.ACTIVATE_ALL then
            npc:AnimationSub(1)
            -- 2026-09-15, same real out-of-range fix as this file's other AnimationSub() calls --
            -- see the REGISTER branch above for the full writeup.
            npc:updateAnimationSub()
            npc:timer(ACTIVATE_LAMP_TIME, function(lamp)
                lamp:AnimationSub(0)
                lamp:updateAnimationSub()
                lamp:setLocalVar("[Lamp]Wait", os.time() + 30)
            end)

            -- LSB checks this with 3 hardcoded branches (lampCount==3/4/5, each explicitly
            -- checking offset+2/+3/+4). Generalized to a loop over however many lamps are
            -- actually in play this floor -- same real rule (all lit at once), not a new one.
            local allLit = true
            for i = NyzulIsle.npcs.RUNIC_LAMP_OFFSET, NyzulIsle.npcs.RUNIC_LAMP_OFFSET + lampCount - 1 do
                local lamp = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)
                if not lamp or lamp:AnimationSub() ~= 1 then
                    allLit = false
                    break
                end
            end

            if allLit then
                instance:setProgress(15)
            else
                -- 2026-09-03: real wiki state -- "All lamps on this floor are activated, but some
                -- other action appears to be necessary in order to activate the rune of transfer."
                -- Per the wiki, this same message actually covers BOTH the literal all-lit-but-
                -- something-else-needed case AND the more common case of only some lamps lit at
                -- once ("Despite the wording of this message, it will also be displayed if several
                -- lamps are lit at the same time, but 1 or more remain unlit") -- shown to whichever
                -- player just activated their own lamp, matching the wiki's own description of when
                -- it appears.
                -- 2026-09-03 (later): confirmed real -- LAMP_NEEDS_OTHER_ACTION (7357) fires in a
                -- real capture immediately after a successful activation while other lamps in the
                -- set are still unlit, exactly this state.
                npc:messageText(player, NyzulIsle.text.LAMP_NEEDS_OTHER_ACTION)
            end
        end
    elseif csid == 3 and option == 2 then
        if lampObjective == Nyzul.lampsObjective.ORDER then
            lampRegister = lampRegister + bit.lshift(1, lampOrder)
            instance:setLocalVar("[Lamp]lampRegister", lampRegister)
            instance:setLocalVar("[Lamp]pressCount", pressCount + 1)
            npc:setLocalVar("[Lamp]press", pressCount + 1)

            -- 2026-09-03: real gap found while wiring LAMP_NEEDS_OTHER_ACTION below -- this lamp
            -- was never actually lit (animationsub) on an individual press, only retroactively once
            -- the FULL set was already complete (below). That left onTrigger's own
            -- npc:AnimationSub()==1 "already active" check unreachable for any lamp pressed
            -- before the last one -- a real behavior bug, not just a missing message. Lighting it
            -- immediately on its own press matches the wiki's framing (lamps individually light up
            -- as pressed; the *rune*, not the lamps, is what needs "some other action").
            npc:AnimationSub(1)
            -- 2026-09-15, same real out-of-range fix as this file's other AnimationSub() calls.
            npc:updateAnimationSub()

            -- LSB hardcodes this per lampCount (3->13, 4->29, 5->61) as a magic-number threshold;
            -- generalized here as the same real formula (sum of bits 2^1..2^lampCount, i.e. every
            -- order value 1..lampCount pressed at least once) rather than hardcoding just 3 cases.
            local requiredMask = bit.lshift(1, lampCount + 1) - 2

            if lampRegister >= requiredMask then
                instance:setLocalVar("lampsCorrect", 0)

                for i = NyzulIsle.npcs.RUNIC_LAMP_OFFSET, NyzulIsle.npcs.RUNIC_LAMP_OFFSET + lampCount - 1 do
                    local lamp = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)
                    if lamp then
                        local lampPress = lamp:getLocalVar("[Lamp]press")
                        local setOrder = lamp:getLocalVar("[Lamp]order")
                        lamp:AnimationSub(1)
                        lamp:updateAnimationSub()

                        if lampPress ~= setOrder then
                            lamp:timer(10000, function(lampNpc)
                                lampNpc:AnimationSub(0)
                                lampNpc:updateAnimationSub()
                                instance:setLocalVar("[Lamp]lampRegister", 0)
                                instance:setLocalVar("[Lamp]pressCount", 0)
                            end)
                        else
                            instance:setLocalVar("lampsCorrect", instance:getLocalVar("lampsCorrect") + 1)
                        end
                    end
                end

                if instance:getLocalVar("lampsCorrect") == lampCount then
                    winCondition = true
                else
                    instance:setLocalVar("lampsCorrect", 0)
                end
            end

            -- Real per the authoritative dialog table -- ORDER has its OWN distinct real message
            -- (LAMP_NOT_ALL_LIT, 7357 "Not all lights have been activated...") separate from
            -- ACTIVATE_ALL's LAMP_NEEDS_OTHER_ACTION (7354), covering both "not all pressed yet"
            -- and "full set pressed but in the wrong order".
            if not winCondition then
                npc:messageText(player, NyzulIsle.text.LAMP_NOT_ALL_LIT)
            end

            if winCondition then
                -- Real per the same dialog table -- LAMP_CONFIRMING_PROCEDURE (7358) "Confirming
                -- operation procedure..." during this exact 6-second win-delay window.
                npc:messageText(player, NyzulIsle.text.LAMP_CONFIRMING_PROCEDURE)
                instance:setLocalVar("procedureTime", os.time() + 6)
                npc:timer(6000, function()
                    instance:setLocalVar("lampsCorrect", 0)
                    instance:setLocalVar("[Lamp]lampRegister", 0)
                    instance:setLocalVar("[Lamp]pressCount", 0)
                    instance:setLocalVar("procedureTime", 0)
                    instance:setProgress(15)
                end)
            end
        end
    end
end

