-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast, instance_list id 80)
--  NPC: Rune of Transfer #1-#5 / Rune of Transfer ???
-- npc_list 17093431-17093435 = "#1-#5" (csid 301-305), 17093436-17093441 = hidden "???" (csid 306-311).
-- csid = 301 + (npc id - 17093431), decoded with explore_event.py from capture #237.
--   #1-#5 : "Warp to Floor ${number: 0}? (Difficulty: ${choice: 1})" Yes/No
--           capture params for #1: (1, 0, 2964, 144, 144, 0, 3, 4095) -- meaning NOT decoded
--   ???   : "Warp to the heroine's chamber?" Yes/No (result2 == 1 on Yes)
-- Separate script name from Rune_of_Transfer.lua (Investigation) because npc_list `name` drives script lookup.
-- Zone-level csid 300 DECODED (capture #237, all 15 uses): params = (destId, x*1000, z*1000, y*1000, rot*16, 0, tier, 4095).
-- The client only plays the fade; the server must setPos itself. Destination table is copied verbatim
-- from those captured params (rot below is the byte = rot/16). Rune -> dest: #1-#5 (301-305) -> 1-5,
-- ??? (306-311) -> 6-11 (306 -> 6 directly observed; the rest follow the capture's ordering, UNVERIFIED per rune).
-----------------------------------
require("scripts/globals/debug_print")
require("scripts/globals/titles")
require("scripts/globals/heroines_holdfast")
-----------------------------------
local FIRST_RUNE = 17093431
local FIRST_CSID = 301

local DEST = { -- x, y, z, rot, tier
    [0]  = {460.0,   0.0, -610.0,  64, 3}, -- hub / zone-in
    -- 2026-09-27: corrected from the placeholder (566.5,-540) -- that point sat east of the
    -- real floor-1 content entirely. Capture #237/#238 shows floor 1's real trash cluster
    -- (Fortune Ram/Lucky Mouse/Papa Monkey/Wood Bugard/Celebratory Coney x2/Unlucky Beak x3)
    -- spanning x=433-520, z=-556 to -433, with Lion (tier-1 boss) at the north end (460,-446.5)
    -- near Aldo/Gilgamesh. Landing just north of Lucky Mouse (498.5,-556), facing into the
    -- corridor (rot 0 = north here per the capture's own dir convention) -- UNVERIFIED LIVE,
    -- run !checknav 495 0 -550 before trusting this on the live navmesh.
    [1]  = {495.0,   0.0, -550.0,   0, 1},
    [2]  = {-260.0,  0.0, -380.0, 128, 2},
    [3]  = {20.0,    0.0, -420.0,   0, 3},
    [4]  = {-60.0,   0.0,  113.5,  64, 4},
    [5]  = {-380.0,  0.0,  420.0, 128, 3},
    [6]  = {460.0,   0.0, -470.0, 192, 1}, -- heroine chambers 6-10
    [7]  = {-331.5,  0.0, -380.0, 128, 0},
    [8]  = {-12.5,   0.0, -380.0, 128, 3},
    [9]  = {-20.0,  -4.0,  -31.0, 192, 4},
    [10] = {-450.0, -4.0,  419.5, 128, 3},
    [11] = {-490.0, -4.0, -260.0, 128, 5}, -- 6th battle arena
}

tpz.heroines.WARP_DEST = DEST -- read by tpz.heroines.tickPendingWarp

local function warpTo(player, dest)
    local d = DEST[dest]
    player:setLocalVar("HHWarpDest", dest)
    -- 2026-09-27: removed 2 extra trailing zeros beyond the file header's own DECODED capture
    -- shape (destId, x*1000, z*1000, y*1000, rot*16, 0, tier, 4095 -- 8 values, capture #237, all
    -- 15 uses) -- same over-padding pattern already fixed twice today in _20m.lua csid 405 and
    -- this file's own csid 301-305. Root-caused after "Yes" correctly registered (Result=1) but
    -- no warp occurred -- this call is what onEventFinish's warpTo() fires next, and it had the
    -- same bug.
    -- 2026-09-27 REVERTED: briefly padded this to 10 values to match returnToHub()'s csid 300 call,
    -- reasoning the two same-csid call sites should agree. That was backwards -- THIS 8-value form
    -- is the one with real capture evidence (file header: csid 300 confirmed at exactly 8 values
    -- across all 15 uses in capture #237, and an earlier session already found/fixed this exact
    -- call being over-padded once before). Padding it back to 10 regressed the bug: live log shows
    -- Result=1073741824 (0x40000000, a forced/cancelled finish) instead of a real fade completion --
    -- client hangs with no animation until the player cancels, which then still runs warpTo().
    -- Restored to 8. returnToHub()'s own csid 300 call (globals/heroines_holdfast.lua) is the
    -- outlier now and should be brought down to 8 to match, not the other way around.
    dbgPrint(string.format("[HRT DEBUG] warpTo dest=%d params=%d,%d,%d,%d,%d",
        dest, d[1] * 1000, d[3] * 1000, d[2] * 1000, d[4] * 16, d[5]))
    tpz.heroines.queueWarp(player)
    player:startEvent(300, dest, d[1] * 1000, d[3] * 1000, d[2] * 1000, d[4] * 16, 0, d[5], 4095)
end

function onTrade(player, npc, trade)
end

function onTrigger(player, npc)
    local csid = FIRST_CSID + npc:getID() - FIRST_RUNE
    -- 2026-09-27: debug instrumentation added (matches Runic_Lamp.lua's [LAMP DEBUG] pattern) --
    -- this onTrigger had NO logging at all, so a correctly-gated "rune locked" outcome (the
    -- else/no-else branches below) was indistinguishable in the map-server log from the
    -- dispatch never reaching this file at all. Needed to root-cause the reported
    -- "runic lamps still do not work" symptom after TargID=824 showed [TRIGGER DEBUG] firing
    -- but zero further output.
    dbgPrint(string.format("[HRT DEBUG] onTrigger npcid=%d csid=%d", npc:getID(), csid))
    if csid >= 301 and csid <= 305 then
        local tier = csid - 300
        local instance = npc:getInstance()
        -- 2026-09-29 (user): "the rune of transfers in the lobby are still active after defeating
        -- that floor's boss and clearing... gate the usage on the boss death." Previously this
        -- branch was unconditional ("always-fire") -- once heroines_holdfast.lua's onHeroineDeath
        -- sets HH_FloorDone<tier>=1 (that tier's boss dead), refuse the warp-in menu instead.
        if instance and instance:getLocalVar("HH_FloorDone" .. tier) == 1 then
            -- No confirmed dialog id exists for a "floor already cleared" line, so this just
            -- refuses the menu silently rather than fabricating text -- the animsub change in
            -- heroines_holdfast.lua (unlit) is the player-facing signal per the user's request.
            dbgPrint(string.format("[HRT DEBUG] branch=301-305 tier=%d gated -- floor already cleared", tier))
            return
        end
        -- 2026-09-29 (user): lobby rune #5 (Mumor) stays locked until floors 1-4 are cleared, so
        -- players can't skip straight to the last boss. Silent refusal, same as the cleared gate.
        if tier == 5 and instance and not tpz.heroines.floor5Unlocked(instance) then
            dbgPrint("[HRT DEBUG] branch=301-305 tier=5 gated -- floors 1-4 not yet cleared")
            return
        end
        dbgPrint(string.format("[HRT DEBUG] branch=301-305 (always-fire), tier=%d, calling startEvent", tier))
        -- 2026-09-27: RESTORED the real capture params -- user supplied a genuine Windower ID
        -- View capture screenshot showing Event 301 rendering correctly client-side with EXACTLY
        -- these 8 values (Actor 17093432 "Rune of Transfer #1", "Warp to Floor 1? (Difficulty:
        -- (star))" Yes/No menu). This disproves the brief "bare call" theory tried earlier today --
        -- explore_event.py's decompile showing a hardcoded npc:dialog(7566, 1, 0) was misleading
        -- (the decompiler doesn't resolve param-slot opcodes correctly here). The real original
        -- bug was 2 EXTRA trailing zeros beyond these 8 real values (same over-padding pattern as
        -- the _20m.lua csid 405 fix) -- removed those, kept everything else unchanged.
        -- 2026-09-28: params[0]/params[1] were hardcoded to (1, 0) -- rune #1's own captured
        -- values -- for EVERY rune #1-#5, so all 5 lobby lamps displayed "Floor 1" / 1 star
        -- regardless of which rune was actually clicked. Confirmed via explore_event.py's
        -- decompile of text id 7566: "Warp to Floor ${number: 0}? (Difficulty: ${choice: 1}
        -- [★/★★/★★★/★★★★/★★★★★])" -- params[0] is the ${number} floor-number slot, params[1] is
        -- the 0-indexed ${choice} slot selecting which star string renders (0=★ .. 4=★★★★★).
        -- Parameterized both on tier (csid-300, matching this rune's own DEST/HH_Rune<tier>
        -- number, 1-5) instead of the rune-#1-only hardcoded (1, 0); every other param is
        -- unchanged real capture data.
        player:startEvent(csid, tier, tier - 1, 2964, 144, 144, 0, 3, 4095)
    elseif csid >= 306 and csid <= 310 then
        -- tier = csid - 305; hidden until the tier objective is done (capture shows the objective text on early click)
        local tier = csid - 305
        local instance = npc:getInstance()
        local flag = instance and instance:getLocalVar("HH_Rune" .. tier)
        dbgPrint(string.format("[HRT DEBUG] branch=306-310 tier=%d instance=%s HH_Rune%d=%s",
            tier, tostring(instance ~= nil), tier, tostring(flag)))
        if instance and flag == 1 then
            -- 2026-09-29: STILL HANGS at 10 values (csid + 9 zeros) -- user reports floor 1's
            -- rune activates (HH_Rune1=1 confirmed in log) but clicking it just hangs, same
            -- symptom as the two prior over-padding bugs in this exact file (csid 300, csid
            -- 301-305). No real capture exists for 306-310 specifically, but every other branch
            -- in this file that DOES have real capture evidence (301-305, and csid 300 in
            -- heroines_holdfast.lua) uses exactly 8 total values, and every 10-value attempt on
            -- this same NPC family has hung. Dropping to the same 8-value shape as the confirmed
            -- 301-305 branch as the best-evidence hypothesis -- UNVERIFIED for 306-310
            -- specifically, retest live and get a real capture if this still hangs.
            player:startEvent(csid, 0, 0, 0, 0, 0, 0, 0)
        else
            dbgPrint("[HRT DEBUG] gated -- sending messageText (locked) instead of startEvent")
            player:messageText(npc, tier == 1 and tpz.heroines.TEXT_OBJ_ALDO or tpz.heroines.TEXT_OBJ_KILL, false)
        end
    elseif csid == 311 then
        -- 6th battle: usable from the start in the capture's second run (after all five were cleared).
        -- 2026-09-29 (user): "The 6th battle and rune of transfer should not work unless one
        -- player in party has entered with the title" -- party-wide, not just the clicking
        -- player. Checks every character currently in the instance, matching the pasted wiki
        -- text ("re-entering with that title reveals a 6th lamp") describing party access, not
        -- an individual requirement.
        local instance = npc:getInstance()
        local hasTitle = false
        if instance then
            for _, v in pairs(instance:getChars()) do
                if v:hasTitle(UNSUNG_HEROINE) then
                    hasTitle = true
                    break
                end
            end
        end
        dbgPrint(string.format("[HRT DEBUG] branch=311 hasTitle(party)=%s", tostring(hasTitle)))
        if hasTitle then
            -- 2026-09-29: same over-padding hypothesis as the 306-310 branch above -- dropped to
            -- the confirmed 301-305 8-value shape. UNVERIFIED for csid 311 specifically.
            player:startEvent(csid, 0, 0, 0, 0, 0, 0, 0)
        end
    else
        dbgPrint(string.format("[HRT DEBUG] csid=%d matched NO branch (npcid out of expected range?)", csid))
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
    -- 2026-09-27: debug instrumentation, same reason as onTrigger above -- needed to confirm
    -- warpTo() is actually being reached and with what dest, while chasing "menu answers Yes
    -- (Result=1) but no warp happens."
    dbgPrint(string.format("[HRT DEBUG] onEventFinish csid=%d option=%s", csid, tostring(option)))
    if csid >= 301 and csid <= 311 and option == 1 then
        local dest = csid - 300
        dbgPrint(string.format("[HRT DEBUG] onEventFinish: calling warpTo(dest=%d)", dest))
        -- 2026-09-29 (user): floor clear-time feature (dialog.yml 7563/7564, "direct precedent:
        -- every BCNM/KSNM battlefield does this") -- Topaz's CInstance has no getTimeInside()
        -- binding like CBattlefield does (checked src/map/lua/lua_instance.cpp -- only
        -- getTimeLimit/getLastTimeUpdate/getWipeTime exist), so this reuses the elapsed-ms clock
        -- the instance script already maintains every tick (HH_LastElapsedMs, see
        -- instances/heroines_holdfast.lua onInstanceTimeUpdate) instead of a new C++ binding --
        -- no rebuild needed. Floor-entry is csid 301-305's own "Yes" selection (dest 1-5 here IS
        -- the tier number directly, unlike DEST[]'s own tier field which isn't a clean 1:1 map),
        -- matching 7560's own documented candidate hook ("the per-floor warp path inside
        -- Heroine_Rune_of_Transfer.lua, csid 301-305").
        if dest >= 1 and dest <= 5 then
            local instance = player:getInstance()
            if instance then
                instance:setLocalVar("HH_FloorStartMs" .. dest, instance:getLocalVar("HH_LastElapsedMs"))
            end
        end
        warpTo(player, dest)
    elseif csid == 300 then
        local dest = player:getLocalVar("HHWarpDest")
        local d = DEST[dest]
        dbgPrint(string.format("[HRT DEBUG] onEventFinish csid=300: HHWarpDest=%s DEST entry=%s",
            tostring(dest), tostring(d ~= nil)))
        player:setLocalVar("HHWarpDest", 0)
        -- 2026-10-04: the reposition now happens mid-fade (tpz.heroines.tickPendingWarp); only fall
        -- back to repositioning here if the tick never got to it (very short fade).
        if d and player:getLocalVar("HHWarpPending") == 1 then
            player:setLocalVar("HHWarpPending", 0)
            player:setPos(d[1], d[2], d[3], d[4])
        end
        player:setLocalVar("HHWarpPending", 0)
        -- 2026-09-29 (user capture, "Heroines Holdfast Floor 5/Mumor clear", Windower ID View):
        -- confirmed real sequence -- csid 300 (this exact hub-warp, params match
        -- tpz.heroines.returnToHub's own call byte-for-byte) is immediately followed by a real
        -- csid 1 whenever the win condition (all 5 tiers, or the Floor 6 battle) was just met.
        -- csid 1 is the SAME generic instance-eject event already used by
        -- instances/heroines_holdfast.lua's onInstanceFailure and by Rune_of_Transfer.lua's own
        -- csid==1 handler (see that file's 2026-09-23 header note: "mirrors every zone's own
        -- Zone.lua onEventFinish csid==1 handler exactly") -- player:setPos(0,0,0,0,72), zone 72
        -- = Alzadaal_Undersea_Ruins (sql/zone_settings.sql). Needs its OWN csid==1 branch here
        -- (added below) rather than relying on Rune_of_Transfer.lua's/Zone.lua's, because
        -- m_event.Script stays pinned to whichever NPC the player last actually clicked -- for a
        -- Heroines' Holdfast run that's always this file (the floor-warp rune), never the
        -- Investigation Rune of Transfer or Zone.lua itself (same sticky-dispatch class already
        -- fixed for csid 95/csid 1 elsewhere in this codebase).
        --
        -- 2026-09-29 (user report): "warped to lobby but exit to zone 72 doesn't fire until you use
        -- another rune of transfer" -- root cause was calling player:startEvent(1) SYNCHRONOUSLY
        -- from inside this csid==300 finish handler: the client is still tearing down csid 300's
        -- own event state in the same tick and silently drops the second CEventPacket, while
        -- HH_FullClear was already consumed (set to 0) regardless, so the pending eject was lost
        -- until an unrelated later event happened to resync the client. Fix: defer the actual
        -- startEvent(1) by one short tick via the instance's own onInstanceTimeUpdate (see
        -- tpz.heroines.tickPendingEject in globals/heroines_holdfast.lua) instead of chaining it
        -- here -- same non-negotiable "no entity:timer() closures" pattern as tickReturnToHub.
        local instance = player:getInstance()
        -- 2026-09-30: HH_FullClear stays set on the instance (the first player through used to clear
        -- it, so the rest of the party never got the message/eject); each player consumes it via
        -- their own HH_FullClearDone flag instead.
        if instance and instance:getLocalVar("HH_FullClear") == 1 and player:getLocalVar("HH_FullClearDone") == 0 then
            player:setLocalVar("HH_FullClearDone", 1)
            player:messageSpecial(7561)
            player:setLocalVar("HH_PendingEjectMs", tpz.heroines.PENDING_EJECT_DELAY_MS)
        end
    elseif csid == 1 then
        player:setPos(0, 0, 0, 0, 72)
    end
end

