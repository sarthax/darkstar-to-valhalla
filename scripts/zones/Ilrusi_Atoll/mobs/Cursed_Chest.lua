-----------------------------------
-- Area: Ilrusi Atoll
--  Mob: Cursed Chest (Golden Salvage) -- pre-reveal state
-----------------------------------
-- 2026-09-01 (4th pass, real fix): onTrigger lives HERE, not in npcs/Cursed_Chest.lua -- confirmed
-- via direct C++ reading that luautils::OnEntityLoad() (the function that actually loads a script
-- into the Lua cache) only ever loads mobs/<name>.lua for a TYPE_MOB entity, never npcs/<name>.lua
-- -- so luautils::OnTrigger()'s old hardcoded "npcs" folder path could never have found this
-- entity's real script no matter what it contained. Fixed luautils::OnTrigger() itself
-- (src/map/lua/luautils.cpp:1603) to mirror OnEntityLoad's type-aware folder choice. See
-- documentation/research/Golden_Salvage_Mimic_Architecture_Fix_Scope.md.
--
-- mob_pools poolid 864 already defaults to modelid 960/animationsub 4 (both capture-confirmed as
-- the closed-chest baseline) -- set explicitly here too for certainty. onTrigger does the live
-- modelid(258)/animationsub(5)/setName("Mimic") reveal in place on this SAME entity.
--
-- 2026-09-01 correction: renaming does NOT switch which file governs future events, unlike the
-- earlier Ranch Wamoura investigation's setName() finding -- that finding was about setName(),
-- which DOES overwrite the real CBaseEntity::name field GetName() returns. setName() only
-- ever sets packetName (a display/packet-only override, confirmed again directly in
-- lua_baseentity.cpp) -- CBaseEntity::GetName() (baseentity.cpp:85) returns `name` unconditionally,
-- never packetName. getEntityCachedFunction() (luautils.cpp:357, used for onMobFight/onMobDeath/
-- onMobDespawn) resolves purely off GetName() -- so this entity's real internal name never
-- actually became "Mimic", and onMobFight in the former mobs/Mimic.lua was unreachable dead code
-- the whole time (user-reported: draw-in stopped working). Everything now lives in this one file,
-- keyed by this entity's real, never-changing name "Cursed_Chest". mobs/Mimic.lua deleted.
-----------------------------------
require("scripts/globals/status")
package.loaded["scripts/zones/Ilrusi_Atoll/TextIDs"] = nil;
require("scripts/zones/Ilrusi_Atoll/TextIDs");
local GoldenSalvageData = require("scripts/zones/Ilrusi_Atoll/GoldenSalvageData")
-----------------------------------
local CLOSED_MODEL_ID = 960
local CLOSED_ANIM_SUB = 4
local MIMIC_MODEL_ID  = 258
local MIMIC_ANIM_SUB  = 5

local function CheckForDrawnIn(centerX, centerY, centerZ, playerX, playerY, playerZ, Rayon, maxRayon)
    local difX = playerX - centerX
    local difY = playerY - centerY
    local difZ = playerZ - centerZ
    local Distance = math.sqrt(math.pow(difX, 2) + math.pow(difY, 2) + math.pow(difZ, 2))

    return Distance > Rayon and Distance < maxRayon
end

