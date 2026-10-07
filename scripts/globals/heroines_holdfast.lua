-----------------------------------
-- Heroines' Holdfast (Nyzul Isle instance 80) shared helpers.
-- Text ids are the Nyzul dialog.yml ids (toolkit pull 2026-09-26); the capture's ids for the same lines are +15.
-----------------------------------
require("scripts/globals/debug_print")
require("scripts/globals/titles")
require("scripts/globals/monstertpmoves")
require("scripts/globals/nyzul/vending_box")
require("scripts/zones/Nyzul_Isle/IDs")
-----------------------------------
tpz = tpz or {}
tpz.heroines = tpz.heroines or {}

local TEXT_DEFEATED  = 7562 -- capture 7577 "You have defeated your opponent."
local TEXT_ACTIVATED = 7571 -- capture 7586 "The Rune of Transfer has been activated!"
tpz.heroines.TEXT_OBJ_ALDO = 7569 -- capture 7584 "Seek the aid of Aldo."
tpz.heroines.TEXT_OBJ_KILL = 7570 -- capture 7585 "Exterminate a certain fiend."

-- Flat damage for the heroine skills. Capture #237 shows heroine TP moves doing small, near-fixed damage
-- to players regardless of the usual fTP/stat formula, so skills roll inside the range observed in the
-- capture's "<heroine> uses <skill>. <player> takes N points" lines, then go through MobFinalAdjustments
-- (shadows, absorb, damage-taken mods) like any other skill.
tpz.heroines.flatDamage = function(mob, target, skill, lo, hi, attackType, damageType, shadowbehav)
    local dmg = math.random(lo, hi)
    dmg = MobFinalAdjustments(dmg, mob, skill, target, attackType, damageType, shadowbehav or MOBPARAM_1_SHADOW)
    target:delHP(dmg)
    return dmg
end

