-----------------------------------
-- Area: Ordelle's Caves
--  MOB: Krabimanjaro (Voidwatch, Crimson II)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids from research/MESSAGE-IDS-SLICE-ZONES.md
-- (anchor verified, offsets inferred).
-----------------------------------

require("scripts/globals/voidwatch");
local VW_MINUTES_TO_COMPLETE = 7513;
local VW_MINUTES_REMAINING   = 7514;
local VW_SECONDS_REMAINING   = 7515;
local VW_TIME_UP             = 7516;
local VW_FADES               = 7517;
local LIMIT = 1800; -- 30 min [C]

local function notify(mob, msgid, param)
    local p = GetPlayerByID(mob:getLocalVar("VW_SPAWNER"));
    if (p == nil or p:getZoneID() ~= mob:getZoneID()) then return; end
    for _, m in pairs(p:getAlliance()) do
        if (m:isPC() and m:getZoneID() == mob:getZoneID()) then
            m:messageSpecial(msgid, param or 0);
        end
    end
end

local VWMSG = {msgWeakElem = 7627, msgBlitzOn = 7634, msgBlitzOff = 7635, msgBlitzGain = 7636, msgBR = 7637, msgW = 7638};

function onMagicHit(caster, target, spell)
    vwOnMagicHit(target, caster, spell, VWMSG);
end;

local function tick(mob)
    vwWeaknessTick(mob, VWMSG);
    local left = mob:getLocalVar("VW_DEADLINE") - os.time();
    if (left <= 0) then
        notify(mob, VW_TIME_UP);
        notify(mob, VW_FADES);
        mob:setLocalVar("VW_DEADLINE", 0);
        vwEndOperation(mob);
        DespawnMob(mob:getID());
        return;
    end
    local warned = mob:getLocalVar("VW_WARNED");
    local marks = {600, 300, 120, 60, 30, 10};
    for _, s in ipairs(marks) do
        if (left <= s and warned > s) then
            mob:setLocalVar("VW_WARNED", s);
            if (s >= 60) then notify(mob, VW_MINUTES_REMAINING, s / 60);
            else notify(mob, VW_SECONDS_REMAINING, s); end
            break;
        end
    end
end

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
    -- [W] "Gains a Regain effect at low HP (cannot be dispelled)"; threshold/amount are [D] guesses
    if (mob:getHPP() < 25 and mob:getMod(MOD_REGAIN) == 0) then
        mob:addMod(MOD_REGAIN, 20);
    end
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17568142;
    vwOnKill(mob, player, {
        cruor = 5500, -- Crimson II base, 0% alignment [C]
        pyxisId = 17568201 + idx,
        drops = {19737, 11917}, -- Percept Bow, Carapacho Cuffs [W]; ids checked vs DSP item_basic
        keyitem = VIVID_PERIAPT_OF_INTENSITY, -- 1794 [V client DAT]
        msgKeyItem = 7611,
        msgCruor = 7607, msgFinalBR = 7604, msgFinalYG = 7602, msgFinalW = 7603,
    });
end;
