-----------------------------------
-- Area: Jugner Forest [S] (82)
--  MOB: Kholomodumo (Voidwatch, Crimson III)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z104 ids - 3509 [V: z82 dialog.yml text-checked this session].
-- Evidence: [C] capture Raguza 2021.03.28, [B] BG forum #614/#798/#801/#292, [D] design guess.
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 8638;
local VW_MINUTES_REMAINING   = 8639;
local VW_SECONDS_REMAINING   = 8640;
local VW_TIME_UP             = 8641;
local VW_FADES               = 8642;
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

local VWMSG = {msgWeakElem = 8752, msgBlitzOn = 8759, msgBlitzOff = 8760, msgBlitzGain = 8761, msgBR = 8762, msgW = 8763};

function onMagicHit(caster, target, spell)
    vwOnMagicHit(target, caster, spell, VWMSG);
end;

-- Accursed Armor (skill 2390) adds curse spikes for 60 s [D]; drop them when the timer lapses.
local function tickArmor(mob)
    local e = mob:getLocalVar("ARMOR_END");
    if (e ~= 0 and os.time() >= e) then
        mob:setLocalVar("ARMOR_END", 0);
        mob:delMod(MOD_SPIKES, 4);
        mob:delMod(MOD_SPIKES_DMG, 0);
    end
end

local function tick(mob)
    vwWeaknessTick(mob, VWMSG);
    tickArmor(mob);
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
    -- BLM main job defaults to HP_STANDBACK 70 (mobutils SetupJob): voidwatch NMs must close to melee (precedent: Belphoebe).
    mob:setMobMod(MOBMOD_HP_STANDBACK, -1);
end;

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
    mob:setLocalVar("ARMOR_END", 0);
    mob:setLocalVar("PH2_IDX", 0);
    mob:setLocalVar("PH2_T", os.time());
end;

-- Below 50% HP [B #614]: Thunderbolt ("Meteobolt" stun, then Meteor) and Ecliptic Meteor. Meteor itself is NOT BUILT
-- (no verified skill row, see UNIMPLEMENTED.md); the phase alternates Thunderbolt 629 -> Ecliptic Meteor 2586.
-- Above 50% the engine picks Accursed Armor / Amnesic Blast from the pool skill list (SQL).
local PHASE2 = {629, 2586};

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
    if (mob:getHPP() < 50 and mob:getTP() >= 1000 and os.time() - mob:getLocalVar("PH2_T") >= 6) then
        local i = mob:getLocalVar("PH2_IDX");
        mob:setLocalVar("PH2_T", os.time());
        mob:setLocalVar("PH2_IDX", (i + 1) % #PHASE2);
        mob:useMobAbility(PHASE2[i + 1]);
    end
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);
    mob:setLocalVar("ARMOR_END", 0);
    vwEndOperation(mob);
    local idx = mob:getID() - 17113826;
    vwOnKill(mob, player, {
        region = "THREE", stage = 3, -- [C] 9660 cruor = 6000 * 161% green
        pyxisId = 17114043 + idx,
        drops = {16201, 10927}, -- Genesis Shield, Genesis Locket [B #292]; ids checked vs live item_basic. Rates [D]
        keyitem = ATMACITE_OF_PERSISTENCE, -- 1807 [W/F]; DSP keyitems.lua name; client-id check pending
        msgKeyItem = 8736,
        msgCruor = 8732, msgFinalBR = 8729, msgFinalYG = 8727, msgFinalW = 8728,
    });
end;