-- Hidden "???" rune npcids: 17093436-17093441, one per tier (1-5) plus the 6th-battle rune,
-- csid 306-311 (see Heroine_Rune_of_Transfer.lua's FIRST_RUNE/FIRST_CSID header). animationsub 12
-- is the dormant/unlit look these ship with in npc_list; 13 is the lit look the always-on #1-#5
-- runes (17093431-17093435) use. Confirmed by comparing the two npc_list rows directly -- #1-#5
-- (always usable) are all animationsub=13, the hidden ??? runes are animationsub=12 by default.
local HIDDEN_RUNE_BASE = 17093436
local RUNE_ANIM_UNLIT = 12
local RUNE_ANIM_LIT   = 13

-- Lobby "Warp to Floor N" runes, npcid 17093431-17093435 (tier = npcid - LOBBY_RUNE_BASE), same
-- animationsub convention as the hidden ??? runes above (12=unlit/inactive, 13=lit/active) --
-- confirmed via the same npc_list row comparison (#1-#5 ship animationsub=13 by default).
local LOBBY_RUNE_BASE = 17093430

-- Marks a tier's ??? rune usable and announces it.
tpz.heroines.activateRune = function(instance, tier)
    if instance:getLocalVar("HH_Rune" .. tier) == 1 then
        return
    end
    instance:setLocalVar("HH_Rune" .. tier, 1)
    -- 2026-09-29 (user): "the rune of transfer is not lit up either. It does work however." --
    -- this flipped the usability flag but never touched the rune NPC's own visual state, so it
    -- stayed on its default dormant (unlit) look even once triggerable. setAnimationSub (not
    -- setAnimation) is the persistent-across-renders form, per the same convention as the chest/
    -- door open-state fix (caskets.lua precedent).
    local runeNpc = instance:getEntity(bit.band(HIDDEN_RUNE_BASE + tier - 1, 0xFFF), TYPE_NPC)
    if runeNpc then
        runeNpc:AnimationSub(RUNE_ANIM_LIT)
    end
    for _, v in pairs(instance:getChars()) do
        v:messageSpecial(TEXT_ACTIVATED)
        -- 2026-09-29 (user): on the 6-warder floor the standard line was missed; add an explicit
        -- floor-numbered line so it's clear which rune unlocked.        v:PrintToPlayer(string.format("Rune of Transfer ??? (Floor %d) has been activated!", tier), tpz.msg.channel.SYSTEM_3)
    end
end

-- sendEntityEmote is a Topaz-only C++ binding; no-op on DSP until ported.
tpz.heroines.emote = function(npc, emote, mode)
    if npc and npc.sendEntityEmote then
        npc:sendEntityEmote(npc, emote, mode)
    end
end

local TEXT_TIME_EXTENDED = 7435 -- "Your time limit for this battle has been extended by <number> minutes"
local EXTEND_MINUTES = 15

-- Uses instance:setTimeLimit (new C++ binding, needs a rebuild). Without it, falls back to a bonus var
-- subtracted from `elapsed` in instances/heroines_holdfast.lua onInstanceTimeUpdate.
tpz.heroines.extendTime = function(instance)
    if instance.setTimeLimit then
        -- CInstance::SetTimeLimit binding (mirrors battlefield:setTimeLimit used by limbus/dynamis)
        instance:setTimeLimit(instance:getTimeLimit() + EXTEND_MINUTES)
    else
        instance:setLocalVar("HH_BonusMs", instance:getLocalVar("HH_BonusMs") + EXTEND_MINUTES * 60 * 1000)
    end
    for _, v in pairs(instance:getChars()) do
        v:messageSpecial(TEXT_TIME_EXTENDED, EXTEND_MINUTES)
    end
end

-- 2026-09-29 (user): "the timing is too fast, increase the delay until the corpse decays and
-- disappears" -- the fade-to-hub used to fire the instant the boss's onMobDeath/progress update
-- landed, well before the death animation/corpse had finished. Split into an immediate part
-- (message + time extension, called straight from onInstanceProgressUpdate) and a delayed part
-- (the actual fade/warp), driven off instance/heroines_holdfast.lua's onInstanceTimeUpdate per
-- the project's timed-instance-mechanic convention (getLocalVar countdown, not entity:timer()).
-- See tpz.heroines.RETURN_DELAY_MS / queueReturnToHub / tickReturnToHub below.
tpz.heroines.RETURN_DELAY_MS = 18000 -- ~18s for the death animation/corpse to play out; adjust if still too fast/slow

-- 2026-10-02: HH-local replacement for updateInstanceTime's wipe handling. CLuaInstance::getWipeTime
-- returns (serverStart - wipeTimer), i.e. NEGATED, so the shared helper's wipe branch misfires here
-- (duplicate / "0 minutes" PARTY_FALLEN). Wipe start is tracked in a localvar instead.
local WIPE_LIMIT_MS = 180000
tpz.heroines.updateTime = function(instance, elapsed, texttable)
    local players = instance:getChars()
    local remaining = instance:getTimeLimit() * 60 - (elapsed / 1000)
    if remaining < 0 then
        instance:fail()
        return
    end
    local anyAlive = false
    for _, v in pairs(players) do
        if v:getHP() ~= 0 then anyAlive = true break end
    end
    local wipeStart = instance:getLocalVar("HH_WipeStartMs")
    if not anyAlive and #players > 0 then
        if wipeStart == 0 then
            instance:setLocalVar("HH_WipeStartMs", math.max(1, elapsed))
            for _, v in pairs(players) do v:messageSpecial(texttable.PARTY_FALLEN, 3) end
        elseif elapsed - wipeStart > WIPE_LIMIT_MS then
            instance:fail()
            return
        end
    elseif anyAlive and wipeStart ~= 0 then
        instance:setLocalVar("HH_WipeStartMs", 0)
    end
    local last = instance:getLastTimeUpdate()
    local message = 0
    if last == 0 and remaining < 600 then message = 600
    elseif last == 600 and remaining < 300 then message = 300
    elseif last == 300 and remaining < 60 then message = 60
    elseif last == 60 and remaining < 30 then message = 30
    elseif last == 30 and remaining < 10 then message = 10 end
    if message ~= 0 then
        for _, v in pairs(players) do
            if remaining >= 60 then
                v:messageSpecial(texttable.TIME_REMAINING_MINUTES, math.floor(remaining / 60))
            else
                v:messageSpecial(texttable.TIME_REMAINING_SECONDS, math.floor(remaining))
            end
        end
        instance:setLastTimeUpdate(message)
    end
end

tpz.heroines.announceHeroineFallen = function(instance)
    tpz.heroines.extendTime(instance)
    for _, v in pairs(instance:getChars()) do
        v:messageSpecial(TEXT_DEFEATED)
    end
end

-- Called once, immediately, when a heroine tier falls: announces the kill and arms the delayed warp.
tpz.heroines.queueReturnToHub = function(instance)
    tpz.heroines.announceHeroineFallen(instance)
    instance:setLocalVar("HH_ReturnPendingMs", tpz.heroines.RETURN_DELAY_MS)
end

-- The actual fade/warp, split out so it can fire either immediately (6th-battle completion, which
-- already has its own longer cutscene beat) or after the delay countdown below reaches zero.
tpz.heroines.returnToHub = function(instance)
    -- 2026-09-29 (user): six-battle corpse cleanup deferred here so it fires at the same moment as
    -- the warp instead of instantly on the kill (see the dead==SIX_HEROINES_NEEDED branch of
    -- onHeroineDeath above) -- guarded by isSpawned() per Fafnir.lua's documented crash (a
    -- DespawnMob() call on a mob not actually spawned/dead can stick a Despawn/Respawn pair on the
    -- AI state stack).
    if instance:getLocalVar("HH_SixCleanupPending") == 1 then
        instance:setLocalVar("HH_SixCleanupPending", 0)
        for _, m in pairs(instance:getMobs()) do
            if tpz.heroines.isSix(m) and m:isSpawned() then
                m:setBehaviour(bit.band(m:getBehaviour(), bit.bnot(BEHAVIOUR_NO_DESPAWN)))
                DespawnMob(m:getID(), instance)
            end
        end
    end
    for _, v in pairs(instance:getChars()) do
        v:setLocalVar("HHWarpDest", 0)
        tpz.heroines.queueWarp(v)
        -- 2026-09-27: dropped to the confirmed 8-value csid 300 shape (destId, x*1000, z*1000,
        -- y*1000, rot*16, 0, tier, 4095) -- this call's own 10-value form was the unverified one;
        -- see Heroine_Rune_of_Transfer.lua's warpTo() for the capture evidence (file header,
        -- capture #237, all 15 uses) and the live-log regression it caused when the two were
        -- made to agree at 10 instead of 8.
        v:startEvent(300, 0, 460000, -610000, 0, 1024, 0, 3, 4095)
        -- 2026-10-04: queue the win-eject HERE, not in Heroine_Rune_of_Transfer's csid 300
        -- onEventFinish -- a timed (non-click) csid 300 finishes against whichever NPC the player
        -- last clicked (sticky m_event.Script), so on the floor-6 win that handler never ran and
        -- the player was left in the lobby. Delay covers the ~6 s csid 300 fade (a startEvent(1)
        -- sent while it is still playing is dropped).
        if instance:getLocalVar("HH_FullClear") == 1 and v:getLocalVar("HH_FullClearDone") == 0 then
            v:setLocalVar("HH_FullClearDone", 1)
            v:setLocalVar("HH_PendingMsg", 1)
            v:setLocalVar("HH_PendingEjectMs", tpz.heroines.WIN_EJECT_DELAY_MS)
        end
    end
end

-- 2026-10-04 (user): "bounce" after a Rune of Transfer warp. Repositioning in the csid 300
-- onEventFinish happens AFTER the fade has completed, so the client visibly snaps the player. Same
-- cure as Nyzul Investigation's RUNE_REPOSITION_DELAY (Rune_of_Transfer.lua): reposition mid-fade.
-- DSP never fires onEventUpdate for this, so a per-player countdown runs from onInstanceTimeUpdate.
-- Tune WARP_REPOSITION_MS live against the fade (Investigation's value is 3300).
tpz.heroines.WARP_REPOSITION_MS = 3300

tpz.heroines.queueWarp = function(player)
    player:setLocalVar("HHWarpPending", 1)
    player:setLocalVar("HHWarpPosMs", tpz.heroines.WARP_REPOSITION_MS)
end

tpz.heroines.tickPendingWarp = function(instance, deltaMs)
    for _, v in pairs(instance:getChars()) do
        if v:getLocalVar("HHWarpPending") == 1 then
            local left = v:getLocalVar("HHWarpPosMs") - deltaMs
            if left <= 0 then
                v:setLocalVar("HHWarpPending", 0)
                v:setLocalVar("HHWarpPosMs", 0)
                local d = tpz.heroines.WARP_DEST and tpz.heroines.WARP_DEST[v:getLocalVar("HHWarpDest")]
                if d then
                    v:setLocalVar("HHWarpDest", 0)
                    v:setPos(d[1], d[2], d[3], d[4])
                end
            else
                v:setLocalVar("HHWarpPosMs", left)
            end
        end
    end
end

-- 2026-09-29 (user): fixes "warped to lobby but exit to zone 72 doesn't fire until you use another
-- rune of transfer" -- Heroine_Rune_of_Transfer.lua's csid==300 finish handler used to call
-- player:startEvent(1) synchronously from inside that same finish callback; the client silently
-- drops a second CEventPacket sent in the same tick as the first event's teardown. Deferring by a
-- short per-player tick (same onInstanceTimeUpdate idiom as tickReturnToHub/tickMumorRevive, never
-- entity:timer()) gives the client a moment to fully close csid 300 before csid 1 opens.
tpz.heroines.PENDING_EJECT_DELAY_MS = 1500
tpz.heroines.WIN_EJECT_DELAY_MS = 8000

tpz.heroines.tickPendingEject = function(instance, deltaMs)
    for _, v in pairs(instance:getChars()) do
        local pending = v:getLocalVar("HH_PendingEjectMs")
        if pending > 0 then
            pending = pending - deltaMs
            if v:getLocalVar("HH_PendingMsg") == 1 and pending <= tpz.heroines.PENDING_EJECT_DELAY_MS then
                v:setLocalVar("HH_PendingMsg", 0)
                v:messageSpecial(7561)
            end
            if pending <= 0 then
                v:setLocalVar("HH_PendingEjectMs", 0)
                v:startEvent(1)
            else
                v:setLocalVar("HH_PendingEjectMs", pending)
            end
        end
    end
end

-- Called every onInstanceTimeUpdate tick with the delta since the previous tick (see
-- instances/heroines_holdfast.lua). Counts HH_ReturnPendingMs down and fires the warp at zero.
tpz.heroines.tickReturnToHub = function(instance, deltaMs)
    local pending = instance:getLocalVar("HH_ReturnPendingMs")
    if pending <= 0 then
        return
    end
    pending = pending - deltaMs
    if pending <= 0 then
        instance:setLocalVar("HH_ReturnPendingMs", 0)
        tpz.heroines.returnToHub(instance)
    else
        instance:setLocalVar("HH_ReturnPendingMs", pending)
    end
end

-- Random-key rune triggers (BG Wiki, confirmed by user 2026-09-28/2026-09-29). Confirmed floor
-- mapping: 1=Lion, 2=Prishe, 3=Nashmeira, 4=Lilisette, 5=Mumor.
-- "Kill Twinkling Treant or Gigantoad... it's random which one" (Prishe), "Kill either Miura or
-- Toro... it's random which one" (Nashmeira, NOT Lilisette -- an earlier version of this comment
-- had that backwards). The candidate pool is picked once per instance (first candidate to spawn
-- rolls it), and only that specific mob's death fires the rune -- killing the other candidates in
-- the pool does nothing except clear trash. groupKey lets multiple rooms/pools share one instance
-- var namespace: all 6 Warder variants use "Warders" (Lilisette, floor 4); Miura/Toro use
-- "Nashmeira_Key" (floor 3); Treant/Gigantoad use "Prishe_Key" (floor 2).
--
-- Floor 5 (Mumor) is NOT a random-key pool: "Kill Pyracmon and ALL Wraith Bats to activate the
-- Runic Lamp to Mumor" (user, 2026-09-29, explicitly rejecting an earlier random-key attempt --
-- "should be ALL bats AND Pyracmon to open the door. not separate random pools"). See
-- groupKillGate below: every one of the 11 mobs must die, and that single shared condition gates
-- BOTH the Gilded Doors animation AND the Runic Lamp rune activation together.
tpz.heroines.randomKeyRoll = function(instance, groupKey, candidateIds)
    local varname = "HH_RandomKey_" .. groupKey
    local key = instance:getLocalVar(varname)
    if key == 0 then
        key = candidateIds[math.random(#candidateIds)]
        instance:setLocalVar(varname, key)
    end
    return key
end

tpz.heroines.randomKeyDeath = function(mob, groupKey, candidateIds, tier)
    local instance = mob:getInstance()
    if not instance then
        return
    end
    local key = tpz.heroines.randomKeyRoll(instance, groupKey, candidateIds)
    if mob:getID() == key then
        tpz.heroines.activateRune(instance, tier)
    end
end

-- Trash-mob loot roll (user, 2026-09-29): "Trash mobs should drop items at random from the pool
-- of items that the vending chest would normally drop. Drop rate should be 20%." Reuses the
-- vending box's own real 25-item catalog (scripts/globals/nyzul/vending_box.lua's itemsTable,
-- exposed as Nyzul.itemsTable) rather than inventing a separate trash loot table -- these are
-- TEMPITEMS (addTempItem), same as a real vending purchase, not a ground-drop/lootid, since
-- nothing about these ids exists in a normal loot table. Called from each trash mob's onMobDeath.
tpz.heroines.trashDrop = function(mob, player)
    local roll = math.random(100)
    dbgPrint(string.format("[HH DEBUG] trashDrop mob=%s player=%s roll=%d (<=20 drops)",
        mob:getName(), tostring(player ~= nil), roll))
    if not player or roll > 20 then
        return
    end
    local pool = Nyzul.itemsTable
    local entry = pool[math.random(#pool)]
    if entry and not player:hasItem(entry.item, LOC_TEMPITEMS) then
        if player:addTempItem(entry.item) then
            player:messageSpecial(NyzulIsle.text.VENDING_ITEM_OBTAINED, entry.item)
        end
    end
end

-- All-must-die gate (see Aldo.lua's HH_BeaksDead for the established increment-a-counter
-- convention this follows). Every death in the group increments a shared instance counter;
-- returns true exactly once, on the death that brings the counter to totalCount, so callers can
-- fire their group-completion effects (door open, rune activation, etc.) without double-firing.
tpz.heroines.groupKillGate = function(mob, groupKey, totalCount)
    local instance = mob:getInstance()
    if not instance then
        return false
    end
    local varname = "HH_KillCount_" .. groupKey
    local count = instance:getLocalVar(varname) + 1
    instance:setLocalVar(varname, count)
    return count == totalCount
end

-----------------------------------
-- Cheerleader assistants (chat-only NPCs, BG Wiki: they cheer for the heroine and warn of TP moves).
-- npc_list id = capture id - 1. Lines are dialog.yml ids verified by text (capture ids are +15).
-- Capture shows a line roughly every 30-35 s while the heroine fights; which line goes with which
-- TP move was NOT decoded, so lines rotate by HP phase instead.
-----------------------------------
local CHEER_INTERVAL_MS = 32000
local CHEERS = {
    -- tier = { heroine mob id, assistant npc id, lines by phase (hpp > 50 / hpp <= 50 / hpp <= 25) }
    [1] = { mob = 17093178, npc = 17093467, lines = { {7579, 7581}, {7579, 7581}, {7582} } },              -- Gilgamesh
    [2] = { mob = 17093211, npc = 17093468, lines = { {7593, 7592}, {7593, 7592}, {7594, 7595} } },        -- Ulmia
    [3] = { mob = 17093247, npc = 17093469, lines = { {7604}, {7604}, {7604} } },                          -- Luzaf
    [4] = { mob = 17093286, npc = 17093470, lines = { {7635, 7636}, {7637, 7638, 7639, 7640}, {7639, 7640} } }, -- Cait Sith
    -- [5] Mumor/Uka Totlihn is driven by tpz.heroines.tickMumorCalls (call -> queued move), not this timer
}
local CHEER_SPLIT_LINE = 7641 -- Cait Sith, once, when Lilisette's clone appears
local CHEER_ONCE_25    = 7662 -- Uka Totlihn, once, at Mumor's 25% phase

-- Called from the instance's onInstanceTimeUpdate. Speaks for any tier whose heroine is fighting.
tpz.heroines.cheer = function(instance, elapsed)
    if elapsed < instance:getLocalVar("HH_CheerNext") then
        return
    end
    instance:setLocalVar("HH_CheerNext", elapsed + CHEER_INTERVAL_MS)

    local mobs, npcs = {}, {}
    for _, m in pairs(instance:getMobs()) do
        mobs[m:getID()] = m
    end
    for _, n in pairs(instance:getNpcs()) do
        npcs[n:getID()] = n
    end

    for tier, c in pairs(CHEERS) do
        local heroine, npc = mobs[c.mob], npcs[c.npc]
        if heroine and npc and heroine:isAlive() and heroine:getTarget() then
            local hpp = heroine:getHPP()
            local phase = hpp > 50 and 1 or (hpp > 25 and 2 or 3)
            local line
            if tier == 4 and mobs[17093287] and instance:getLocalVar("HH_CheerSplit") == 0 then
                instance:setLocalVar("HH_CheerSplit", 1)
                line = CHEER_SPLIT_LINE
            elseif tier == 5 and phase == 3 and instance:getLocalVar("HH_Cheer25") == 0 then
                instance:setLocalVar("HH_Cheer25", 1)
                line = CHEER_ONCE_25
            end
            -- 2026-10-01: periodic call lines for tiers 1-4 moved to tpz.heroines.tickTierCalls
            -- (call -> skill, capture-decoded); only the one-shot lines above remain here.
            if line then
                -- 2026-09-29 (user report): cheerleader lines were missing name attribution for the
                -- same reason as mobSay above -- showName hardcoded false.
                for _, v in pairs(instance:getChars()) do
                    v:messageText(npc, line, true)
                end
                npc:entityAnimationPacket("sp00")
            end
        end
    end
end

-- Broadcasts a mob's own battle-skill "voice line" to every player in its instance.
tpz.heroines.mobSay = function(mob, textid)
    local instance = mob:getInstance()
    if not instance then
        return
    end
    -- 2026-09-29 (user report): "her name is not appended to dialog. Same with most other bosses
    -- and cheerleaders." messageText's 3rd arg is showName (lua_baseentity.cpp:215-247) -- this was
    -- hardcoded false, suppressing the speaker name on every line sent through mobSay. showText
    -- (used for a handful of Mumor's own lines, e.g. Final Eternal Heart) uses CMessageSpecialPacket
    -- instead, which has no such toggle, which is why only SOME lines were missing names.
    for _, v in pairs(instance:getChars()) do
        v:messageText(mob, textid, true)
    end
end

-- 2026-10-02 (user report: heroine skill/spell lines spam chat, sometimes with different lines):
-- the engine calls a mob's onMobWeaponSkill (mob-local and shared mobskill script) once PER TARGET
-- the skill hits (mobentity.cpp OnMobWeaponSkill loop), so an AoE on a full party said the line N
-- times, and the random-pool callers rolled a different line each time. Latch so only the first
-- target of a use speaks. 2s window: a heroine can't start two skills that close together.
local SKILL_SAY_WINDOW_S = 2
tpz.heroines.skillLatch = function(mob)
    local now = os.time()
    if now - mob:getLocalVar("HH_SkillSayT") < SKILL_SAY_WINDOW_S then
        return false
    end
    mob:setLocalVar("HH_SkillSayT", now)
    return true
end

-- Skill-use line: mobSay, once per skill use regardless of how many targets it hits.
tpz.heroines.skillSay = function(mob, textid)
    if tpz.heroines.skillLatch(mob) then
        tpz.heroines.mobSay(mob, textid)
    end
end

-- 2026-09-29 (user, corrected): "7607-7614 are Mnejing's dialog when it casts a spell. It's
-- associated with each elemental weapon/mob skill etc." Ordered Fire/Ice/Wind/Earth/Thunder/Water/
-- Light/Dark per the doc's own dialog.yml text quotes and the "Sequence F/I/W-1/E/T/W-2/L/D"
-- callout pattern (see docs/project-memory/19-heroines-holdfast-dialog-map.md). Indexed here for
-- per-skill lookup (index [1]=Fire ... [8]=Dark) -- NOT a random pool anymore. 2026-09-29 (user,
-- 2nd correction): Mnejing's real 4 skills are Flashbulb(Light)/Provoke(Fire)/Shield Bash(Earth)/
-- Disruptor(Dark), NOT shield_bash/string_clipper/string_shredder/chimera_ripper (that was TRUST_
-- Mnejing/1041's generic overworld skill_list, wrongly assumed to be her real HH moveset). New SQL
-- skill_list 1151 ('Mnejing_HH') carries the real 4; mob_pools.sql poolid 7034 repointed to it.
tpz.heroines.MNEJING_SKILL_LINES = { 7616, 7617, 7618, 7619, 7620, 7621, 7622, 7623 }
-- Fire=7616 ... Dark=7623. 2026-10-02: capture message-id mapping shows Mnejing's skill callouts are
-- 7616-7623 and Ovjang's spell callouts 7607-7614 (swapped vs the 2026-09-29 note; capture wins).

-- Mnejing's real 4 skill scripts (flashbulb/provoke/shield_bash/disruptor.lua) are generic shared
-- mobskill scripts, NOT HH-exclusive -- gate on zone id so this HH-flavored line never fires for
-- any other encounter that might reuse these skill ids. 77 = Nyzul_Isle (sql/zone_settings.sql).
local NYZUL_ISLE_ZONE_ID = 77
tpz.heroines.mnejingSay = function(mob, textid)
    if mob:getZoneID() ~= NYZUL_ISLE_ZONE_ID then
        return
    end
    tpz.heroines.skillSay(mob, textid)
end

-- 2026-09-29 (user): "7616-7623 are Ovjang's dialog when it casts a spell. It's associated with
-- each element of the spell cast." Ordered Fire/Ice/Wind/Earth/Thunder/Water/Light/Dark, same basis
-- as MNEJING_SKILL_LINES above. Indexed for per-skill/per-spell lookup, NOT a random pool.
tpz.heroines.OVJANG_SPELL_LINES = { 7607, 7608, 7609, 7610, 7611, 7612, 7613, 7614 }
-- Fire=7607 ... Dark=7614 (see swap note above)

-- Ovjang's Tier V elemental spells (mob_spell_lists.sql 'Ovjang_HH'/437) share their scripts with
-- every other real caster of the same spell (players included) -- gate on zone + exact mob name so
-- this HH-flavored line only ever fires for the HH Ovjang instance.
tpz.heroines.ovjangSpellSay = function(caster, textid)
    if not textid then
        return
    end
    if caster:getZoneID() ~= NYZUL_ISLE_ZONE_ID then
        return
    end
    if caster:getName() ~= "Ovjang" then
        return
    end
    tpz.heroines.skillSay(caster, textid)
end

-- 2026-09-29 (user): "Go ahead and wire the random-line-per-skill-use pattern for both" -- Lion and
-- Lilisette's mobskill scripts had no mobSay call at all (same gap Prishe's had), but unlike Prishe's
-- 3 lines, neither boss's dialog.yml pool names a specific skill (Lilisette's 7627 mentions "Moonshade
-- Butterfly," which matches none of her 6 real skill_list-484 script names) -- so there's no 1:1
-- mapping to wire. Same random-per-use approach as SIXTH_ELEMENT_LINES above: flavor-accurate (every
-- line is real, in-range, HH-specific text), not move-accurate.
-- 2026-09-29 (user): "7572 is the dialog when players first engage Lion, not a call and response."
-- Pulled out of the random skill-use pool above (was previously one of 7 random battle taunts) --
-- now fires once via tpz.heroines.engageOnce (see below), leaving 7573-7578 as the skill-use pool.
tpz.heroines.LION_LINES = { 7573, 7574, 7575, 7576, 7578 } -- 7577 = death line (Lion.lua onMobDeath)
tpz.heroines.LILISETTE_LINES = { 7625, 7626, 7627, 7628, 7629, 7630, 7631, 7632, 7633 }

-- 2026-09-29 (user): single-heroine "first engage" line, same idempotency pattern as t3Engage but
-- scoped to one mob instead of linking three. Used for Lion (7572) and Prishe (7583).
tpz.heroines.engageOnce = function(mob, textid)
    local key = "HH_Engaged"
    if mob:getLocalVar(key) == 1 then
        return
    end
    mob:setLocalVar(key, 1)
    tpz.heroines.mobSay(mob, textid)
end

-- Mumor's named dance skills (mob_skill_lists 'Mumor_HH', see sql/mob_skill_lists.sql) each have a
-- real short "chant" line, and 4 of the 5 reusable moves also have a longer "full" line that
-- appears grouped with her HP-25%-or-below berserk monologue (dialog ids 7653-7660, opening "It
-- cannot end like this..."). No explicit berserk-phase flag exists for Mumor yet, so HP% <= 25
-- (matching CHEERS[5]'s own existing phase-3 threshold) is used as the switch here -- inferred from
-- the dialog block's placement/tone, not a decoded phase variable.
tpz.heroines.MUMOR_LINES = {
    shining_summer_samba  = { short = 7643 },                 -- no full/berserk variant in this range
    lovely_miracle_waltz  = { short = 7644, full = 7657 },
    neo_crystal_jig       = { short = 7645, full = 7656 },
    super_crusher_jig     = { short = 7645, full = 7658 },    -- shares the short "...Jig!" line with Neo Crystal Jig
    eternal_vana_illusion = { short = 7646, full = 7659 },
    final_eternal_heart   = { full = 7660 },                  -- ultimate move, always the full line
}

tpz.heroines.mumorSay = function(mob, skillname)
    local lines = tpz.heroines.MUMOR_LINES[skillname]
    if not lines or not tpz.heroines.skillLatch(mob) then
        return
    end
    -- a cheerleader-called move already sent its chant when it started (tickMumorCalls)
    if mob:getLocalVar("HH_ChantDone") == 1 then
        mob:setLocalVar("HH_ChantDone", 0)
        return
    end
    -- berserk = HH_Phase>=1 (her HP is restored to 50% at the 25% transition, so HPP alone misses it)
    -- 2026-09-30 (user): the full lines belong to phase 2 only, so key strictly off HH_Phase
    -- floor 6 has no cheerleader call/response splitting her dialog, so she always uses the full lines
    local berserk = tpz.heroines.isSix(mob) or mob:getLocalVar("HH_Phase") >= 1
    tpz.heroines.mobSay(mob, (berserk and lines.full) or lines.short or lines.full)
end

-- 2026-09-30 (user): cheerleader-as-override scheduler, Mumor/Uka Totlihn first. Every
-- MUMOR_CALL_INTERVAL_MS of fight time Uka calls a move (call line -> skill id). The call is QUEUED
-- (HH_MumorPending) and only executes once Mumor is free (not mid-cast/skill), so a 10s+ cast can
-- never swallow it; a call that can't run within MUMOR_CALL_TTL_MS is dropped. The move's chant is
-- sent when it STARTS. Mumor's own AI keeps using skills/spells independently in between; this
-- never clears her TP or AI state except by issuing the called skill itself.
tpz.heroines.MUMOR_CALL_INTERVAL_MS = 32000
tpz.heroines.MUMOR_CALL_TTL_MS = 25000
tpz.heroines.MUMOR_CALL_DELAY_MS = 5000 -- call -> response skill
local MUMOR_ID, UKA_ID = 17093309, 17093471
local MUMOR_CALLS_NORMAL = { -- HP > 25: call line, skill id, chant skillname
    { call = 7647, skill = 2899, emote = 65, name = "shining_summer_samba" },
    { call = 7648, skill = 2900, emote = 66, name = "lovely_miracle_waltz" },
    { call = 7649, skill = 2902, emote = 68, name = "super_crusher_jig" },
    { call = 7650, skill = 2903, emote = 67, name = "eternal_vana_illusion" },
}
local MUMOR_CALLS_BERSERK = { -- HP <= 25: single generic call, moves use the full berserk chants
    { call = 7661, skill = 2901, emote = 67, name = "neo_crystal_jig" },
    { call = 7661, skill = 2900, emote = 66, name = "lovely_miracle_waltz" },
    { call = 7661, skill = 2902, emote = 68, name = "super_crusher_jig" },
    { call = 7661, skill = 2903, emote = 67, name = "eternal_vana_illusion" },
}

-- Finds an instance NPC by its full npc_list id. instance:getEntity(id & 0xFFF, TYPE_NPC) is not
-- reliable on DSP (instanced npc targids are assigned at load, not derived from the id), so scan
-- getNpcs() like cheer() does.
tpz.heroines.findInstanceNpc = function(instance, npcId)
    for _, n in pairs(instance:getNpcs()) do
        if n:getID() == npcId then
            return n
        end
    end
    return nil
end

tpz.heroines.tickMumorCalls = function(instance, deltaMs)
    local mumor = GetMobByID(MUMOR_ID, instance)
    local uka = tpz.heroines.findInstanceNpc(instance, UKA_ID)
    if mumor and mumor:isAlive() and mumor:getTarget() and not uka and instance:getLocalVar("HH_UkaWarned") == 0 then
        instance:setLocalVar("HH_UkaWarned", 1)
        printf("[HH] Uka Totlihn (%u) not found among instance NPCs - cheers disabled", UKA_ID)
    end
    if not mumor or not uka or not mumor:isAlive() or not mumor:getTarget() then
        return
    end
    -- 2026-10-01: Uka turns to face Mumor and performs the called move's dance as a real 0x05A
    -- emote with herself as actor (capture-confirmed ids: 65 samba, 66 waltz, 68 super crusher jig,
    -- 67 neo crystal jig / eternal vana illusion; user-tested in-game). Emote fires with the call.
    local function say(textid, emote)
        for _, v in pairs(instance:getChars()) do
            v:messageText(uka, textid, true)
        end
        uka:lookAt(mumor:getPos())
        if emote then
            tpz.heroines.emote(uka, emote, 2)
        end
    end

    -- 1) queued call: run it as soon as Mumor is free
    local phase = mumor:getLocalVar("HH_Phase")
    if phase == 2 or phase == 3 then
        -- Final Eternal Heart sequence (Mumor.lua) owns her; drop any queued call, pause scheduler
        instance:setLocalVar("HH_MumorPending", 0)
        return
    end
    local berserk = phase >= 1
    local pending = instance:getLocalVar("HH_MumorPending")
    if pending > 0 then
        local delay = instance:getLocalVar("HH_MumorPendingDelay") - deltaMs
        instance:setLocalVar("HH_MumorPendingDelay", delay)
        local ttl = instance:getLocalVar("HH_MumorPendingTtl") - deltaMs
        instance:setLocalVar("HH_MumorPendingTtl", ttl)
        if ttl <= 0 then
            instance:setLocalVar("HH_MumorPending", 0)
        elseif delay <= 0 and mumor:getCurrentAction() == ACTION_ATTACK and instance:getLocalVar("HH_MumorReviving") == 0 then
            instance:setLocalVar("HH_MumorPending", 0)
            local entry
            for _, e in ipairs(berserk and MUMOR_CALLS_BERSERK or MUMOR_CALLS_NORMAL) do
                if e.skill == pending then
                    entry = e
                    break
                end
            end
            if entry then
                mumor:setLocalVar("HH_ChantDone", 1)
                tpz.heroines.mobSay(mumor, (berserk and tpz.heroines.MUMOR_LINES[entry.name].full)
                    or tpz.heroines.MUMOR_LINES[entry.name].short)
                mumor:useMobAbility(entry.skill)
            end
        end
        return
    end

    -- 2) interval countdown -> place a new call
    local wait = instance:getLocalVar("HH_MumorCallWait") - deltaMs
    if wait > 0 then
        instance:setLocalVar("HH_MumorCallWait", wait)
        return
    end
    instance:setLocalVar("HH_MumorCallWait", tpz.heroines.MUMOR_CALL_INTERVAL_MS)
    local list = berserk and MUMOR_CALLS_BERSERK or MUMOR_CALLS_NORMAL
    local entry = list[math.random(#list)]
    say(entry.call, entry.emote)
    instance:setLocalVar("HH_MumorPending", entry.skill)
    instance:setLocalVar("HH_MumorPendingTtl", tpz.heroines.MUMOR_CALL_TTL_MS)
    instance:setLocalVar("HH_MumorPendingDelay", tpz.heroines.MUMOR_CALL_DELAY_MS)
end

-- 2026-10-01: cheerleader call -> heroine skill scheduler for tiers 1-4, same design as
-- tickMumorCalls. Mapping decoded from the Siknawz Heroines' Holdfast capture (CapLog: each call
-- line is followed ~2s later by the heroine's chant and ~4s later by the skill; every call line maps
-- to exactly ONE skill). Call line ids verified by text against a fresh same-session dialog.yml
-- pull (mission_toolkit Nyzul_Isle). The heroine's own chant is sent by her mobskill script
-- (onMobSkillCheck), so this only issues the call, the cheerleader's sp00 animation (0x038 "sp00",
-- capture-confirmed on every call, user-confirmed visually on Gilgamesh) and the queued skill.
-- Luzaf: the one Slapstick (1943) in the capture window is the Mnejing puppet's skill (user-confirmed),
-- not Nashmeira's -- an overlap, correctly NOT mapped.
tpz.heroines.TIER_CALL_INTERVAL_MS = 32000
tpz.heroines.TIER_CALL_TTL_MS = 25000
tpz.heroines.TIER_CALL_DELAY_MS = 2000 -- call -> skill start (chant lands at skill start)
-- DSP skill ids (2026-10-04): the Topaz ids (2891-2896/1982/1983) do not exist in DSP mob_skills, so
-- useMobAbility silently did nothing. Real DSP ids by name: lists 1022/1028/1038.
local TIER_CALLS = {
    [1] = { mob = 17093178, npc = 17093467, calls = { -- Gilgamesh -> Lion
        { call = 7581, skill = 3200 }, -- Powder Keg
        { call = 7579, skill = 3198 }, -- Grapeshot
        { call = 7582, skill = 3201 }, -- Walk the Plank
    } },
    [2] = { mob = 17093211, npc = 17093468, calls = { -- Ulmia -> Prishe
        { call = 7593, skill = 3235 }, -- Auroral Uppercut
        { call = 7592, skill = 3234 }, -- Nullifying Dropkick
        { call = 7594, skill = 3236 }, -- Knuckle Sandwich
    } },
    [3] = { mob = 17093247, npc = 17093469, calls = { -- Luzaf -> Nashmeira
        { call = 7604, skill = 3243 }, -- Imperial Authority
    } },
    [4] = { mob = 17093286, npc = 17093470, calls = { -- Cait Sith -> Lilisette
        { call = 7635, skill = 2442 }, -- Thorned Stance
        { call = 7636, skill = 2443 }, -- Sensual Dance
        { call = 7637, skill = 2445 }, -- Whirling Edge
        { call = 7638, skill = 2446 }, -- Rousing Samba
        { call = 7639, skill = 2447 }, -- Vivifying Waltz
        { call = 7640, skill = 2444 }, -- Dancer's Fury
    } },
}

tpz.heroines.tickTierCalls = function(instance, deltaMs)
    for tier, c in pairs(TIER_CALLS) do
        local heroine = GetMobByID(c.mob, instance)
        local npc = tpz.heroines.findInstanceNpc(instance, c.npc)
        if heroine and npc and heroine:isAlive() and heroine:getTarget() then
            local wk, pk, tk, dk = "HH_TCallWait" .. tier, "HH_TPending" .. tier, "HH_TTtl" .. tier, "HH_TDelay" .. tier
            local pending = instance:getLocalVar(pk)
            if pending > 0 then
                local delay = instance:getLocalVar(dk) - deltaMs
                local ttl = instance:getLocalVar(tk) - deltaMs
                instance:setLocalVar(dk, delay)
                instance:setLocalVar(tk, ttl)
                if ttl <= 0 then
                    instance:setLocalVar(pk, 0)
                elseif delay <= 0 and heroine:getCurrentAction() == ACTION_ATTACK then
                    instance:setLocalVar(pk, 0)
                    heroine:useMobAbility(pending)
                end
            else
                local wait = instance:getLocalVar(wk) - deltaMs
                if wait > 0 then
                    instance:setLocalVar(wk, wait)
                else
                    instance:setLocalVar(wk, tpz.heroines.TIER_CALL_INTERVAL_MS)
                    local entry = c.calls[math.random(#c.calls)]
                    for _, v in pairs(instance:getChars()) do
                        v:messageText(npc, entry.call, true)
                    end
                    npc:lookAt(heroine:getPos())
                    npc:entityAnimationPacket("sp00")
                    instance:setLocalVar(pk, entry.skill)
                    instance:setLocalVar(tk, tpz.heroines.TIER_CALL_TTL_MS)
                    instance:setLocalVar(dk, tpz.heroines.TIER_CALL_DELAY_MS)
                end
            end
        end
    end
end

-- 6th battle ("all heroines", rune csid 311 -> dest 11): capture ids 17093310-17093317
-- (Lion, Prishe, Nashmeira, Ovjang, Mnejing, Lilisette, Lilisette clone, Mumor).
tpz.heroines.SIX_FIRST = 17093310
tpz.heroines.SIX_LAST  = 17093317
tpz.heroines.SIX_LILISETTE = 17093315
tpz.heroines.SIX_LILISETTE_SPLIT = 17093316
-- 2026-09-29: was 5 -- undercounted. The 7 onHeroineDeath-firing events in the 6th battle are
-- Lion, Prishe, Nashmeira, Ovjang, Mnejing, Lilisette (both halves count as ONE death, see
-- Lilisette.lua's ids()/prefix.."Dead">=2 gate), Mumor -- matches the user's pasted wiki text
-- naming exactly these 7 heroines as required. At 5, the fight was completing 2 events early
-- (silently skipping whichever of Ovjang/Mnejing died last).
local SIX_HEROINES_NEEDED = 7

tpz.heroines.isSix = function(mob)
    local id = mob:getID()
    return id >= tpz.heroines.SIX_FIRST and id <= tpz.heroines.SIX_LAST
end

-- 2026-09-29 (user): "For the 6th battle... None of the mobs should despawn. Corpses should
-- remain until last boss is killed, then they should decay and warp players out." Set on every
-- six-battle mob at spawn (see each mob file's onMobSpawn) so an individual death's default
-- 15s corpse-fade (CMobEntity::Die -> Internal_Die -> OnDeathTimer -> CDespawnState) never
-- completes -- despawn_state.cpp gates both its ctor and Update() on this flag. Cleared + force-
-- despawned explicitly in onHeroineDeath below once the whole group is dead, per Fafnir.lua's
-- documented precedent/warning: this flag MUST be cleared and despawn issued explicitly, or
-- corpses persist forever.
tpz.heroines.armSixNoDespawn = function(mob)
    -- 2026-10-01 (user): heroine bosses are static at their spawn point until engaged (roam
    -- distance 0, same precedent as Long-Bowed_Chariot.lua); chasing once engaged is unaffected.
    mob:setMobMod(MOBMOD_ROAM_DISTANCE, 0)
    if tpz.heroines.isSix(mob) then
        mob:setBehaviour(bit.bor(mob:getBehaviour(), BEHAVIOUR_NO_DESPAWN))
    end
end

-- Instance var used to count dead automatons (Nashmeira's damage reduction), separate per fight.
tpz.heroines.automatonVar = function(mob)
    return tpz.heroines.isSix(mob) and "HH_S_Automatons" or "HH_T3_Automatons"
end

-----------------------------------
-- 2026-09-29 (user): 6th battle only -- "If Mumor dies before all the other heroes do, she will
-- always be brought back to life... prevents players from trying to 'zerg' her". Mumor.lua sets
-- mob:setUnkillable(true) on spawn (isSix only), which clamps her HP to 1 instead of letting it
-- reach 0 (CBattleEntity::addHP, battleentity.cpp) -- she can never actually Die() this way. When
-- Mumor.lua's onMobFight detects that clamp firing while HH_SixDead < 6 (i.e. at least one other
-- six-battle heroine still alive), it calls tpz.heroines.mumorFakeDeath below to run the ~15s
-- "fake death" sequence the user specified (7663 at death, 7664/7666 from a random surviving
-- heroine, 7665 + full HP + phase reset at revival).
--
-- The 15s countdown is driven from THIS instance's own onInstanceTimeUpdate tick
-- (tpz.heroines.tickMumorRevive, called from instances/heroines_holdfast.lua), per the project's
-- "timed instance mechanics use onInstanceTimeUpdate, not entity:timer()" rule -- and because
-- mob:stun() forces Mumor into CInactiveState (ai_container.cpp Inactive() ->
-- ForceChangeState<CInactiveState>), which calls PAI->InterruptStates() and replaces her
-- CAttackState outright, so her own onMobFight stops firing entirely for the duration (confirmed
-- by reading ai_container.cpp/inactive_state.cpp) -- it cannot be used to drive this timer itself.
-----------------------------------
tpz.heroines.MUMOR_REVIVE_DELAY_MS = 15000
tpz.heroines.MUMOR_REVIVE_REACT2_DELAY_MS = 5000
local MUMOR_REVIVE_DEATH_LINE = 7663  -- "I deliver you to eternal rest..." (Mumor)
local MUMOR_REVIVE_REACT_LINE_1 = 7664 -- "M-Mumor... What's wrong with you!?" (random survivor)
local MUMOR_REVIVE_REACT_LINE_2 = 7666 -- "Mumor...! Come back to us! Mumor!!!" (random survivor)
local MUMOR_REVIVE_LINE = 7665 -- "I am eternal...immortal... I shall rise again..." (Mumor)
-- The other 6 six-battle heroines eligible to speak 7664/7666 -- excludes Mumor herself
-- (SIX_LAST) and the Lilisette split-clone (counted as part of one heroine, see the
-- SIX_HEROINES_NEEDED note above).
local MUMOR_REVIVE_SPEAKERS = { 17093310, 17093311, 17093312, 17093313, 17093314, 17093315 }

local function mumorReviveRandomSurvivor(instance)
    local alive = {}
    for _, id in ipairs(MUMOR_REVIVE_SPEAKERS) do
        local m = GetMobByID(id, instance)
        if m and m:isSpawned() and m:isAlive() then
            alive[#alive + 1] = m
        end
    end
    if #alive == 0 then
        return nil
    end
    return alive[math.random(#alive)]
end

-- Called from Mumor.lua the instant her HP would have hit 0 while HH_SixDead < 6.
MUMOR_DEATH_POSE_BYTE = true

tpz.heroines.mumorFakeDeath = function(mob)
    local instance = mob:getInstance()
    if not instance or instance:getLocalVar("HH_MumorReviving") == 1 then
        return
    end
    instance:setLocalVar("HH_MumorReviving", 1)
    -- 2026-09-29 (user): removed mob:untargetable(true) here -- real dead mobs/corpses in FFXI
    -- stay targetable (that's how Raise works on them), and this project's own FLAG_UNTARGETABLE
    -- is a confirmed split-bug (CMobEntity::Untargetable() writes m_flags/entityFlags, but
    -- CBaseEntity::IsTargetable() reads a completely different member, namevis -- baseentity.cpp:
    -- 134-137 vs mobentity.cpp:446-457) -- the raw entityFlags bit still reaches the client
    -- unchanged though, and is the confirmed cause of "she despawns/turns invisible like a dead
    -- trust" (user report). Dropping it entirely fixes the visibility without needing this flag at
    -- all -- she's already fully neutralized via stun()+setUnkillable, nothing else depends on her
    -- being unclickable for the ~15s window.
    mob:stun(tpz.heroines.MUMOR_REVIVE_DELAY_MS)
    -- 2026-09-30 (user): the revived Mumor was invisible ("despawns like a trust"). setAnimation(3)
    -- (ANIMATION_DEATH) makes the entity-update byte say "dead", which the client treats as a real
    -- death and fades/removes the model -- it never comes back on a plain update. The pose is
    -- played purely by the "ded" motion packet below, so the sync byte is left alone.
    -- 2026-09-29 (user, confirmed client motion tag): "ded" is the real death-pose motion (same one
    -- a GM-forced player death / /doom uses) -- setAnimation(3) alone only updates the raw sync
    -- byte the client uses for state tracking, it does not by itself replay the pose motion the way
    -- a real CBattleEntity::Die() packet sequence does.
    -- 2026-10-04 (user): the death pose no longer showed at all (she just went 1% -> 100%). The
    -- sync byte is what the client actually renders as "dead", so set it alongside the motion
    -- packet. If she comes back invisible after the revive, set MUMOR_DEATH_POSE_BYTE = false.
    if MUMOR_DEATH_POSE_BYTE then
        mob:setAnimation(ANIMATION_DEATH)
    end
    mob:entityAnimationPacket("ded")
    tpz.heroines.mobSay(mob, MUMOR_REVIVE_DEATH_LINE)
    local r1 = mumorReviveRandomSurvivor(instance)
    if r1 then
        tpz.heroines.mobSay(r1, MUMOR_REVIVE_REACT_LINE_1)
    end
    instance:setLocalVar("HH_MumorReviveReact2At", tpz.heroines.MUMOR_REVIVE_REACT2_DELAY_MS)
    instance:setLocalVar("HH_MumorReviveAt", tpz.heroines.MUMOR_REVIVE_DELAY_MS)
end

-- Called every tick from instances/heroines_holdfast.lua's onInstanceTimeUpdate with the elapsed
-- delta (ms) since the last tick, while a fake-death sequence is pending.
tpz.heroines.tickMumorRevive = function(instance, deltaMs)
    if instance:getLocalVar("HH_MumorReviving") ~= 1 then
        return
    end

    local react2At = instance:getLocalVar("HH_MumorReviveReact2At")
    if react2At > 0 then
        react2At = react2At - deltaMs
        if react2At <= 0 then
            local r2 = mumorReviveRandomSurvivor(instance)
            if r2 then
                tpz.heroines.mobSay(r2, MUMOR_REVIVE_REACT_LINE_2)
            end
        end
        instance:setLocalVar("HH_MumorReviveReact2At", math.max(react2At, 0))
    end

    local reviveAt = instance:getLocalVar("HH_MumorReviveAt") - deltaMs
    if reviveAt > 0 then
        instance:setLocalVar("HH_MumorReviveAt", reviveAt)
        return
    end

    instance:setLocalVar("HH_MumorReviveAt", 0)
    instance:setLocalVar("HH_MumorReviving", 0)
    local mumor = GetMobByID(tpz.heroines.SIX_LAST, instance)
    if mumor and mumor:isSpawned() then
        -- "sp00" is the real raise-glow animation tag -- the only existing non-PC precedent
        -- (scripts/globals/spells/raise.lua/raise_ii.lua/raise_iii.lua's hardcoded CoP 8-4 Prishe
        -- branch) uses this exact same tag for all three raise tiers, so it's what Raise III looks
        -- like on a non-PC target in this engine.
        if MUMOR_DEATH_POSE_BYTE then
            mumor:setAnimation(ANIMATION_NONE)
        end
        mumor:entityAnimationPacket("sp00")
        -- 2026-09-29 (user, confirmed client motion tag): "std" is the real universal raise/stand
        -- recovery motion (same for all models, per user) -- "sp00" alone is only the glow effect,
        -- it never moves her model out of the "ded" death pose set in mumorFakeDeath, which is why
        -- the revive previously showed no model. setAnimation back to ANIMATION_NONE clears the
        -- sync byte, entityAnimationPacket("std") replays the actual stand-up motion.
        mumor:entityAnimationPacket("std")
        mumor:setLocalVar("HH_TransStep", 0)
        mumor:setHP(mumor:getMaxHP())
        mumor:setMod(MOD_DMG, 0) -- clear phase-1's -5000 flat DMG cap
        mumor:setLocalVar("HH_Phase", 0)
        mumor:setLocalVar("HH_FEHCast", 0)
        mumor:setLocalVar("HH_FEHResolve", 0)
        tpz.heroines.mobSay(mumor, MUMOR_REVIVE_LINE)
    end
end

-- 2026-09-29 (user): tier-3 engage lines 7596/7597/7598 fire together off the FIRST hit landed on
-- ANY of Nashmeira/Ovjang/Mnejing ("should link with each other"). Gated on a shared instance
-- localvar. Called from each mob's entity.onMobFight.
tpz.heroines.T3_ENGAGE_LINES = { 7596, 7597, 7598 } -- Nashmeira, Mnejing, Ovjang (dialog.yml order)
tpz.heroines.T3_IDS = { 17093247, 17093248, 17093249 } -- Nashmeira, Ovjang, Mnejing
tpz.heroines.t3Engage = function(mob, target)
    local instance = mob:getInstance()
    -- 2026-09-29 (user): the three link ONCE, on the first engage -- whichever is pulled first
    -- drags the other two onto that target. After that enmity is independent (HH_T3Linked gate),
    -- so they can split across different targets.
    if instance and target and instance:getLocalVar("HH_T3Linked") == 0 then
        instance:setLocalVar("HH_T3Linked", 1)
        for _, id in ipairs(tpz.heroines.T3_IDS) do
            if id ~= mob:getID() then
                local sib = GetMobByID(id, instance)
                if sib and sib:isAlive() then
                    sib:updateEnmity(target)
                end
            end
        end
    end
    if not instance or instance:getLocalVar("HH_T3Engaged") == 1 then
        return
    end
    instance:setLocalVar("HH_T3Engaged", 1)
    -- each line is spoken by ITS OWN heroine (Nashmeira 7596, Mnejing 7597, Ovjang 7598), not by
    -- whichever one got engaged first
    local speakers = { 17093247, 17093249, 17093248 }
    for i, textid in ipairs(tpz.heroines.T3_ENGAGE_LINES) do
        local speaker = GetMobByID(speakers[i], instance) or mob
        tpz.heroines.mobSay(speaker, textid)
    end
end

-- 2026-09-29 (user): "7601/7605/7606 is when Nashmeira/Mnejing/Ovjang kills a player." No engine
-- hook exists for "mob kills a player" (luautils.cpp only exposes onMobDeath/onMobDeathEx, fired
-- on the MOB's own death -- confirmed by grep). CLuaBaseEntity DOES expose isDead() on any battle
-- entity, so this is detected from entity.onMobFight (fires every combat round with the current
-- target) by checking the target's HP after the round. Gated per-target-id on the mob so it fires
-- once per kill and re-arms once that target is no longer dead (raised/repopped).
tpz.heroines.sayOnPlayerKill = function(mob, target, textid)
    if not target or not target:isDead() then
        return
    end
    local key = "HH_KillSaid_" .. target:getID()
    if mob:getLocalVar(key) == 1 then
        return
    end
    mob:setLocalVar(key, 1)
    tpz.heroines.mobSay(mob, textid)
end

-- 2026-09-29 (user): "For Ovjang and Mnejing, a new ability needs to be set for when they reach
-- 25% Overdrive is an ability that increases their power. It's a normal Puppetmaster skill."
-- Real mechanic confirmed in-codebase: EFFECT_OVERDRIVE (166) / ability id 135
-- (scripts/globals/abilities/overdrive.lua, scripts/globals/effects/overdrive.lua) -- a PC ability
-- that empowers their PET. Ovjang/Mnejing narratively ARE automatons (pets), so the exact same
-- pet-side mod block from effects/overdrive.lua's onEffectGain is applied directly to the mob here
-- (magnitude taken verbatim from that file, not invented). OVERLOAD_THRESH is skipped -- that mod
-- only matters for the PC master, not the automaton itself. Fires once per fight at <=25% HP,
-- gated via localvar (mirrors mumorSay's existing HPP<=25 pattern, but one-shot since this also
-- grants a persistent stat buff).
tpz.heroines.activateOverdrive = function(mob, activateTextid)
    if mob:getLocalVar("HH_Overdrive") == 1 then
        return
    end
    if mob:getHPP() > 25 then
        return
    end
    mob:setLocalVar("HH_Overdrive", 1)
    mob:addMod(MOD_HASTE_MAGIC, 2500)
    mob:addMod(MOD_MAIN_DMG_RATING, 30)
    mob:addMod(MOD_RANGED_DMG_RATING, 30)
    mob:addMod(MOD_ATTP, 50)
    mob:addMod(MOD_RATTP, 50)
    mob:addMod(MOD_ACC, 100)
    mob:addMod(MOD_RACC, 100)
    mob:addMod(MOD_EVA, 50)
    mob:addMod(MOD_MEVA, 50)
    mob:addMod(MOD_REVA, 50)
    mob:addMod(MOD_DMG, -50)
    -- 2026-09-29 (user): 7616-7623 reassigned to Ovjang's Sixth Element spell-cast dialog (see
    -- OVJANG_SPELL_LINES above) -- no longer coupled to Overdrive activation. Only the activation
    -- line itself (7615/7624) fires here now.
    tpz.heroines.mobSay(mob, activateTextid)
end

-- Tier heroine boss mob ids -> tier number, same ids CHEERS/Heroine_Rune_of_Transfer.lua's DEST
-- table already key off of (Lion=1, Prishe=2, Nashmeira=3, Lilisette=4, Mumor=5).
local TIER_BOSS = {
    [17093178] = 1, -- Lion
    [17093211] = 2, -- Prishe
    [17093247] = 3, -- Nashmeira
    [17093286] = 4, -- Lilisette (main)
    -- 2026-09-29 (user): "Rune of Transfer 4 in the lobby is always active and does not deactivate."
    -- Root cause: Lilisette.lua only calls onHeroineDeath on whichever half dies SECOND (Dead>=2),
    -- and that is frequently the split clone -- its id was missing here, so tier came back nil and
    -- the whole floor-done / unlight block below was silently skipped (progress still bumped).
    [17093287] = 4, -- Lilisette split clone
    [17093309] = 5, -- Mumor
}

-- 2026-09-29 (user): lobby Rune of Transfer #5 stays unlit/unusable until floors 1-4 are cleared --
-- otherwise players can skip straight to Mumor. HH_FloorDone1..4 are set in onHeroineDeath below.
tpz.heroines.floor5Unlocked = function(instance)
    for t = 1, 4 do
        if instance:getLocalVar("HH_FloorDone" .. t) ~= 1 then
            return false
        end
    end
    return true
end

-- Called once when the instance is created: lobby rune #5 starts dormant.
tpz.heroines.initLobbyRunes = function(instance)
    local rune5 = instance:getEntity(bit.band(LOBBY_RUNE_BASE + 5, 0xFFF), TYPE_NPC)
    if rune5 then
        rune5:AnimationSub(RUNE_ANIM_UNLIT)
    end
    -- hidden ??? rune for floor 6 (csid 311) stays dormant until floor 5 (Mumor) is cleared
    local rune6 = instance:getEntity(bit.band(HIDDEN_RUNE_BASE + 5, 0xFFF), TYPE_NPC)
    if rune6 then
        rune6:AnimationSub(RUNE_ANIM_UNLIT)
    end
end

-- One call per fallen heroine. Tier fights bump instance progress (hub return / title handled there);
-- the 6th battle counts separately and ends with the Epic Heroine title.
tpz.heroines.onHeroineDeath = function(mob)
    local instance = mob:getInstance()
    if not instance then
        return
    end
    if not tpz.heroines.isSix(mob) then
        -- 2026-09-28: deactivate this tier's hidden rune now that its boss is dead -- the tier's
        -- keeper-mob objective (Aldo/beaks, Gigantoad, Toro, Warders, Pyracmon) can't be redone
        -- once the floor's trash is cleared, so leaving HH_Rune<tier>=1 let a player warp back
        -- into an already-cleared floor with no boss left to fight and no way back to the hub.
        local tier = TIER_BOSS[mob:getID()]
        if tier then
            instance:setLocalVar("HH_Rune" .. tier, 0)
            local runeNpc = instance:getEntity(bit.band(HIDDEN_RUNE_BASE + tier - 1, 0xFFF), TYPE_NPC)
            if runeNpc then
                runeNpc:AnimationSub(RUNE_ANIM_UNLIT)
            end
            -- 2026-09-29 (user): "the rune of transfers in the lobby are still active after
            -- defeating that floor's boss and clearing. They should switch to inactive and not
            -- light up... gate the usage on the boss death." The lobby #1-#5 rune (the one that
            -- warps INTO this floor) is a separate npc from the hidden ??? rune above -- mark it
            -- done here too, both visually (unlit) and via a gate flag Heroine_Rune_of_Transfer.lua
            -- checks before offering the warp-in menu.
            instance:setLocalVar("HH_FloorDone" .. tier, 1)
            -- 2026-09-29 (user): floor 5 cleared -> light the floor-6 ??? rune (gate is in
            -- Heroine_Rune_of_Transfer.lua csid 311). Set AFTER the unlight above so it isn't undone.
            if tier == 5 then
                local rune6 = instance:getEntity(bit.band(HIDDEN_RUNE_BASE + 5, 0xFFF), TYPE_NPC)
                if rune6 then
                    rune6:AnimationSub(RUNE_ANIM_LIT)
                end
            end
            local lobbyRune = instance:getEntity(bit.band(LOBBY_RUNE_BASE + tier, 0xFFF), TYPE_NPC)
            if lobbyRune then
                lobbyRune:AnimationSub(RUNE_ANIM_UNLIT)
            end
            -- floors 1-4 all cleared -> light lobby rune #5 (Mumor)
            if tier <= 4 and tpz.heroines.floor5Unlocked(instance) then
                local rune5 = instance:getEntity(bit.band(LOBBY_RUNE_BASE + 5, 0xFFF), TYPE_NPC)
                if rune5 then
                    rune5:AnimationSub(RUNE_ANIM_LIT)
                end
                for _, v in pairs(instance:getChars()) do
                    v:messageSpecial(TEXT_ACTIVATED)
                end
            end

            -- 2026-09-29 (user): floor clear-time (dialog.yml 7563/7564) -- clock started at
            -- csid 301-305's "Yes" selection (see Heroine_Rune_of_Transfer.lua onEventFinish),
            -- stopped here on the tier boss's own death. HH_FloorStartMs<tier> is 0 if the boss
            -- was somehow killed without a recorded floor-entry (e.g. pre-existing save state) --
            -- skip the announcement rather than print a bogus near-infinite time.
            local startMs = instance:getLocalVar("HH_FloorStartMs" .. tier)
            if startMs > 0 then
                local elapsedMs = instance:getLocalVar("HH_LastElapsedMs") - startMs
                local totalSeconds = math.max(0, math.floor(elapsedMs / 1000))
                for _, v in pairs(instance:getChars()) do
                    -- dialog.yml params are positional: 7563 = {0 floor, 3 seconds}; 7564 = {0 floor, 3 minutes, 2 seconds}
                    if totalSeconds < 60 then
                        v:messageSpecial(7563, tier, 0, 0, totalSeconds)
                    else
                        v:messageSpecial(7564, tier, 0, totalSeconds % 60, math.floor(totalSeconds / 60))
                    end
                end
            end
        end
        instance:setProgress(instance:getProgress() + 1)
        -- 2026-09-29 (user): "The real exit mechanism is the win condition on floor 5 or 6" --
        -- confirmed via a real capture (Floor 5/Mumor clear, Windower ID View): completing all 5
        -- tiers (progress reaches 5, matching the existing UNSUNG_HEROINE threshold just below)
        -- chains csid 300 (hub warp) straight into csid 1 (real instance-eject to zone 72,
        -- Alzadaal_Undersea_Ruins) plus dialog.yml 7561 ("You have defeated all opponents.
        -- Exiting the holdfast."). HH_FullClear is consumed by Heroine_Rune_of_Transfer.lua's own
        -- csid==300 handler once the hub-warp lands. instance:complete() (CInstance::Complete(),
        -- real binding, src/map/instance.cpp) is called here too -- it was never called anywhere
        -- in this instance's scripts before now, so ClearEntities()/INSTANCE_COMPLETE never ran;
        -- mirrors Rune_of_Transfer.lua's own real "Leave Assault" call site.
        -- 2026-09-30 (user): NO warp-out / instance:complete() on the floor-5 clear -- the run only
        -- ends on the floor-6 win (below). The UNSUNG_HEROINE title is still granted at progress 5
        -- (instances/heroines_holdfast.lua onInstanceProgressUpdate), which unlocks the floor-6 rune.
        return
    end
    local dead = instance:getLocalVar("HH_SixDead") + 1
    instance:setLocalVar("HH_SixDead", dead)
    if dead == SIX_HEROINES_NEEDED then
        -- 2026-09-29 (user): "mobs despawn instantly, the last one despawns but name is still
        -- visible and then player warps out like 10 seconds later" -- root cause: this loop used to
        -- call DespawnMob() immediately, right here, while the warp itself waits out the full
        -- RETURN_DELAY_MS (20s) below -- the two were never on the same clock. That also contradicts
        -- this file's own header note at armSixNoDespawn (line ~380): "Corpses should remain until
        -- last boss is killed, then they should decay and warp players out" -- i.e. despawn and warp
        -- were always meant to happen together. Deferred to tpz.heroines.returnToHub (fires at the
        -- same moment as the warp) via HH_SixCleanupPending instead of despawning here.
        instance:setLocalVar("HH_SixCleanupPending", 1)
        -- 2026-09-29 (user): same real exit-sequence fix as the 5-tier completion path above --
        -- the Floor 6 "all heroines" battle is this instance's other real win condition (see
        -- dialog.yml 7561's own doc note: "all 5 floor bosses dead, OR the Floor 6 battle boss(es)
        -- dead"), so it gets the identical HH_FullClear + instance:complete() treatment.
        instance:setLocalVar("HH_FullClear", 1)
        instance:complete()
        for _, v in pairs(instance:getChars()) do
            v:addTitle(EPIC_HEROINE)
        end
        -- same too-fast-warp fix as the tier bosses (see queueReturnToHub/RETURN_DELAY_MS above) --
        -- this call bypasses onInstanceProgressUpdate entirely, so it needs its own queue call.
        tpz.heroines.queueReturnToHub(instance)
    end
end

-- 2026-09-30 (user): floor-6 ??? rune is usable by anyone in a party containing an UNSUNG_HEROINE
-- holder -- granted on a floor-5 clear, or already held on entry. Lights the rune once that's true.
-- Called from the instance tick.
tpz.heroines.syncRune6 = function(instance)
    local rune6 = instance:getEntity(bit.band(HIDDEN_RUNE_BASE + 5, 0xFFF), TYPE_NPC)
    if not rune6 or rune6:AnimationSub() == RUNE_ANIM_LIT then
        return
    end
    for _, v in pairs(instance:getChars()) do
        if v:hasTitle(UNSUNG_HEROINE) then
            rune6:AnimationSub(RUNE_ANIM_LIT)
            return
        end
    end
end

-- 2026-09-30 (user): floor 6 -- all the heroines link on the first enmity hit (same one-shot idea as
-- t3Engage): the first one to get a target drags every other living six-battle heroine onto it, then
-- enmity is independent. Polled from the instance tick so no per-mob hook is needed.
tpz.heroines.tickSixLink = function(instance)
    if instance:getLocalVar("HH_SixLinked") == 1 then
        return
    end
    local target
    for id = tpz.heroines.SIX_FIRST, tpz.heroines.SIX_LAST do
        local m = GetMobByID(id, instance)
        if m and m:isSpawned() and m:isAlive() and m:getTarget() then
            target = m:getTarget()
            break
        end
    end
    if not target then
        return
    end
    instance:setLocalVar("HH_SixLinked", 1)
    for id = tpz.heroines.SIX_FIRST, tpz.heroines.SIX_LAST do
        local m = GetMobByID(id, instance)
        if m and m:isSpawned() and m:isAlive() and not m:getTarget() then
            m:updateEnmity(target)
        end
    end
end

-- 2026-09-30 (user): a fallen player has DEATH_EJECT_MS to be raised/recovered, otherwise they are
-- ejected from the instance. Per-player countdown in a char localvar, driven by the instance tick.
tpz.heroines.DEATH_EJECT_MS = 180000
tpz.heroines.tickDeathEject = function(instance, deltaMs)
    for _, v in pairs(instance:getChars()) do
        local left = v:getLocalVar("HH_DeathLeftMs")
        if v:isDead() then
            if left == 0 then
                left = tpz.heroines.DEATH_EJECT_MS
                v:messageSpecial(7311) -- 3 minute warning
            else
                local nextLeft = left - deltaMs
                left = nextLeft
                if left <= 0 then
                    v:setLocalVar("HH_DeathLeftMs", 0)
                    v:messageSpecial(7565) -- ejection
                    v:setPos(0, 0, 0, 0, 72)
                    left = nil
                end
            end
            if left then
                v:setLocalVar("HH_DeathLeftMs", left)
            end
        elseif left ~= 0 then
            v:setLocalVar("HH_DeathLeftMs", 0)
        end
    end
end
