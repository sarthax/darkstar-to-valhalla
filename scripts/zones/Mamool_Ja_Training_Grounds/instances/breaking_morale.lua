-----------------------------------
-- Assault: Breaking Morale
-----------------------------------
-- Built 2026-08-18 from data found sitting unwired in this repo's own SQL: 18 real mobs (7
-- Mamool Ja Recruit + 11 Mamool Ja Trainer), comment-labeled "-- breaking morale" in
-- sql/mob_spawn_points.sql, directly after Sagelord Elimination's block.
--
-- Corrected 2026-08-18 (later) from a real Thris Nov 2025 capture: this is NOT a kill-all. The
-- capture's CapLog/NPCLogger showed the real loop is loot 8 Supplies Crates scattered around
-- camp and turn them in to Quhaaja (see npcs/Supplies_Crate.lua, npcs/Quhaaja.lua) -- the 18
-- Recruit/Trainer mobs are real spawn data too, but function as ambient camp guards rather than
-- kill targets, matching "Steal the supplies" (the real ASSAULT_14_START text, which never fit
-- a kill-all reading anyway).
--
-- 2026-08-19 re-analysis (both Breaking Morale captures, including the previously-written-off
-- "(4)" one): completion count of 8 is STILL unconfirmed -- neither capture ever actually
-- completed the mission (both timed out/failed). Capture 1 (solo) managed only 6 successful
-- Quhaaja turn-ins in the real 15-minute time limit (confirmed correct in instance_list.sql)
-- before failing; that's circumstantial evidence 8 may be a tight ask solo, but not proof the
-- real threshold is lower -- a full party could plausibly reach 8. Left at 8 (matches the real
-- physical crate count exactly) pending a capture that actually completes.
--
-- Viscous Liquid (real position 52/0/-298, see IDs.lua) mechanic IS now pinned down precisely
-- from the "(4)" capture's eventview log plus capture 1's CapLog: it is NOT a player-triggered
-- prop. A Mamool Ja Trainer periodically uses hate/aggro on the player ("Scaleless heathen... A
-- taste of my wrath, you shall have!"), which teleports the player to Viscous Liquid ("You seem
-- to have been brought here by some strange magic...", "There is a curious liquid here.",
-- "Thris is overcome by a peculiar sensation."). If the player is currently holding an
-- uncollected Supplies Crate temp item at that moment, it's removed ("The supplies you seized
-- are missing!", real MesNum 7545 confirmed via dat-extractor) -- if not holding one (already
-- turned in), nothing happens. Confirmed via exact timestamp correlation across capture 1: every
-- single teleport event lines up 1:1 with either an item loss (if held) or no message (if not).
-- NOT wired in -- implementing the actual trigger (a mob periodically teleporting its target to a
-- fixed NPC + firing a CS-event dialogue sequence) has no existing pattern in this codebase, and
-- the exact trigger cadence/condition (hate-based? fixed timer? recast on a TP-style move?) isn't
-- pinned down precisely enough by a single capture to hard-code with confidence -- see
-- Assault_Fix_Log.md/Assault_Issue_Tracker.md for the full writeup so a future pass has the real
-- message IDs and behavior confirmed already.
--
-- 2026-08-24, NPCLogger crossref pipeline re-run: found the 18 Recruit/Trainer mobs above were
-- all still sitting at the literal (0,0,0) placeholder in mob_spawn_points.sql (spawning stacked
-- at the map origin instead of scattered around camp) -- fixed with real positions from the same
-- Thris Nov2025 capture. Also found this script never repositioned Rune of Release/Ancient
-- Lockbox at all (~80 yalm miss off the shared cross-mission default) -- added real setPos()
-- calls below. Both fixes are single-observation confidence (not cross-verified by a 2nd
-- independent capture) -- a 2019 Dropbox [W]in capture ("2 treasures (partial win)... costume
-- use, capture, killing mamool") was found cataloged in discord_captures/mission_source_catalog.md
-- but not yet downloaded/mined; worth a follow-up pass since it's the only known WIN capture for
-- this mission (both local captures timed out/failed) and could pin down the still-open
-- completion-threshold and Viscous Liquid trigger-cadence questions above.
-----------------------------------
require("scripts/globals/instance")
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
require("scripts/globals/status")
-----------------------------------
-- Real 7 Mamool Ja Recruit + 11 Mamool Ja Trainer ids (were ID.mob[14] under the old
-- LandSandBoat-targeted IDs.lua; that per-instance mob-group shape has no old-dsp-reference
-- equivalent -- see TextIDs.lua's own header -- so hardcoded directly here instead, same
-- convention as old-dsp-reference's own Rune_of_Release.lua/Ancient_Lockbox.lua).
local MOB_GROUP_14 = {
    17047610, 17047611, 17047612, 17047613, 17047614, 17047615, 17047616,
    17047617, 17047618, 17047619, 17047620, 17047621, 17047622, 17047623,
    17047624, 17047625, 17047626, 17047627,
}
-----------------------------------
function afterInstanceRegister(player)
    local instance = player:getInstance()
    player:messageSpecial(ASSAULT_14_START, 14)
    player:messageSpecial(TIME_TO_COMPLETE, instance:getTimeLimit())
end

-- Same fix as Leujaoam_Sanctum / Lebros_Cavern: without MOBMOD_ALWAYS_AGGRO a mob only aggros a
-- player when the exp gain is > 50 (zone_entities.cpp), so low-level instance mobs never aggro
-- high-level players. Only takes effect for mobs whose pool has aggro=1 (m_Aggro gate).
local function forceAggro(mob)
    if mob then
        mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    end
end

function onInstanceCreated(instance)
    for _, v in ipairs(MOB_GROUP_14) do
        forceAggro(SpawnMob(v, instance))
    end

    -- 2026-08-24: this script never repositioned Rune of Release/Ancient Lockbox -- they were
    -- sitting at npc_list's shared cross-mission default (-58/-55, 1.3-1.5, -103), ~80 yalms from
    -- the real captured position. Real position from the NPCLogger crossref pipeline (Thris
    -- Nov2025 "LC - Breaking Morale" capture): both round to the same integer-precision
    -- (18, 2, -136) -- this capture's positions are integer-rounded throughout, not necessarily
    -- two objects truly stacked exactly on top of each other, but this is the best real data
    -- available (single observation, not cross-verified by a 2nd independent capture).
    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setPos(18, 2, -136, 59)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setPos(20, 2, -136, 59)

    -- 2026-08-24: _1ub/_1u5 are shared door/gate props also used by other Mamool Ja missions --
    -- editing their SQL default in npc_list.sql would risk moving them for every OTHER mission
    -- too, whose real captures haven't been checked for agreement. Per-instance setPos() override
    -- (same pattern already used for Orichalcum Survey/Leujaoam Cleansing) fixes this mission's
    -- own real drift (_1ub 53 yalms, _1u5 172 yalms off the shared default) without touching the
    -- shared row at all. Real positions from the same Thris Nov2025 capture, single-observation
    -- confidence.
    instance:getEntity(bit.band(17047870, 0xFFF), TYPE_NPC):setPos(-137, -8, -198, 0)
    instance:getEntity(bit.band(17047864, 0xFFF), TYPE_NPC):setPos(-18, 0, -397, 0)

    -- 2026-08-27, user-reported: all doors in this mission impassable. Tried adding explicit
    -- setAnimation(8)/setStatus(NORMAL) to all 6 registered door props (matching Imperial Agent
    -- Rescue's pattern for the shared _1u5) -- user confirmed live this did NOT fix it. Reverted.
    -- User's correction: these numeric ids are keyed to fixed client-side geometry/rotation/
    -- function baked into the zone's compiled dat -- renaming/repositioning them in our own SQL
    -- doesn't change what the client actually associates with that id, and the _1u1-_1ul
    -- identity-shift correction (done for Imperial Agent Rescue) may have reintroduced whatever
    -- was previously "mostly under control" here. Needs the zone-69-navmesh-style diagnosis
    -- (`zone:checkNavPath()`/live `!checknav`, per topaz_1x_prop_blocker_diagnosis) to tell a real
    -- broken door apart from a baked-terrain blocker, rather than more Lua/SQL guessing.

    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setStatus(STATUS_DISAPPEAR)
end

-- Viscous Liquid / Supplies Crate mechanics, driven from the instance tick (no entity:timer
-- closures). A costumed player can never trigger an NPC on this engine (packet_system.cpp), so
-- the costume must be stripped server-side when they walk up to a crate.
local SUPPLIES_CRATES = { 17047813, 17047814, 17047815, 17047816, 17047817, 17047818, 17047819, 17047820 }
local STRIP_RANGE   = 4.0  -- ESTIMATE
local REFRESH_RANGE = 20.0 -- ESTIMATE
local DOT_DAMAGE    = 30
local DOT_TICK_MS   = 3000
local SPEED_REDUCTION = 10 -- must match npcs/Viscous_Liquid.lua

local function updateCostumeAndCrates(instance, elapsed)
    for _, player in pairs(instance:getChars()) do
        local costumed = player:hasStatusEffect(EFFECT_COSTUME)

        if costumed then
            if player:getLocalVar("vlDotAt") == 0 or elapsed - player:getLocalVar("vlDotAt") >= DOT_TICK_MS then
                player:setLocalVar("vlDotAt", elapsed)
                if player:getHP() > DOT_DAMAGE then
                    player:delHP(DOT_DAMAGE)
                end
            end
        elseif player:getLocalVar("vlSlow") == 1 then
            player:delMod(MOD_HASTE_MAGIC, -SPEED_REDUCTION)
            player:setLocalVar("vlSlow", 0)
        end

        for _, crateId in ipairs(SUPPLIES_CRATES) do
            local crate = instance:getEntity(bit.band(crateId, 0xFFF), TYPE_NPC)
            if crate then
                local dist = player:checkDistance(crate)
                if costumed and dist <= STRIP_RANGE then
                    player:delStatusEffect(EFFECT_COSTUME)
                end
                -- returning player gets a fresh spawn packet that renders an opened crate as
                -- closed; toggle animationsub 0 -> 1 to re-send the correct state.
                local key = "near" .. bit.band(crateId, 0xFFF)
                local isNear = dist <= REFRESH_RANGE
                if isNear and player:getLocalVar(key) == 0 and crate:getLocalVar("opened") == 1 then
                    crate:AnimationSub(0)
                    crate:AnimationSub(1)
                    crate:updateAnimationSub()
                end
                player:setLocalVar(key, isNear and 1 or 0)
            end
        end
    end
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, { PARTY_FALLEN = PARTY_FALLEN, TIME_REMAINING_MINUTES = TIME_REMAINING_MINUTES, TIME_REMAINING_SECONDS = TIME_REMAINING_SECONDS })
    updateCostumeAndCrates(instance, elapsed)
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(MISSION_FAILED, 10, 10)
        v:startEvent(102)
    end
end

-- 2026-08-22: removed the `progress >= 8` auto-complete -- confirmed wrong per FFXIclopedia.
-- Completion is player-choice via Quhaaja's "give up" option (real minimum 1 item solo, 2+ in a
-- party), not an automatic all-8-crates requirement -- see npcs/Quhaaja.lua.
function onInstanceProgressUpdate(instance, progress)
end

function onInstanceComplete(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(RUNE_UNLOCKED_POS, 7, 6)
    end

    instance:getEntity(bit.band(17047809, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
    instance:getEntity(bit.band(17047808, 0xFFF), TYPE_NPC):setStatus(STATUS_NORMAL)
end

function onEventUpdate(player, csid, option)
end

