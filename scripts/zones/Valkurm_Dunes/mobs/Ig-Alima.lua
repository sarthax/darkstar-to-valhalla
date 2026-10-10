-----------------------------------
-- Area: Valkurm Dunes (103)
--  MOB: Ig-Alima (Voidwatch, Jeuno Stage VI / White VI)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z118 ids + 7 = z95 + 3058 [V].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/voidwatch_ki");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 11454;
local VW_MINUTES_REMAINING   = 11455;
local VW_SECONDS_REMAINING   = 11456;
local VW_TIME_UP             = 11457;
local VW_FADES               = 11458;
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

local VWMSG = {msgWeakElem = 11568, msgBlitzOn = 11575, msgBlitzOff = 11576, msgBlitzGain = 11577, msgBR = 11578, msgW = 11579};

function onMagicHit(caster, target, spell)
    vwOnMagicHit(target, caster, spell, VWMSG);
    return 0;
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
    mob:setLocalVar("VW_MANTLE", 0);
end;

-- [C] Blaze Spikes (249) seen; Ice 250 / Shock 251 [D standard ids]. Recast when no spikes are up; spikes can't be dispelled [F].
-- Dread Spikes at low HP [F] not built (no evidence for id/trigger).
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    if (mob:hasStatusEffect(EFFECT_BLAZE_SPIKES) or mob:hasStatusEffect(EFFECT_ICE_SPIKES) or mob:hasStatusEffect(EFFECT_SHOCK_SPIKES)) then return nil; end
    local pool = {249, 250, 251};
    return vwPick(mob, target, pool);
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
    if (mob:getLocalVar("VW_MANTLE") == 1) then -- [F] Oblivion's Mantle always follows Diluvial Wake
        mob:setLocalVar("VW_MANTLE", 0);
        mob:useMobAbility(2790);
    end
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17199612;
    vwOnKill(mob, player, {
        region = "JEUNO", stage = 6, -- [C] White VI; 10000 cruor base
        pyxisId = 17199767 + idx,
        drops = {19174, 19175, 18908, 18558, 10450, 3509, 3498, 3499}, -- Borealis, Hoarfrost Blade, Dhampyr Sword, Wroth Scythe, Ogier's Surcoat, Plate of Heavy Metal, Riftdross, Riftcinder [F]; ids vs DSP item_basic
        dropRates = {[19174]=0.2, [19175]=4.1, [18908]=5.7, [18558]=18.5, [10450]=2.6, [3509]=12.8, [3498]=3.6, [3499]=1.0}, -- Borealis, Hoarfrost Blade, Dhampyr Sword, Wroth Scythe, Ogier's Surcoat, Heavy Metal, Riftdross, Riftcinder [U 2026-10-07, % per item]
        keyitem = ATMACITE_OF_THE_VALIANT, -- DSP id 1827; client-id check pending
        msgKeyItem = 11552,
        msgCruor = 11548, msgFinalBR = 11545, msgFinalYG = 11543, msgFinalW = 11544,
    });
    vwExtraKeyItem(player, mob, VIVID_PERIAPT_OF_VIGILANCE, 11552, 0.05); -- [F ffxiclopedia item page: possible spoil]; chance [D]
end;
