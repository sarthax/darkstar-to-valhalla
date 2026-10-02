-----------------------------------
-- func: nyzuldebug complete | nyzuldebug floor <N> | nyzuldebug reroll | nyzuldebug layout <N>|clear
-- desc: GM debug command -- lets you test Nyzul Isle Investigation floor objectives/win
--       conditions without climbing 100 floors of random rolls to reach them.
--
--       !nyzuldebug complete      -- force-completes the CURRENT floor's objective regardless of
--                                     stage (works for both the "flag" objectives -- Free Floor,
--                                     Eliminate Enemy Leader, Activate All Lamps, Eliminate
--                                     Specified Enemy -- and the "counter" ones -- Eliminate All
--                                     Enemies, Eliminate Specified Enemies -- by zeroing the
--                                     required count alongside setting progress=15, satisfying
--                                     handleProgress's real check either way, scripts/globals/
--                                     nyzul.lua). Lights the Rune of Transfer immediately.
--       !nyzuldebug floor <N>     -- jumps straight to floor N (1-100) on your NEXT Rune of
--                                     Transfer "next floor" interaction, by setting
--                                     Nyzul_Current_Floor to N-1 (Rune_of_Transfer.lua always
--                                     advances by exactly +1) and force-completing the current
--                                     floor so the Rune lights up right away. This is the only
--                                     way to land on an EXACT boss floor (20/40/60/80/100) --
--                                     the real token-based floor-select menu only offers 5-floor
--                                     checkpoints (1/6/11.../96), never those exact numbers.
--       !nyzuldebug reroll        -- re-rolls the CURRENT floor's objective/spawns in place
--                                     (calls the same real instance_object.pickSetPoint the
--                                     engine uses on a normal floor transition) -- keep running
--                                     this until you land on the specific objective you want to
--                                     test, without spending a floor transition on it.
--       !nyzuldebug layout <N>    -- pins Nyzul_Isle_FloorLayout to an exact value (1-16, see
--                                     scripts/globals/nyzul.lua's Nyzul.FloorLayout table)
--                                     instead of pickSetPoint's normal random roll, then
--                                     immediately rerolls so it takes effect right away. Stays
--                                     pinned across further rerolls/floor transitions until
--                                     cleared.
--       !nyzuldebug layout clear  -- removes the pin, restoring the normal random roll.
--       !nyzuldebug leader <name> -- pins a specific Eliminate Enemy Leader mob (e.g.
--                                     ginger_custard, vanilla_custard, mokke, shielded_chariot --
--                                     any of the 24 real names in this file's own IDs.mob[51]
--                                     leader list) instead of the normal random pick from the full
--                                     pool, then immediately rerolls so the current floor's stage
--                                     is forced to ELIMINATE_ENEMY_LEADER and that mob spawns right
--                                     away. Stays pinned across further rerolls/floor transitions
--                                     until '!nyzuldebug leader clear'.
--       !nyzuldebug leader clear  -- removes the pin, restoring the normal random roll.
--
--       Must be run while standing inside a live Nyzul Isle Investigation instance
--       (!warpassault 51, then actually enter/create the floor loop via the entrance rune, or
--       already be mid-run).
-----------------------------------
local nyzulIsleInvestigation = require("scripts/zones/Nyzul_Isle/instances/nyzul_isle_investigation")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------

cmdprops =
{
    permission = 1,
    parameters = "ss"
}

local function printUsage(player)
    player:PrintToPlayer("Usage: !nyzuldebug complete | !nyzuldebug floor <N> | !nyzuldebug reroll | !nyzuldebug layout <N>|clear | !nyzuldebug leader <name>|clear")
end

function onTrigger(player, subcommand, arg)
    local instance = player:getInstance()
    if not instance or instance:getID() ~= 51 then
        player:PrintToPlayer("[NYZULDEBUG] You are not inside a live Nyzul Isle Investigation instance.")
        return
    end

    if subcommand == "complete" then
        instance:setLocalVar("Eliminate", 0)
        instance:setProgress(15)
        player:PrintToPlayer("[NYZULDEBUG] Current floor objective force-completed. The Rune of Transfer should light up.")
    elseif subcommand == "floor" then
        local floor = tonumber(arg)
        if not floor or floor < 1 or floor > 100 then
            player:PrintToPlayer("[NYZULDEBUG] Invalid floor number (must be 1-100).")
            printUsage(player)
            return
        end
        instance:setLocalVar("Nyzul_Current_Floor", floor - 1)
        instance:setLocalVar("Eliminate", 0)
        instance:setProgress(15)
        player:PrintToPlayer(string.format("[NYZULDEBUG] Current floor force-completed and Nyzul_Current_Floor primed -- next Rune of Transfer advance will land on floor %d.", floor))
    elseif subcommand == "reroll" then
        nyzulIsleInvestigation.pickSetPoint(instance)
        player:PrintToPlayer(string.format("[NYZULDEBUG] Floor %d re-rolled -- new objective/spawns apply in ~1s (real despawn/respawn delay). Check the Rune of Transfer for the new objective text.", instance:getLocalVar("Nyzul_Current_Floor")))
    elseif subcommand == "layout" then
        if arg == "clear" then
            instance:setLocalVar("Nyzul_Debug_ForceLayout", 0)
            player:PrintToPlayer("[NYZULDEBUG] Layout pin cleared -- next reroll/floor transition uses the normal random roll.")
            return
        end
        local layout = tonumber(arg)
        if not layout or layout < 1 or layout > 16 then
            player:PrintToPlayer("[NYZULDEBUG] Invalid layout number (must be 1-16, or 'clear').")
            printUsage(player)
            return
        end
        instance:setLocalVar("Nyzul_Debug_ForceLayout", layout)
        nyzulIsleInvestigation.pickSetPoint(instance)
        player:PrintToPlayer(string.format("[NYZULDEBUG] Layout pinned to %d, applies in ~1s (real despawn/respawn delay). Stays pinned across further rerolls until '!nyzuldebug layout clear'.", layout))
    elseif subcommand == "leader" then
        if arg == "clear" then
            instance:setLocalVar("Nyzul_Debug_ForceLeader", 0)
            player:PrintToPlayer("[NYZULDEBUG] Leader pin cleared -- next reroll/floor transition uses the normal random roll.")
            return
        end
        local leaderId = NyzulIsle.mobs[51][string.upper(arg or "")]
        if not leaderId then
            player:PrintToPlayer("[NYZULDEBUG] Unknown leader name. Use a real IDs.mob[51] leader name, e.g. ginger_custard, vanilla_custard, mokke, shielded_chariot.")
            printUsage(player)
            return
        end
        instance:setLocalVar("Nyzul_Debug_ForceLeader", leaderId)
        nyzulIsleInvestigation.pickSetPoint(instance)
        player:PrintToPlayer(string.format("[NYZULDEBUG] Leader pinned to %s, applies in ~1s (real despawn/respawn delay). Stays pinned across further rerolls until '!nyzuldebug leader clear'.", arg))
    else
        printUsage(player)
    end
end