function onMobSpawn(mob)
    -- DIAGNOSTIC (uncomment for future debugging) -- confirms the SQL is actually live and this
    -- entity is registered/resolving as a mob at all: if this never prints on a fresh instance,
    -- check the SQL reimport first before anything else.
    -- print(string.format("[Cursed_Chest DEBUG] onMobSpawn -- id=%d name=%s",
    --     mob:getID(), mob:getName()))
    mob:setModelId(CLOSED_MODEL_ID)
    mob:AnimationSub(CLOSED_ANIM_SUB)
    -- poolid 864 has aggro=1 -- fine for an already-revealed Mimic, wrong for a disguised chest
    -- that hasn't been triggered yet (would ambush on proximity, bypassing onTrigger entirely).
    -- Re-enabled below once actually revealed.
    mob:setAggressive(false)
    -- CBaseEntity::Spawn() (baseentity.cpp:62) auto-sets status=STATUS_TYPE::MOB(1) whenever
    -- allegiance==MOB (this pool's default) -- real interactable NPCs default to
    -- STATUS_TYPE::NORMAL(0). This status byte (packet offset 0x20) is the real signal the
    -- client's own menu logic uses to decide whether to offer a check/trigger action at all --
    -- confirmed live: without this, the client only ever sent Attack/Disengage/Weaponskill
    -- actions, never Trigger (0x00), for this entity. Forcing NORMAL while disguised; flipped
    -- back below once the interaction has already happened.
    mob:setStatus(STATUS_NORMAL)
end

function onTrigger(player, npc)
    -- DIAGNOSTIC (uncomment for future debugging) -- confirms whether the engine actually
    -- dispatches onTrigger here at all. If it never prints when a chest is interacted with, check
    -- luautils::OnTrigger()'s folder-selection logic (luautils.cpp:1603) and the packet_system.cpp
    -- TYPE_NPC|TYPE_MOB trigger-action filter first -- both are real, previously-hit failure points
    -- for a mob-registered entity. If it DOES print, the failure is further down this function.
    -- print(string.format("[Cursed_Chest DEBUG] onTrigger fired -- id=%d name=%s triggered=%s",
    --     npc:getID(), npc:getName(), tostring(npc:getLocalVar("triggered"))))

    npc:lookAt(player:getPos())

    if npc:getLocalVar("triggered") == 1 then
        return
    end

    player:messageSpecial(CHEST)

    local npcID = npc:getID()
    local instance = npc:getInstance()
    local figureheadChest = instance:getProgress()

    if npcID == figureheadChest then
        npc:setLocalVar("triggered", 1)
        -- 2026-09-01, user-reported: this branch never set "triggered", so the golden chest could
        -- be re-triggered endlessly (re-completing the mission each time). Every other branch
        -- (see below) already guards on this same localvar -- this one just never did.
        player:messageSpecial(GOLDEN)
        -- 2026-09-01: setAnimationSub(1) alone (a persisted pose flag, not a one-shot clip) didn't
        -- animate anything visible -- same root cause already found and fixed for this exact
        -- mission's Ancient Lockbox (assault_lockbox.lua's chestTrigger): the real "opens" visual
        -- (with baked-in VFX) is a CEntityAnimationPacket, FourCC "open", confirmed against a real
        -- capture there. Using the same real mechanism here instead.
        npc:entityAnimationPacket("open")
        instance:complete()
        -- Despawn every OTHER chest (revealed or not) -- all are the same real mob id now.
        -- 2026-09-01, user-reported (server crash on zoning out afterward): this used to also
        -- include npcID (this exact entity) -- DespawnMob() -> PAI->Despawn() ->
        -- ForceChangeState<CDespawnState> was forcibly changing THIS entity's own AI state while
        -- its own onTrigger (called from that same entity's PAI/CTriggerState) was still on the
        -- call stack -- a real self-despawn-during-own-event-handler hazard. The golden chest
        -- doesn't need to despawn itself anyway; it already served its purpose.
        for _, chestId in ipairs(GoldenSalvageData.CURSED_CHEST_SLOTS.chestIds) do
            if chestId ~= npcID then
                DespawnMob(chestId, instance)
            end
        end
    else
        npc:setLocalVar("triggered", 1)

        npc:setModelId(MIMIC_MODEL_ID)
        npc:AnimationSub(MIMIC_ANIM_SUB)
        -- Persistent rename (not setName()) -- see the Ranch Wamoura/Golden Salvage Mimic name-
        -- display investigation for why a plain setName() wouldn't stick past this first packet.
        npc:setName("Mimic", true)
        -- Re-enable native aggro now that it's actually revealed.
        npc:setAggressive(true)
        -- Flip status back from the disguise's forced NORMAL to the real MOB status now that the
        -- interaction has already happened -- matches every other real fighting monster from this
        -- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
        -- point on. tpz.status has no "MOB" entry, but the real C++ enum (baseentity.h:46) defines
        -- STATUS_TYPE::MOB = 1 as a literal alias for the same value as STATUS_UPDATE (also 1)
        -- -- using the numeric value directly since neither Lua-side name reflects what this is.
        npc:setStatus(1)

        npc:updateClaim(player)
        npc:engage(player:getShortID())
    end
end

function onMobFight(mob, target)
    -- Not yet revealed by onTrigger: must not be attackable. The melee guard in
    -- CCharEntity::CanAttack covers normal attacks; anything that still lands (ranged/spell/WS/AOE)
    -- is undone here: full heal, drop enmity, disengage. (Lua-side workaround, not a Topaz behavior.)
    if mob:getLocalVar("triggered") ~= 1 then
        mob:setHP(mob:getMaxHP())
        mob:resetEnmity(target)
        mob:disengage()
        return
    end
    -- After onTrigger's setName("Mimic") this entity's script file is mobs/Mimic.lua (DSP setName
    -- overwrites GetName()), so the draw-in for the revealed chest lives there.
end

function onMobDeath(mob, player, optParams)
end

function onMobDespawn(mob)
end

