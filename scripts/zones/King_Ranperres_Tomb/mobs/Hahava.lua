-----------------------------------
-- Area: King Ranperre's Tomb (190)
--  MOB: Hahava (Voidwatch, Crimson IV)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z95 ids - 1015 [V: z190 dialog.yml text-checked, 138 matches].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 7381;
local VW_MINUTES_REMAINING   = 7382;
local VW_SECONDS_REMAINING   = 7383;
local VW_TIME_UP             = 7384;
local VW_FADES               = 7385;
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

local VWMSG = {msgWeakElem = 7495, msgBlitzOn = 7502, msgBlitzOff = 7503, msgBlitzGain = 7504, msgBR = 7505, msgW = 7506};

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
    -- [F] ~25% quad attack, non-dispellable Regain, very high WS-damage resistance. Amounts [D].
    mob:setMod(MOD_QUAD_ATTACK, 25);
    mob:setMod(MOD_REGAIN, 10);
    mob:setLocalVar("HH_STANCE", 0);
    mob:setLocalVar("HH_PHYS", 0);
    mob:setLocalVar("HH_T", os.time());
    mob:setLocalVar("HH_SWITCH", os.time() + 45); -- [J] "switches stance occasionally"; interval [D]
end;

-- Stance skills [J]: Yaksha (-50% physical taken) 2714 Stance / 2715 Damnation / 2717 Bliss / 2716 Oblivion (<50%)
--                    Raksha 2718 Stance / 2719 Judgement / 2720 Illusion / 2721 Vengeance (<50%)
-- Pool skill list is empty so the engine never picks one at random; Lua drives them.
local function pickSkill(mob)
    local hpp = mob:getHPP();
    if (mob:getLocalVar("HH_STANCE") == 1) then
        local t = {2715, 2717};
        if (hpp < 50) then table.insert(t, 2716); end
        return t[math.random(#t)];
    else
        local t = {2719, 2720};
        if (hpp < 50) then table.insert(t, 2721); end
        return t[math.random(#t)];
    end
end

-- Spells [J, F]: common Graviga/Sleepga/Slowga/Dispelga/Bindga/Silencega/Addle/Stun; Fire IV + Firaga III at >=50%, Fire V + Firaga IV + Firaja below.
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end
    local pool = {366, 273, 357, 360, 362, 359, 286, 252};
    if (mob:getHPP() >= 50) then
        table.insert(pool, 147); table.insert(pool, 176);
    else
        table.insert(pool, 148); table.insert(pool, 177); table.insert(pool, 496);
    end
    return pool[math.random(#pool)];
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
    local now = os.time();
    if (mob:getTP() >= 1000 and now - mob:getLocalVar("HH_T") >= 4) then
        mob:setLocalVar("HH_T", now);
        local st = mob:getLocalVar("HH_STANCE");
        if (st == 0 or now >= mob:getLocalVar("HH_SWITCH")) then
            -- toggle stance; first use picks Yaksha
            mob:setLocalVar("HH_SWITCH", now + 45);
            mob:useMobAbility((st == 1) and 2718 or 2714);
        else
            mob:useMobAbility(pickSkill(mob));
        end
    end
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17555901;
    vwOnKill(mob, player, {
        region = "THREE", stage = 4, -- [F] stage table; cruor/EXP base (6500 cruor confirmed [C])
        pyxisId = 17555964 + idx,
        drops = {11855, 10928, 11814, 3445, 3510}, -- Mextli Harness, Ganesha's Mala, Ganesha's Mask, Suit of Hahava's Mail, Silver Mirror [F]; ids checked vs DSP item_basic
        keyitem = ATMACITE_OF_EMINENCE, -- 1808 [W/F]; DSP keyitems.lua name; client-id check pending
        msgKeyItem = 7479,
        msgCruor = 7475, msgFinalBR = 7472, msgFinalYG = 7470, msgFinalW = 7471,
    });
end;
