-----------------------------------
-- func: warpassault <instanceid> | warpassault leave | warpassault list
-- desc: GM debug command - bypasses the assault officer NPC and runic
--       portal entirely, letting you enter or exit any Assault instance
--       directly without playing through the normal trigger sequence.
--
--       "instanceid" is the current assault mission id
--       (CCharEntity::m_assaultLog.current, exposed to Lua as
--       player:getCurrentAssault()/addAssault()/delAssault()). Only one
--       assault can be active on a character at a time -- entering a new
--       one automatically clears whatever was active before.
--
-- Usage: !warpassault 1          -- enter mission 1 (leujaoam_cleansing)
--        !warpassault leave      -- warp out of the current assault instance
--                                    and clear the active-assault flag
--        !warpassault list       -- print all known instanceids + zone IDs
--
-- Self-contained (2026-08-18): createInstance()'s ready callback is
-- resolved server-side via the character's CURRENT zone (see
-- Leujaoam_Sanctum/Zone.lua for the full root-cause writeup), so you must
-- actually be standing in the mission's own zone for entry to work. This
-- command now checks that automatically -- if you're in the wrong zone it
-- warps you there and asks you to run the command again, instead of
-- silently failing. (One extra invocation is unavoidable: zoning is
-- asynchronous, so there's no way to warp-then-enter inside a single
-- command call.)
--
-- Table below is generated directly from sql/instance_list.sql
-- (2026-08-18) -- covers all 50 built Assault missions (1-50) plus the
-- pre-existing non-Assault instanced content that already used this
-- table before (53, 54, 58, 59, 65, 79), plus the Salvage Remnants zones
-- added 2026-09-04 (62 Zhayolm, 68 Bhaflau, 71 Silver Sea).
-----------------------------------
cmdprops =
{
    permission = 1,
    parameters = "s"
}

local assault_missions =
{
    [1] = { zone = 69, entrance = 79, name = 'leujaoam_cleansing' },
    [2] = { zone = 69, entrance = 79, name = 'orichalcum_survey' },
    [3] = { zone = 69, entrance = 79, name = 'escort_professor_chanoix' },
    [4] = { zone = 69, entrance = 79, name = 'shanarha_grass_conservation' },
    [5] = { zone = 69, entrance = 79, name = 'counting_sheep' },
    [6] = { zone = 69, entrance = 79, name = 'supplies_recovery' },
    [7] = { zone = 69, entrance = 79, name = 'azure_experiments' },
    [8] = { zone = 69, entrance = 79, name = 'imperial_code' },
    [9] = { zone = 69, entrance = 79, name = 'red_versus_blue' },
    [10] = { zone = 69, entrance = 79, name = 'bloody_rondo' },
    [11] = { zone = 66, entrance = 52, name = 'imperial_agent_rescue' },
    [12] = { zone = 66, entrance = 52, name = 'preemptive_strike' },
    [13] = { zone = 66, entrance = 52, name = 'sagelord_elimination' },
    [14] = { zone = 66, entrance = 52, name = 'breaking_morale' },
    [15] = { zone = 66, entrance = 52, name = 'the_double_agent' },
    [16] = { zone = 66, entrance = 52, name = 'imperial_treasure_retrieval' },
    [17] = { zone = 66, entrance = 52, name = 'blitzkrieg' },
    [18] = { zone = 66, entrance = 52, name = 'marids_in_the_mist' },
    [19] = { zone = 66, entrance = 52, name = 'azure_ailments' },
    [20] = { zone = 66, entrance = 52, name = 'the_susanoo_shuffle' },
    [21] = { zone = 63, entrance = 61, name = 'excavation_duty' },
    [22] = { zone = 63, entrance = 61, name = 'lebros_supplies' },
    [23] = { zone = 63, entrance = 61, name = 'troll_fugitives' },
    [24] = { zone = 63, entrance = 61, name = 'evade_and_escape' },
    [25] = { zone = 63, entrance = 61, name = 'siegemaster_assassination' },
    [26] = { zone = 63, entrance = 61, name = 'apkallu_breeding' },
    [27] = { zone = 63, entrance = 61, name = 'wamoura_farm_raid' },
    [28] = { zone = 63, entrance = 61, name = 'egg_conservation' },
    [29] = { zone = 63, entrance = 61, name = 'operation:black_pearl' },
    [30] = { zone = 63, entrance = 61, name = 'better_than_one' },
    [31] = { zone = 56, entrance = 79, name = 'seagull_grounded' },
    [32] = { zone = 56, entrance = 79, name = 'requiem' },
    [33] = { zone = 56, entrance = 79, name = 'saving_private_ryaaf' },
    [34] = { zone = 56, entrance = 79, name = 'shooting_down_the_baron' },
    [35] = { zone = 56, entrance = 79, name = 'building_bridges' },
    [36] = { zone = 56, entrance = 79, name = 'stop_the_bloodshed' },
    [37] = { zone = 56, entrance = 79, name = 'defuse_the_threat' },
    [38] = { zone = 56, entrance = 79, name = 'operation:snake_eyes' },
    [39] = { zone = 56, entrance = 79, name = 'wake_the_puppet' },
    [40] = { zone = 56, entrance = 79, name = 'the_price_is_right' },
    [41] = { zone = 55, entrance = 54, name = 'golden_salvage' },
    [42] = { zone = 55, entrance = 54, name = 'lamia_no_13' },
    [43] = { zone = 55, entrance = 54, name = 'extermination' },
    [44] = { zone = 55, entrance = 54, name = 'demolition_duty' },
    [45] = { zone = 55, entrance = 54, name = 'searat_salvation' },
    [46] = { zone = 55, entrance = 54, name = 'apkallu_seizure' },
    [47] = { zone = 55, entrance = 54, name = 'lost_and_found' },
    [48] = { zone = 55, entrance = 54, name = 'deserter' },
    [49] = { zone = 55, entrance = 54, name = 'desperately_seeking_cephalopods' },
    [50] = { zone = 55, entrance = 54, name = 'bellerophons_bliss' },
    [53] = { zone = 60, entrance = 54, name = 'the_black_coffin' },
    [54] = { zone = 60, entrance = 54, name = 'against_all_odds' },
    [58] = { zone = 77, entrance = 72, name = 'path_of_darkness' },
    [59] = { zone = 77, entrance = 72, name = 'nashmeiras_plea' },
    [51] = { zone = 77, entrance = 72, name = 'nyzul_isle_investigation' },
    [52] = { zone = 77, entrance = 72, name = 'nyzul_isle_uncharted_survey' },
    [62] = { zone = 73, entrance = 72, name = 'zhayolm_remnants' },
    [65] = { zone = 74, entrance = 72, name = 'arrapago_remnants' },
    [68] = { zone = 75, entrance = 72, name = 'bhaflau_remnants' },
    [71] = { zone = 76, entrance = 72, name = 'silver_sea_remnants' },
    [79] = { zone = 56, entrance = 79, name = 'shades_of_vengeance' },
    [80] = { zone = 77, entrance = 72, name = 'heroines_holdfast' },
}

