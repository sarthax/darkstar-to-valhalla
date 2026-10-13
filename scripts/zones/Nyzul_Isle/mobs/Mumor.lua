-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Mumor (tier 5, final heroine)
-- Skills: mob_skill_lists 1061 (dances/jigs, Final Eternal Heart); spells: list 438 (tier V nukes,
-- -ga IV, -ja, Holy II) -- all from capture #237.
-- HP (90000) is an ESTIMATE (no HP track in the capture); the -50% DMG cap stands in for the
-- wiki's unquantified 25% HP "heavy damage resistance".
--
-- 2026-09-28: phase-2 timing/music rebuilt from a full re-read of the real capture
-- (CapLog 2025.05.02 00:10:44-00:18:59 + packetviewer/incoming/0x05F.log), replacing a flat 6s
-- guess that conflated three distinct capture-confirmed beats into one:
--   1) HP<=25% (00:16:56, Uka Totlihn msg 7670) -> music changes to song 119 "Awakening" 3s later
--      (00:16:59, 0x05F packet, musicType 0-3 all 4 party slots). Phase-1 fight music was song 146
--      "The Colosseum" (set 00:10:44, fight start -- not replicated here, zone/instance default).
--   2) ~117s later (00:18:53) Mumor casts Final Eternal Heart: NPC Chat msg 7675 (dialog.yml 7660,
--      verified this session against a fresh dat-extractor pull of zone 77, exact text match "All
--      life shall die and be born anew!Final!!! Eternal!!! Heart!!!").
--   3) 6s after the cast line (00:18:59) the skill resolves: capture's [AView] line confirms
--      Cat: 11 ID: 2904 Anim: 2042 Msg: 406 -- matches FINAL_ETERNAL_HEART below exactly.
-- The Uka Totlihn warning line ("I have a bad feeling...") has no packet logged in the capture
-- (only Mumor's own msg 7675 line one second later was captured) -- not implemented, per project
-- rule against inventing an unverified message id.
--
-- 2026-09-28: party-wipe taunt added (CapLog 00:38:00 wipe -> 00:38:06 "That's right! The Mighty
-- Maidens are back and better than ever!" / Uka Totlihn "Oh, Mumor, we did it!", ids 7651/7652 --
-- see IDs.lua). Detected in onMobFight by polling instance:getChars() for an all-dead party, since
-- there is no dedicated wipe hook; fires once via the same os.time()-localvar delay idiom used for
-- the FEH cast above (never entity:timer() closures, per project rule).
--
-- 2026-09-29 (user, from wiki + user-confirmed dialog ids): filled in the rest of the punch-list
-- "Mumor missing death text" gap for the FLOOR 5 SOLO FIGHT ONLY (Floor 6's fake-death/revive
-- sequence, 7663-7666, is a separate mechanic and unchanged):
--   - 7642: Mumor's battle engage line, once, via engageOnce (same pattern as Lion 7572/Prishe 7583).
--   - Phase 0->1 (HP<=25%) transition now also restores HP to 50%, adds a haste/damage-up buff (wiki:
--     "speeds up significantly, deals additional damage" -- magnitude not capture-confirmed, reused
--     from the real PUP Overdrive mod block), and plays 7653/7654 (Mumor) + 7655 (Uka Totlihn
--     reaction) as the transition monologue.
--   - onMobDeath (floor-5-only branch): 7665 (Mumor's real death line) + 7664 (Uka Totlihn's
--     reaction), distinct from floor 6's reuse of the same two ids for its fake-death/revive beat.
-----------------------------------
require("scripts/zones/Nyzul_Isle/IDs")
require("scripts/globals/heroines_holdfast")
local FINAL_ETERNAL_HEART = 2904
local PHASE2_MUSIC = 119 -- "Awakening"
local FEH_CAST_DELAY = 117 -- phase-2 entry -> FEH cast line (00:16:59 -> 00:18:53)
local FEH_CALL_DELAY = 5 -- Uka's 7662 call -> FEH chant
local TRANS_LINE_DELAY = 3 -- 7653 -> 7655 -> 7654 spacing (s)
local FEH_RESOLVE_DELAY = 6 -- FEH cast line -> skill resolution (00:18:53 -> 00:18:59)
local WIPE_TAUNT_DELAY = 6 -- wipe -> taunt line (00:38:00 -> 00:38:06)
local UKA_TOTLIHN = 17093471

-- 2026-09-29 (user): phase-2 (HP<=25%) stat buff tuning -- not capture-confirmed, tweak freely here.
-- HASTE_MAGIC is in the engine's 10000=100% scale (modifier.h), so 5000 = 50% haste.
-- ATTP is a plain percent mod. PHASE2_DAMAGE_REDUCTION_PERCENT feeds Mod::DMG (a flat % cut to ALL
-- damage she takes -- physical/magic/range/breath alike, battleutils.cpp PhysicalDmgTaken/
-- MagicalDmgTaken/etc. each add DMG/100 to their own resist calc), NOT a defense/evasion stat --
-- confirmed 2026-09-29 (user): "she should take less damage from players, a flat 50% cut, not a
-- defense/MDEF boost." Mod::DMG is engine-capped at -50% (battleutils.cpp:5030, `max(resist, 0.5f)`),
-- so any value >=50 here has the same effect at 50; the constant exists so a future lower value
-- (e.g. a 25% cut) still works correctly.
local PHASE2_HASTE_PERCENT = 50 -- % haste gained
local PHASE2_DMG_UP_PERCENT = 50 -- % attack damage gained (ATTP)
local PHASE2_DAMAGE_REDUCTION_PERCENT = 50 -- % cut to ALL damage she takes (Mod::DMG, capped at 50 by the engine)

-- 2026-10-01 (user): Uka does the Welcome emote (id 10, capture 00:12:50) when Mumor engages.
function onMobEngaged(mob, target)
    local instance = mob:getInstance()
    if instance and not tpz.heroines.isSix(mob) then
        local uka = instance:getEntity(bit.band(UKA_TOTLIHN, 0xFFF), TYPE_NPC)
        if uka then
            tpz.heroines.emote(uka, 10, 2)
        end
    end
end

-- 2026-10-04 (user): she ran dry on MP mid-fight (tier V nukes 156-267, -ga IV 371-455, -ja 298-398).
-- Mods are not dispellable. MOD_REFRESH is MP per 3s tick; CONSERVE_MP is % chance to spend a
-- quarter of the cost. Strength is a first guess -- tune here. MP_FLOOR is a hard backstop in
-- onMobFight (tops her up if a cast would still be unaffordable) in case the mob MP tick ignores
-- MOD_REFRESH in this engine.
local MUMOR_REFRESH = 25
local MUMOR_CONSERVE_MP = 50
local MUMOR_MP_FLOOR = 500

function onMobSpawn(mob)
    mob:addMod(MOD_REFRESH, MUMOR_REFRESH)
    mob:addMod(MOD_CONSERVE_MP, MUMOR_CONSERVE_MP)
    mob:setLocalVar("HH_Phase", 0)
    mob:setLocalVar("HH_WipeFired", 0)
    tpz.heroines.armSixNoDespawn(mob)
    -- 2026-09-29 (user): 6th battle only -- "If Mumor dies before all the other heroes do, she will
    -- always be brought back to life... prevented from zerging". setUnkillable clamps her HP to 1
    -- instead of letting it reach 0 (CBattleEntity::addHP), so she can never really Die() this way --
    -- onMobFight below clears the flag once HH_SixDead reaches 6 (all other heroines dead), letting
    -- her final death proceed normally. See heroines_holdfast.lua's mumorFakeDeath/tickMumorRevive
    -- for the ~15s fake-death sequence the HP-1 clamp triggers.
    if tpz.heroines.isSix(mob) then
        mob:setUnkillable(true)
        mob:setLocalVar("HH_Unkillable", 1)
    end
end

function onMobFight(mob, target)
    -- 2026-09-29 (user-confirmed): "7642 - Mumor's battle engage line." Fires once, first engage,
    -- same pattern as Lion (7572)/Prishe (7583).
    tpz.heroines.engageOnce(mob, 7642)

    if mob:getMP() < MUMOR_MP_FLOOR then
        mob:setMP(MUMOR_MP_FLOOR)
    end

    if tpz.heroines.isSix(mob) then
        local instance = mob:getInstance()
        if instance then
            if instance:getLocalVar("HH_SixDead") >= 6 then
                if mob:getLocalVar("HH_Unkillable") == 1 then
                    mob:setUnkillable(false)
                    mob:setLocalVar("HH_Unkillable", 0)
                end
            elseif mob:getHP() <= 1 and instance:getLocalVar("HH_MumorReviving") == 0 then
                tpz.heroines.mumorFakeDeath(mob)
                return
            end
        end
    end

    if mob:getLocalVar("HH_WipeFired") == 0 then
        local instance = mob:getInstance()
        if instance then
            local allDead = true
            for _, v in pairs(instance:getChars()) do
                if v:isAlive() then
                    allDead = false
                    break
                end
            end
            if allDead then
                mob:setLocalVar("HH_WipeFired", 1)
                mob:setLocalVar("HH_WipeTaunt", os.time() + WIPE_TAUNT_DELAY)
            end
        end
    elseif mob:getLocalVar("HH_WipeFired") == 1 and os.time() >= mob:getLocalVar("HH_WipeTaunt") then
        mob:setLocalVar("HH_WipeFired", 2)
        mob:showText(mob, NyzulIsle.text.MUMOR_WIPE_TAUNT)
        local instance = mob:getInstance()
        if instance and not tpz.heroines.isSix(mob) then -- no cheerleader in floor 6
            local uka = instance:getEntity(bit.band(UKA_TOTLIHN, 0xFFF), TYPE_NPC)
            if uka then
                uka:showText(uka, NyzulIsle.text.UKA_TOTLIHN_WIPE_TAUNT)
                tpz.heroines.emote(uka, 43, 2) -- capture 00:38:06 "we did it" (emote id 43)
            end
        end
    end

    local phase = mob:getLocalVar("HH_Phase")
    if phase == 0 and mob:getHPP() <= 25 then
        mob:setLocalVar("HH_Phase", 1)
        -- 2026-09-29 (user, from wiki, tuning values user-specified 2026-09-29): "the meat of the
        -- fight happens at 25%... HP restored to 50%, speeds up significantly, deals additional
        -- damage, gains a damage reduction trait." None of these magnitudes are capture-confirmed --
        -- see the PHASE2_* constants above, tweak those instead of the numbers here.
        mob:addMod(MOD_DMG, -(PHASE2_DAMAGE_REDUCTION_PERCENT * 100)) -- flat % cut to damage taken (wiki's "damage reduction trait")
        mob:addMod(MOD_HASTE_MAGIC, PHASE2_HASTE_PERCENT * 100)
        mob:addMod(MOD_ATTP, PHASE2_DMG_UP_PERCENT)
        mob:setHP(math.floor(mob:getMaxHP() / 2))
        -- 2026-09-29 (user-confirmed): "7653-7655 is Mumor's 25% hp state transition text before she
        -- recovers to 50% and changes phases." 7655 ("Mumor? Are you feeling all rrright?") is Uka
        -- Totlihn reacting, same pairing pattern as the 7664 death reaction above.
        -- 2026-09-30 (user): final-stage monologue is 7653 -> 3s -> 7655 -> 3s -> 7654 (steps 2/3 in
        -- the TRANS block below; 7655 is skipped in floor 6, where there is no cheerleader).
        mob:showText(mob, 7653)
        mob:setLocalVar("HH_TransStep", 1)
        mob:setLocalVar("HH_TransAt", os.time() + TRANS_LINE_DELAY)
        local instance = mob:getInstance()
        if instance then
            for _, v in pairs(instance:getChars()) do
                for musicType = 0, 3 do
                    v:ChangeMusic(musicType, PHASE2_MUSIC)
                end
            end
        end
        mob:setLocalVar("HH_FEHCast", os.time() + FEH_CAST_DELAY)
    end

    -- transition monologue steps (see above)
    local step = mob:getLocalVar("HH_TransStep")
    if step > 0 and os.time() >= mob:getLocalVar("HH_TransAt") then
        local instance = mob:getInstance()
        if step == 1 then
            local uka = instance and not tpz.heroines.isSix(mob) and instance:getEntity(bit.band(UKA_TOTLIHN, 0xFFF), TYPE_NPC)
            if uka then
                for _, v in pairs(instance:getChars()) do
                    v:messageText(uka, 7655, true)
                end
                tpz.heroines.emote(uka, 32, 2) -- capture 00:16:56 "are you feeling all right" (emote id 32)
            end
            mob:setLocalVar("HH_TransStep", 2)
        else
            mob:showText(mob, 7654)
            mob:setLocalVar("HH_TransStep", 0)
        end
        mob:setLocalVar("HH_TransAt", os.time() + TRANS_LINE_DELAY)
    end

    phase = mob:getLocalVar("HH_Phase")
    if phase == 1 and os.time() >= mob:getLocalVar("HH_FEHCast") then
        -- 2026-09-30 (user): Uka's "I have a bad feeling about this" (7662) is the call; Final
        -- Eternal Heart follows ~5s later (chant), then resolves FEH_RESOLVE_DELAY after that.
        mob:setLocalVar("HH_Phase", 2)
        local instance = mob:getInstance()
        local uka = instance and not tpz.heroines.isSix(mob) and instance:getEntity(bit.band(UKA_TOTLIHN, 0xFFF), TYPE_NPC)
        if uka then
            for _, v in pairs(instance:getChars()) do
                v:messageText(uka, 7662, true)
            end
            tpz.heroines.emote(uka, 29, 2) -- capture 00:18:52 "bad feeling" (emote id 29)
        end
        mob:setLocalVar("HH_FEHChant", os.time() + FEH_CALL_DELAY)
    elseif phase == 2 and os.time() >= mob:getLocalVar("HH_FEHChant") then
        mob:setLocalVar("HH_Phase", 3)
        mob:showText(mob, NyzulIsle.text.MUMOR_FINAL_ETERNAL_HEART)
        mob:setLocalVar("HH_FEHResolve", os.time() + FEH_RESOLVE_DELAY)
    elseif phase == 3 and os.time() >= mob:getLocalVar("HH_FEHResolve")
        and mob:getCurrentAction() == ACTION_ATTACK then
        mob:setLocalVar("HH_Phase", 4)
        mob:setLocalVar("HH_ChantDone", 1) -- chant already shown above
        mob:useMobAbility(FINAL_ETERNAL_HEART)
    end
end

-- 2026-09-29 (user): superseded -- 7665 ("I am eternal...immortal... I shall rise again...") is
-- Mumor's mid-fight REVIVAL line (see tpz.heroines.tickMumorRevive in heroines_holdfast.lua), not a
-- final-death line; it no longer fires here. This onMobDeath now only runs for her real, final
-- death -- either the Floor 5 solo fight, or the Floor 6 fight once HH_SixDead has already reached
-- 6 and onMobFight above has cleared setUnkillable.
function onMobDeath(mob, player, isKiller)
    -- 2026-09-29 (user-confirmed): "7665 is Mumor's death line" / "7664 is the cheerleader's
    -- response to Mumor's death" -- scoped to the Floor 5 solo fight only. Floor 6's death uses a
    -- separate substitute-heroine framework (no cheerleader there) -- see mumorFakeDeath/
    -- tickMumorRevive above, whose own 7663-7666 assignment (fake mid-fight death/revive, not the
    -- real death) is unrelated and unchanged.
    if not tpz.heroines.isSix(mob) then
        tpz.heroines.mobSay(mob, 7665)
        local instance = mob:getInstance()
        if instance then
            local uka = instance:getEntity(bit.band(UKA_TOTLIHN, 0xFFF), TYPE_NPC)
            if uka then
                -- 2026-10-01 (user, confirmed via playthrough video): Uka's line on Mumor's death is
                -- 7666 ("Come back to us!") with emote 21; 7664 was the wrong mapping.
                for _, v in pairs(instance:getChars()) do
                    v:messageText(uka, 7666, true)
                end
                tpz.heroines.emote(uka, 21, 2)
            end
        end
    end
    tpz.heroines.onHeroineDeath(mob)
end

