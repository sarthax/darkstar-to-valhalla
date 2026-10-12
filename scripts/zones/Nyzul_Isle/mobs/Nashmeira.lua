-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Nashmeira (tier 3, with Ovjang + Mnejing)
-- Wiki: takes reduced damage until both automatons are defeated. Real reduction % is not
-- documented; the DMG mod cap (-50%) is used. Tier 3 is complete once all three are dead.
-- Wiki: Imperial Authority (real mob_skills id 3243, mob_skill_lists 1038 -- the only
-- "imperial_authority" row actually wired to a Nashmeira skill list, TRUST_Nashmeira/1038, shared
-- by all 3 Nashmeira pool variants) "causes damage to one target, knocks them back, stuns, and
-- resets hate. She runs around randomly for a while after using this move." 2026-09-28: the
-- knockback/stun/hate-reset are native engine behavior for this mob skill already (mob_skills.sql
-- flags), nothing to add there. The "runs around randomly" part had no implementation at all.
-- Real duration/radius are NOT capture-confirmed -- RUN_DURATION_MS/RUN_RADIUS below are estimates,
-- flagged rather than presented as verified. Precedent for pathTo-while-still-engaged (no
-- disengage()) is Sagelord_Molaal_Ja.lua's flee mechanic; each candidate point is validated live
-- against the real navmesh via zone:checkNavPath() before pathTo(), so a bad random offset can
-- never send her through a wall/off the arena regardless of the guessed radius.
-----------------------------------
require("scripts/globals/heroines_holdfast")
local IMPERIAL_AUTHORITY_ID = 3243
local RUN_DURATION_MS = 8000 -- not capture-confirmed -- estimate for "for a while"
local RUN_STEP_MS = 1500
local RUN_RADIUS = 12 -- not capture-confirmed -- estimate, navmesh-validated per step regardless

local function randomRunStep(mob, endTime)
    if not mob:isAlive() or os.time() * 1000 >= endTime then
        mob:setLocalVar("HH_Running", 0)
        return
    end
    local zone = mob:getZone()
    local x, y, z = mob:getXPos(), mob:getYPos(), mob:getZPos()
    local angle = math.random() * 2 * math.pi
    local dist = math.random(4, RUN_RADIUS)
    local tx, tz = x + math.cos(angle) * dist, z + math.sin(angle) * dist
    local valid = zone:checkNavPath(x, y, z, tx, y, tz)
    if valid then
        mob:pathTo(tx, y, tz, 9) -- RUN|SCRIPT
    end
    mob:timer(RUN_STEP_MS, function(mob) randomRunStep(mob, endTime) end)
end

function onMobSpawn(mob)
    mob:addMod(MOD_DMG, -5000)
    mob:setLocalVar("HH_DR", 1)
    tpz.heroines.armSixNoDespawn(mob)
end

-- 2026-09-29 (user): 7596 fires as part of the linked tier-3 engage set (see t3Engage); 7601
-- fires once per player Nashmeira kills (mob-side isDead() check, no engine hook exists for
-- "mob kills a player" -- see tpz.heroines.sayOnPlayerKill's header).
function onMobFight(mob, target)
    tpz.heroines.t3Engage(mob, target)
    tpz.heroines.sayOnPlayerKill(mob, target, 7601)
    local instance = mob:getInstance()
    if instance and mob:getLocalVar("HH_DR") == 1 and instance:getLocalVar(tpz.heroines.automatonVar(mob)) >= 2 then
        mob:delMod(MOD_DMG, -5000)
        mob:setLocalVar("HH_DR", 0)
    end
end

function onMobWeaponSkill(target, mob, skill, action)
    if skill:getID() ~= IMPERIAL_AUTHORITY_ID or not tpz.heroines.skillLatch(mob) then
        return
    end
    -- 2026-09-29 (user): "7604 - Luzaf callout before Nashmeira uses Imperial Authority." 7604 was
    -- already wired as a generic phase-independent Luzaf cheer (CHEERS[3], fires on the ~32s
    -- interval regardless of skill -- see heroines_holdfast.lua). That periodic wiring is left
    -- alone (it's the only line in tier 3's cheer pool, so it isn't wrong, just generic); this
    -- adds the specific pre-Imperial-Authority callout the user described, via the real Luzaf
    -- cheerleader NPC (17093469), independent of the interval timer.
    -- 2026-09-29 (user): "7599 is imperial authority dialog." -- Nashmeira's own line, distinct
    -- from the Luzaf 7604 callout below (different speaker).
    tpz.heroines.mobSay(mob, 7599)
    local instance = mob:getInstance()
    -- 2026-09-30 (user): no cheerleaders in the floor 6 battle
    if instance and not tpz.heroines.isSix(mob) then
        local luzaf
        for _, n in pairs(instance:getNpcs()) do
            if n:getID() == 17093469 then
                luzaf = n
                break
            end
        end
        if luzaf then
            -- 2026-09-29 (user report): showName hardcoded false suppressed Luzaf's name on this
            -- line, same bug as heroines_holdfast.lua's mobSay/cheer.
            for _, v in pairs(instance:getChars()) do
                v:messageText(luzaf, 7604, true)
            end
        end
    end
    if mob:getLocalVar("HH_Running") == 1 then
        return -- already running from a previous use, don't stack timers
    end
    mob:setLocalVar("HH_Running", 1)
    randomRunStep(mob, os.time() * 1000 + RUN_DURATION_MS)
end

-- 2026-09-29 (user): "7600 is Nashmeria death dialog"
function onMobDeath(mob, player, isKiller)
    tpz.heroines.mobSay(mob, 7600)
    -- 2026-10-01 (user): her puppets die with her (tier 3). Capture only shows the normal death
    -- animation for puppets, so they are killed (setHP(0)) rather than despawned; HH_Dismissed
    -- makes their onMobDeath skip the death line / automaton count / loot credit. Six-battle
    -- puppets die too (also six-battle, where their death still counts toward the 7 heroines).
    local instance = mob:getInstance()
    if instance then
        for _, m in pairs(instance:getMobs()) do
            local name = m:getName()
            if (name == "Ovjang" or name == "Mnejing") and m:isAlive() and tpz.heroines.isSix(m) == tpz.heroines.isSix(mob) then
                m:setLocalVar("HH_Dismissed", 1)
                m:setHP(0)
            end
        end
    end
    tpz.heroines.onHeroineDeath(mob)
end