local function printUsage(player)
    player:PrintToPlayer("Usage: !warpassault <instanceid> | !warpassault leave | !warpassault list")
    player:PrintToPlayer("Use !warpassault list to see all valid instanceids.")
end

local function printList(player)
    local ids = {}
    for id, _ in pairs(assault_missions) do
        table.insert(ids, id)
    end
    table.sort(ids)

    local line = ""
    for _, id in ipairs(ids) do
        local entry = string.format("%d(z%d)=%s", id, assault_missions[id].zone, assault_missions[id].name)
        if #line + #entry > 200 then
            player:PrintToPlayer(line)
            line = ""
        end
        line = line .. entry .. "  "
    end
    if line ~= "" then
        player:PrintToPlayer(line)
    end
    player:PrintToPlayer("Format: instanceid(zZoneID)=name. You do not need to !zone there yourself -- !warpassault <id> does it for you if needed.")
end

function onTrigger(player, target)
    if not target or target == "" then
        printUsage(player)
        return
    end

    if target == "list" then
        printList(player)
        return
    end

    if target == "leave" then
        -- Check the LIVE instance (player:getInstance()), not
        -- getCurrentAssault() (2026-08-18, found via a real repro): the
        -- assault-log flag and the actual CInstance registration can drift
        -- apart. Previously "leave" only cleared the log flag and warped
        -- the player away, but never told the CInstance it was abandoned
        -- -- the engine's normal zone-in recovery (CharRegistered() in
        -- CZoneInstance::IncreaseZoneCounter) would silently reattach the
        -- player to that same stale instance the moment they walked back
        -- into the zone by ANY means, even without running !warpassault
        -- again. getCurrentAssault() was already 0 by then (delAssault
        -- already ran the first time), so a second "leave" wrongly
        -- reported "no active assault" while the player was still very
        -- much inside a live, un-failed instance.
        local instance = player:getInstance()

        if not instance then
            player:PrintToPlayer("[WARP] You do not have an active assault to leave.")
            return
        end

        local instanceId = instance:getID()
        local mission = assault_missions[instanceId]
        -- 2026-09-09: real fix -- user-confirmed live bug: falling back to player:getZoneID() is
        -- always wrong for ANY instance (an instance's zone id IS the same as its host zone --
        -- that's what makes it that zone's instance), so this fallback was silently landing the
        -- player right back in the same zone they were trying to leave. Exposed concretely by an
        -- invalid instanceId (0, an unregistered "bare" instance -- assault_missions[0] is nil)
        -- looping the player back into the same broken instance at (0,0,0) instead of actually
        -- leaving. Falls back to Aht Urhgan Whitegate (zone 50, confirmed via zone_settings.sql)
        -- -- a real, always-safe non-instanced hub -- instead of the current zone.
        local entranceZone = mission and mission.entrance or 50

        player:PrintToPlayer(string.format("[WARP] Leaving instance %d%s, ending it and warping to zone %d...",
            instanceId, mission and (" (" .. mission.name .. ")") or "", entranceZone))

        -- fail() properly marks the instance INSTANCE_FAILED and runs its
        -- real cleanup (CInstance::Fail() -> Cancel()/ClearEntities()/
        -- OnInstanceFailure) so the engine's own per-tick sweep
        -- (CZoneInstance::ZoneServer) actually erases it once we've zoned
        -- out -- the same mechanism CreateInstance()'s stale-instance
        -- guard already relies on. Without this the instance just sits
        -- there forever, silently reachable again on the next zone-in.
        instance:fail()
        player:delAssault(instanceId)
        player:setPos(0, 0, 0, 0, entranceZone)
        return
    end

    local assaultid = tonumber(target)

    if not assaultid or not assault_missions[assaultid] then
        printUsage(player)
        return
    end

    local mission = assault_missions[assaultid]

    -- Guard against re-entering the exact instance you're already standing
    -- in (2026-08-18, found via a real crash): if you're already inside
    -- this mission's live instance, calling createInstance() again makes a
    -- SECOND live CInstance with the same id while you're still registered
    -- to the first one, and the client gets confused about which one it's
    -- leaving vs entering when setPos() fires -- crashed the server. The
    -- C++ side (CZoneInstance::CreateInstance) correctly refuses to evict
    -- you from an instance with active chars, but that alone isn't enough
    -- -- we have to not ask for a duplicate in the first place.
    local currentInstance = player:getInstance()
    if currentInstance and currentInstance:getID() == assaultid then
        player:PrintToPlayer(string.format("[WARP] You are already inside mission %d (%s). Use !warpassault leave first if you want to re-enter fresh.", assaultid, mission.name))
        return
    end

    -- createInstance()'s ready callback resolves via the character's
    -- CURRENT zone (PChar->loc.zone in luautils::OnInstanceCreated's
    -- fallback path -- see Leujaoam_Sanctum/Zone.lua for the full
    -- writeup), so we can't create-and-enter unless we're already
    -- standing in the mission's own zone. Move the player there first and
    -- ask them to re-run the command -- zoning is asynchronous, so there
    -- is no way to chain "warp then enter" inside a single call.
    if player:getZoneID() ~= mission.zone then
        player:PrintToPlayer(string.format("[WARP] Mission %d (%s) requires zone %d -- you are in zone %d. Moving you there now.", assaultid, mission.name, mission.zone, player:getZoneID()))
        player:PrintToPlayer(string.format("[WARP] Once you've zoned in, run !warpassault %d again to enter the instance.", assaultid))
        player:setPos(0, 0, 0, 0, mission.zone)
        return
    end

    -- Always clear whatever assault is currently active first, even if
    -- it's the same id we're about to re-enter. addAssault() overwrites
    -- m_assaultLog.current unconditionally either way (just logs
    -- "player has a current assault" if we skip this), but going through
    -- delAssault explicitly keeps the quest-log packet/save state
    -- consistent and kills the log noise on repeat test runs.
    local current = player:getCurrentAssault()
    if current ~= 0 then
        player:delAssault(current)
    end

    player:PrintToPlayer(string.format("[WARP] Setting current assault to %d (%s) and entering the instance...", assaultid, mission.name))

    player:addAssault(assaultid)
    player:createInstance(assaultid, mission.zone)
end

-----------------------------------
-- NOTE: there is deliberately no onInstanceCreated() defined in this file.
-- createInstance()'s ready callback is resolved in C++ via
-- GetCacheEntryFromFilename(PChar->m_event.Script), which is only ever
-- populated for NPC-triggered events -- command scripts are re-executed
-- fresh every invocation via commandhandler.cpp and are never cached
-- under that lookup path, so a function defined here can never be found.
-- (This was the original bug -- an onInstanceCreated used to live in this
-- file and silently never ran.) The engine's fallback for an unresolved
-- callback is the character's CURRENT zone's own Zone.lua, which is why
-- the real handler now lives there instead -- see the onInstanceCreated
-- function in each of the 8 zones listed in assault_missions above, and
-- Leujaoam_Sanctum/Zone.lua specifically for the full root-cause writeup.
-----------------------------------
