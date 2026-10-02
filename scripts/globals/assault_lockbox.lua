-----------------------------------
-- Shared Ancient Lockbox reward roller for Assault zones.
-----------------------------------
-- Several zones (Lebros Cavern, Mamool Ja Training Grounds, Periqia) share one
-- physical Ancient Lockbox NPC across multiple missions, so the reward tables
-- differ per mission but the open/roll/give logic is identical. Rather than
-- duplicate that logic in every zone's npcs/Ancient_Lockbox.lua, it lives here
-- once and each zone script just supplies its own weighted tables.
--
-- Table shape mirrors LandSandBoat's qItem/regItem pattern:
--   pool  = { { weight, itemId }, { weight, itemId }, ... }
--   qItemPools    = { pool, pool, ... }  -- "???" items, given directly to the opener
--   regItemPools  = { pool, pool, ... }  -- regular items, staggered into the party Treasure Pool
-- itemId 0 in a pool is a valid outcome meaning "nothing".
--
-- DSP-PORT: ported verbatim from Topaz's scripts/globals/assault_lockbox.lua. DSP has no
-- equivalent at all (confirmed via file search, not just a grep miss -- see
-- mission_toolkit/data/dsp_namespace_map.json's missing_lua_modules.assault_lockbox entry).
-- Only 2 real changes from the Topaz source, both confirmed against real DSP source before
-- applying (never guessed):
--   1. `tpz.assault = tpz.assault or {}` / `tpz.assault.chestTrigger` -> a bare global table
--      `AssaultLockbox.chestTrigger`, matching this DSP snapshot's own convention for bespoke
--      shared modules that have no Topaz-namespace equivalent to preserve (same pattern used for
--      Nyzul Isle's own `Nyzul` table -- see dsp_namespace_map.json reshaped_families.nyzul).
--   2. `tpz.status.DISAPPEAR` -> bare `STATUS_DISAPPEAR` (confirmed exact match,
--      scripts/globals/status.lua:47).
-- Every other call used here (addTreasure, addGil, addExp, entityAnimationPacket,
-- npcUtil.giveItem, instance:getChars) was confirmed to exist with an identical signature in
-- DSP's own src/map/lua/lua_baseentity.cpp, src/map/lua/lua_instance.cpp, and
-- scripts/globals/npc_util.lua -- no other behavioral change needed.
--
-- Target path in a DSP checkout: scripts/globals/assault_lockbox.lua
-----------------------------------
require("scripts/globals/npc_util")
-----------------------------------
AssaultLockbox = AssaultLockbox or {}

-- 2026-08-19, user-provided real mechanics writeup for the Ancient Lockbox system: a "???" item
-- is NOT guaranteed -- the box rolls against a fixed drop rate, "typically ranging from ~20% to
-- ~50% depending on the specific Assault". This shared function has always given its "???" item
-- at a guaranteed 100% (no drop-chance gate existed at all) -- real bug, not previously known,
-- affecting every mission that routes through here (Lebros Cavern/Mamool Ja Training Grounds/
-- Periqia/Ilrusi Atoll). Set to 100 (guaranteed) at the user's request for easier live testing
-- while other mechanics are still being verified. **The real value should be 50** -- change this
-- back to 50 once testing no longer needs guaranteed drops. Deliberately NOT gating this
-- differently per-mission -- several missions routing through here already have full
-- user-confirmed live playthroughs (Preemptive Strike, Requiem), so leaving this at 100 for now
-- avoids silently changing their already-signed-off loot behavior.
local QITEM_DROP_CHANCE_PCT = 100

-- Sum-then-roll weighted pick, same idiom as scripts/globals/helm.lua's pickItem.
local function pickWeighted(pool)
    local sum = 0
    for _, v in ipairs(pool) do
        sum = sum + v[1]
    end

    local roll = math.random(sum)
    local acc = 0
    for _, v in ipairs(pool) do
        acc = acc + v[1]
        if roll <= acc then
            return v[2]
        end
    end
end

-- qItemPools/regItemPools may be nil (e.g. a mission with no "???" reward tier).
AssaultLockbox.chestTrigger = function(player, npc, qItemPools, regItemPools, xpReward, gilReward)
    if npc:getLocalVar("opened") == 1 then
        return
    end
    npc:setLocalVar("opened", 1)

    -- TextIDs are plain globals shared by every zone: whichever zone's TextIDs.lua ran last owns
    -- ITEM_OBTAINED etc. (Silver_Knife's GIL_OBTAINED is 6379 = the 'token of thanks' line). Re-run this
    -- zone's own TextIDs so npcUtil.giveItem's messageSpecial(ITEM_OBTAINED) uses the right ids.
    local zoneName = npc:getZoneName()
    if zoneName then
        package.loaded["scripts/zones/" .. zoneName .. "/TextIDs"] = nil
        require("scripts/zones/" .. zoneName .. "/TextIDs")
    end
    -- DEBUG (disabled): print(string.format("[assault_lockbox] zone=%s ITEM_OBTAINED=%s GIL_OBTAINED=%s", tostring(zoneName), tostring(ITEM_OBTAINED), tostring(GIL_OBTAINED)))

    -- 2026-08-27, user-reported live: no light/sparkle effect plays when the lockbox opens.
    -- Checked the real Thris Nov2025 capture (Mamool Ja Training Grounds, Imperial Agent
    -- Rescue) directly: the box's real open event is a `CEntityAnimationPacket` with
    -- FourCCString "open" (same mechanism as Brujeel's "deru" reveal), NOT `setAnimation(90)`.
    -- setAnimation() just flips a persisted pose/state field (the same one used for door open/
    -- closed poses, 8/9) -- it's not a one-shot canned animation clip the way an
    -- entityAnimationPacket FourCC is, so it never plays whatever VFX (the sparkle/light) is
    -- baked into the real "open" clip on the client side. Switched to the real mechanism.
    -- The same capture also shows the box vanishing ~15s later via FourCCString "kesu" (the
    -- same disappear clip used elsewhere in this codebase, e.g. Brujeel's own Warp vanish) --
    -- added that too, since this is a shared lockbox reused across multiple missions in this
    -- zone and a looted box lingering indefinitely doesn't match the real capture.
    npc:entityAnimationPacket("open")
    npc:timer(15000, function(n)
        n:entityAnimationPacket("kesu")
        n:setStatus(STATUS_DISAPPEAR)
    end)

    if qItemPools and math.random(100) <= QITEM_DROP_CHANCE_PCT then
        local direct = {}
        for _, pool in ipairs(qItemPools) do
            local itemID = pickWeighted(pool)
            if itemID and itemID ~= 0 then
                table.insert(direct, itemID)
            end
        end
        if #direct > 0 then
            npcUtil.giveItem(player, direct)
        end
    end

    if regItemPools then
        local playerId = player:getID()
        for i, pool in ipairs(regItemPools) do
            local itemID = pickWeighted(pool)
            if itemID and itemID ~= 0 then
                -- Re-resolve the player by id: the captured `player` can be freed by the time the
                -- timer fires (same stale-capture crash fixed in Leujaoam's Ancient_Lockbox.lua).
                npc:timer(i * 250, function(n)
                    local livePlayer = GetPlayerByID(playerId)
                    if livePlayer and n then
                        livePlayer:addTreasure(itemID, n)
                    end
                end)
            end
        end
    end

    local instance = npc:getInstance()
    if instance then
        local chars = instance:getChars()
        for _, char in pairs(chars) do
            if xpReward and xpReward > 0 then
                char:addExp(xpReward)
            end
            if gilReward and gilReward > 0 then
                char:addGil(gilReward)
            end
        end
    end
end
