-----------------------------------
-- Wamoura family maturation: a pre-evolution form (Wamouracampa / Wamoura_Prince) matures into
-- Wamoura after being left unengaged for about 1 Vana'diel day.
-----------------------------------
-- 2026-09-14: real, confirmed mechanic per FFXIclopedia (same real source already cited in this
-- project's own working Assault implementation, mission-packages/lebros_cavern_missions_1-4's
-- Ranch_Wamouracampa.lua -- "~1 Vana'diel day unengaged"). User directly confirmed this is
-- observably NOT working on Valhalla for the WILD (non-Assault) Wamouracampa/Wamoura_Prince in
-- Halvung and Mount Zhayolm -- traced to Topaz's own real source: both zones' pre-evolution mob
-- files (scripts/zones/Halvung/mobs/Wamouracampa.lua,
-- scripts/zones/Mount_Zhayolm/mobs/Wamoura_Prince.lua) only ever implement a curled/stretched
-- stance toggle, with the maturation itself left as an explicit unimplemented TODO ("Morph into
-- Wamoura") in Topaz's own source -- confirmed identical, byte-for-byte-shaped TODO in both
-- files, and old-dsp-reference's own copy of Halvung's file is the same unmodified stub. This
-- was never a DSP-specific regression -- it was never built anywhere, on either codebase.
--
-- Built as a proper shared module (not duplicated per-zone) since the exact same real mechanic
-- applies to at least 2 zones -- following this session's other family-mixin precedent
-- (imp/eruca/ziz), but scoped to this codebase's REAL per-mob callback architecture from the
-- start (onMobSpawn/onMobRoam/onMobFight -- NOT Topaz's `mixins = {...}`/addListener pattern,
-- which is confirmed dead code in old-dsp-reference; see this project's other family mixins'
-- headers for the full explanation of why).
--
-- Real model ids (1802 = pre-evolution look, 1808 = Wamoura look) and skill lists (254 =
-- pre-evolution, 253 = Wamoura) are NOT guessed -- decoded directly from sql/mob_pools.sql's real
-- `modelid` column for the wild pools this session (poolid 4281 'Wamouracampa' and 4282
-- 'Wamoura_Prince' both carry modelid blob 0x00000A0700..., poolid 4280 'Wamoura' carries
-- 0x00001007...; bytes 3-4 read little-endian as 0x070A=1802 and 0x0710=1808 respectively) --
-- and independently cross-checked: these are the EXACT SAME blob values (byte-for-byte) as
-- poolid 3319 'Ranch_Wamouracampa'/3318 'Ranch_Wamoura', the Assault pair whose 1802/1808 model
-- ids were already separately confirmed via 2 live user observations (see Ranch_Wamouracampa.lua's
-- own header) -- strong independent confirmation, not a coincidence.
--
-- Real duration: 1 Vana'diel day = 86400 Vana'diel seconds; confirmed real 25:1 Earth:Vana'diel
-- second ratio directly in this codebase's own src/map/vana_time.cpp (`/ 60.0 * 25`) -> 86400/25
-- = 3456 real seconds. NOT the Assault-specific Ranch_Wamouracampa.lua's compressed/randomized
-- 10-minute window -- that was a deliberate per-user-direction scaling to fit a 30-minute mission
-- clock, documented as such in that file's own header; this wild-zone version uses the real,
-- uncompressed FFXIclopedia duration since there's no mission clock to fit here.
--
-- 2026-09-14, user-corrected: a real BG Wiki excerpt describes maturation as LEVEL-gated ("at
-- level 50, these wamouracampa morph into the adult Wamoura... share the same experience points
-- and level"), which on its own conflicts with the time-based trigger above. User's own
-- resolution: "I think it's both, only the higher level ones mature" -- so this is now a
-- combined gate, not a replacement: a spawn is only ELIGIBLE to mature at all if its individually
-- assigned level (mob:getMainLvl(), varies per-spawn within its group's real min/max level range
-- -- confirmed via sql/mob_groups.sql) is at the top of that zone's real range, and even an
-- eligible spawn still has to wait out the same real unengaged-time gate. maxLevel is passed in
-- per zone by the caller (not hardcoded here) since Halvung (73-76) and Mount Zhayolm (79-81)
-- have different real ranges -- see each mob file's own onSpawn call for its real max.
-----------------------------------
require("scripts/globals/status")
-----------------------------------

WamouraMix = WamouraMix or {}

local MATURE_SECONDS  = 3456 -- ~1 Vana'diel day
local ENGAGE_DELAY_SEC = 60  -- being engaged pushes maturation back, doesn't cancel it (same real
                              -- design already used by Ranch_Wamouracampa.lua's onMobFight)

local PRE_MODEL_ID  = 1802
local PRE_SKILL_LIST = 254
local WAMOURA_MODEL_ID  = 1808
local WAMOURA_SKILL_LIST = 253
local WAMOURA_NAME = "Wamoura"

-- call from the mob's own real onMobSpawn(mob). maxLevel is that zone's real top of range
-- (sql/mob_groups.sql) -- only a spawn whose own assigned level equals it is ever eligible to
-- mature at all; the rest keep their stance-toggle behavior forever, same real design as the
-- Assault version's "only 3 of many larvae ever mature" (Ranch_Wamouracampa.lua).
WamouraMix.onSpawn = function(mob, maxLevel)
    mob:setModelId(PRE_MODEL_ID)
    mob:setMobMod(MOBMOD_SKILL_LIST, PRE_SKILL_LIST)

    if mob:getMainLvl() >= maxLevel then
        mob:setLocalVar("eligible", 1)
        mob:setLocalVar("matureTime", os.time() + MATURE_SECONDS)
    end
end

local function tryMature(mob)
    if mob:getLocalVar("matured") == 1 or mob:getLocalVar("eligible") ~= 1 then
        return
    end

    local matureTime = mob:getLocalVar("matureTime")
    if matureTime == 0 or os.time() < matureTime then
        return
    end

    mob:setLocalVar("matured", 1)
    mob:renameEntity(WAMOURA_NAME)
    mob:setModelId(WAMOURA_MODEL_ID)
    mob:setMobMod(MOBMOD_SKILL_LIST, WAMOURA_SKILL_LIST)
    mob:forceRespawn()
end

-- call from the mob's own real onMobRoam(mob) (fires every 3s while roaming/idle).
WamouraMix.onRoam = function(mob)
    tryMature(mob)
end

-- call from the mob's own real onMobFight(mob, target) (fires every 3s during combat) -- being
-- actively engaged delays maturation rather than cancelling it outright.
WamouraMix.onFight = function(mob, target)
    if mob:getLocalVar("eligible") == 1 and mob:getLocalVar("matured") == 0 then
        mob:setLocalVar("matureTime", os.time() + ENGAGE_DELAY_SEC)
    end
end

return WamouraMix
