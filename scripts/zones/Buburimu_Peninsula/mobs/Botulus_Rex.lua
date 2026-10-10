-----------------------------------
-- Area: Buburimu Peninsula (118)
--  MOB: Botulus Rex (Voidwatch, Jeuno Stage VI / White VI)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z95 ids + 3051 [V: z118 dialog.yml text-checked, 96 matches].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/voidwatch_ki");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 11447;
local VW_MINUTES_REMAINING   = 11448;
local VW_SECONDS_REMAINING   = 11449;
local VW_TIME_UP             = 11450;
local VW_FADES               = 11451;
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

local VWMSG = {msgWeakElem = 11561, msgBlitzOn = 11568, msgBlitzOff = 11569, msgBlitzGain = 11570, msgBR = 11571, msgW = 11572};

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

function onMobInitialize(mob)
    -- BLM main job defaults to HP_STANDBACK 70 (mobutils SetupJob): mob would stay at range above 70% HP.
    -- Voidwatch NMs must close to melee; -1 disables standback (precedent: Bahamut).
    mob:setMobMod(MOBMOD_HP_STANDBACK, -1);
end;

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
    mob:setLocalVar("VW_CHAIN", 0);
end;

-- [C] -ja spells + Meteor; [W] Chainspell at 68-80% HP then chained Meteor. Spell choice/rates [D].
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    if (mob:getHPP() < 70 and mob:getLocalVar("VW_CHAIN") == 0) then
        mob:setLocalVar("VW_CHAIN", 1);
        mob:useMobAbility(692); -- Chainspell
        return 218; -- Meteor
    end
    if (mob:hasStatusEffect(EFFECT_CHAINSPELL)) then return 218; end
    local pool = {496, 497, 498, 499, 500, 501};
    return vwPick(mob, target, pool);
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17261047;
    vwOnKill(mob, player, {
        region = "JEUNO", stage = 6, -- [C] White VI; 10000 cruor base
        pyxisId = 17261222 + idx,
        drops = {19145, 19146, 18625, 18882, 10451, 10452, 3509, 3498, 3499}, -- Asteria, Supernal Knife, Gerra's Staff, Beaivi's Scepter, Athos's Tabard, Rubeus Jacket, Plate of Heavy Metal, Riftdross, Riftcinder [F]; ids vs DSP item_basic
        dropRates = {[19145]=0.1, [19146]=12.2, [18625]=16.0, [18882]=0.1, [10451]=1.8, [10452]=2.1, [3509]=21.1, [3498]=0.8, [3499]=3.3}, -- Asteria, Supernal Knife, Gerra's Staff, Beaivi's Scepter, Athos's Tabard, Rubeus Jacket, Heavy Metal, Riftdross, Riftcinder [U 2026-10-07, % per item]
        keyitem = ATMACITE_OF_THE_SHREWD, -- DSP id 1828; client-id check pending
        msgKeyItem = 11545,
        msgCruor = 11541, msgFinalBR = 11538, msgFinalYG = 11536, msgFinalW = 11537,
    });
    vwExtraKeyItem(player, mob, DUSKY_PERIAPT_OF_VIGILANCE, 11545, 0.05); -- [F ffxiclopedia item page: possible spoil]; chance [D]
end;
