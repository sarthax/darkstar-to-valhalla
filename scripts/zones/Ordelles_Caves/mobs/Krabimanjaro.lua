-----------------------------------
-- Area: Ordelle's Caves
--  MOB: Krabimanjaro (Voidwatch, Crimson II)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids from research/MESSAGE-IDS-SLICE-ZONES.md
-- (anchor verified, offsets inferred).
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
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

function onMobInitialize(mob)
    mob:setMobMod(MOBMOD_ADD_EFFECT, 1);
end;

-- Melee additional effect: Paralysis [W] BG wiki; user-observed in-game. Chance/power/duration are [D] guesses.
function onAdditionalEffect(mob, player)
    local resist = applyResistanceAddEffect(mob, player, ELE_LIGHTNING, EFFECT_PARALYSIS);
    if (math.random(0,99) >= 25 or resist <= 0.5) then
        return 0,0,0;
    end
    if (player:hasStatusEffect(EFFECT_PARALYSIS) == false) then
        player:addStatusEffect(EFFECT_PARALYSIS, 20, 0, 60 * resist);
    end
    return SUBEFFECT_PARALYSIS, msgBasic.ADD_EFFECT_STATUS, EFFECT_PARALYSIS;
end;

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
    mob:setMod(MOD_TRIPLE_ATTACK, 10); -- [W] BG wiki "can triple attack"; 10% rate per user
    mob:setMod(MOD_DEFP, 50); -- [W] "very high Defense"; amount is a [D] guess
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
    -- [W] Regain below 50% HP (BG wiki Krabimanjaro; Krabkatoa "modest TP Regain"); 100 is the user's [D] pick
    if (mob:getHPP() < 50 and mob:getMod(MOD_REGAIN) == 0) then
        mob:addMod(MOD_REGAIN, 100);
    end
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17568142;
    vwOnKill(mob, player, {
        region = "THREE", stage = 2, -- [F] stage table
        pyxisId = 17568201 + idx,
        drops = {19737, 11917}, -- Percept Bow, Carapacho Cuffs [W]; ids checked vs DSP item_basic
        keyitem = VIVID_PERIAPT_OF_INTENSITY, -- 1794 [V client DAT]
        msgKeyItem = 7611,
        msgCruor = 7607, msgFinalBR = 7604, msgFinalYG = 7602, msgFinalW = 7603,
    });
end;
