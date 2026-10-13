-----------------------------------
-- Area: Leujaoam Sanctum (Orichalcum Survey)
-- NPC: Mulwahah
-----------------------------------
-- Issues a Pickaxe (item 605) at the start, and accepts the Chunk of Orichalcum Ore
-- (item 739, "chunk_of_orichalcum_ore" in item_basic) once a Mining Point yields one.
--
-- Flow:
--   1. Player has no pickaxe/ore -> Mulwahah gives Pickaxe.
--   2. Player already has Pickaxe -> Mulwahah gives the "already have" dialogue.
--   3. Player has Orichalcum Ore -> Mulwahah gives the 3 turn-in messages,
--      then completes the instance.
--   4. Once the instance is completed / Rune of Release is activated,
--      Mulwahah only gives GO_AWAY_1 and GO_AWAY_2.
-----------------------------------

require("scripts/globals/status")
local ID = Leujaoam
-----------------------------------

local PICKAXE_ITEM = 605
local ORE_ITEM     = 739

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    npc:lookAt(player:getPos())

    local instance = npc:getInstance()

    ----------------------------------------------------------------
    -- Assault already completed.
    --
    -- instance:complete() causes onInstanceComplete() to fire,
    -- which makes the Rune of Release available. Once completed,
    -- Mulwahah should no longer show the ore turn-in dialogue.
    ----------------------------------------------------------------
    if instance and instance:completed() then
        player:showText(npc, ID.text.MULWAHAH_GO_AWAY_1)

        -- 2026-09-14, same npc-capture-across-a-timer risk as the ore turn-in sequence below --
        -- use npc:timer()'s own fresh callback argument instead of a GetNPCByID() re-lookup.
        -- ALSO re-resolve player: live debugger inspection proved it's player, not npc, that goes
        -- invalid here (garbage objtype/id, classic use-after-free) -- GetPlayerByID() is the safe
        -- re-lookup (returns nil if the player's since disconnected).
        local playerId = player:getID()
        npc:timer(1000, function(npc)
            local livePlayer = GetPlayerByID(playerId)
            if npc and livePlayer then
                livePlayer:showText(npc, ID.text.MULWAHAH_GO_AWAY_2)
            end
        end)

        return
    end

    ----------------------------------------------------------------
    -- Player has the Chunk of Orichalcum Ore.
    --
    -- This is the actual mission turn-in.
    ----------------------------------------------------------------
    if player:hasItem(ORE_ITEM) then

        -- 2026-08-27, user-reported: the ore was never actually removed from inventory on turn-in
        -- (dialogue played, instance completed, but the item stayed until Rune of
        -- Release/mission cleanup) -- Qiqirn Miners kept attacking the whole time since they
        -- aggro on ore possession (see Mining_Point.lua's resolveMining, which sets them
        -- aggressive on the successful ore roll). Ore was granted via addTempItem in
        -- Mining_Point.lua, so remove it the same way, immediately on this first interaction --
        -- not after the dialogue/instance-complete timers, so the Qiqirn stand down right away.
        -- 2026-08-27, live-reported: delTempItem() isn't a real function (crashed onTrigger
        -- outright, "attempt to call method 'delTempItem' (a nil value)") -- there is no such
        -- binding in lua_baseentity.cpp, only addTempItem() to grant one. Removing a temp item
        -- uses the normal delItem(), pointed at the temp-items container via
        -- LOC_TEMPITEMS (same pattern as Imperial_Stormer.lua/Quhaaja.lua).
        player:delItem(ORE_ITEM, 1, LOC_TEMPITEMS)

        player:showText(npc, ID.text.MULWAHAH_ORE_TURNED_IN_1)

        -- 2026-09-14, crash-reported (garbage objtype/id in showText's `self`, via a queued AI
        -- action). Live debugger inspection proved it's PLAYER that goes invalid here (classic
        -- use-after-free: id=4123655840, objtype=-171311456), not npc -- npc's own data (arg 1)
        -- was completely sane at the crash point. Re-resolve BOTH by id when each timer actually
        -- fires: npc via npc:timer()'s own fresh callback argument (same proven mechanism as
        -- mob:timer(ms, tick) in Clavauert_B_Chanoix.lua), player via GetPlayerByID() (returns nil
        -- if they've since disconnected). Bail cleanly if either is gone.
        local playerId = player:getID()

        npc:timer(3000, function(npc)
            local livePlayer = GetPlayerByID(playerId)
            if not npc or not livePlayer then
                return
            end

            -- 2026-09-10 REAL BUG FOUND AND FIXED, user-reported live (screenshot showed "This is
            -- definitely  !" with a blank instead of the item name): the item param was wired to
            -- the WRONG line. Per IDs.lua's own real text comments, MULWAHAH_ORE_TURNED_IN_2
            -- (7533) is "Amazing... Look at it shine! This is definitely <item> Validated" -- the
            -- one with the real item-name placeholder -- while MULWAHAH_ORE_TURNED_IN_3 (7534,
            -- "The rumors were true! Excellent work!") has no placeholder at all. ORE_ITEM was
            -- being passed to line 3 (where it does nothing) instead of line 2 (where the client
            -- actually needed it to resolve the name). Not a messageSpecialFrom()/packet mechanism
            -- problem -- that part was already correct.
            livePlayer:showText(npc, ID.text.MULWAHAH_ORE_TURNED_IN_2, ORE_ITEM)

            npc:timer(3000, function(npc)
                local livePlayer2 = GetPlayerByID(playerId)
                if not npc or not livePlayer2 then
                    return
                end
                livePlayer2:showText(npc, ID.text.MULWAHAH_ORE_TURNED_IN_3)
            end)
        end)

        ----------------------------------------------------------------
        -- Complete the Assault after the three dialogue lines have
        -- been displayed.
        ----------------------------------------------------------------
        if instance then
            npc:timer(9000, function()
                if instance then
                    instance:complete()
                end
            end)
        end

        return
    end

    ----------------------------------------------------------------
    -- Player already has a valid Pickaxe.
    ----------------------------------------------------------------
    if player:hasItem(PICKAXE_ITEM) then

        player:showText(
            npc,
            ID.text.MULWAHAH_ALREADY_HAVE_PICKAXE,
            PICKAXE_ITEM,
            0, 0, 0,
            true
        )

        return
    end

    ----------------------------------------------------------------
    -- First interaction.
    --
    -- Give the player a temporary Pickaxe and display the dialogue
    -- telling them to find and return with Orichalcum Ore.
    ----------------------------------------------------------------
    player:showText(
        npc,
        ID.text.MULWAHAH_PICKAXE_GRANT,
        ORE_ITEM,
        0, 0, 0,
        true
    )

    player:addTempItem(PICKAXE_ITEM)

    player:messageSpecial(
        ID.text.PLAYER_OBTAINS_TEMP_ITEM,
        PICKAXE_ITEM
    )

    return
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

