-----------------------------------
-- Area: Jugner Forest (104)
--  MOB: Belphoebe (Voidwatch, Crimson III, [S] zone)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z95 ids + 3751 [V: z104 dialog.yml text-checked].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 12147;
local VW_MINUTES_REMAINING   = 12148;
local VW_SECONDS_REMAINING   = 12149;
local VW_TIME_UP             = 12150;
local VW_FADES               = 12151;
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

local VWMSG = {msgWeakElem = 12261, msgBlitzOn = 12268, msgBlitzOff = 12269, msgBlitzGain = 12270, msgBR = 12271, msgW = 12272};

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
    -- BLM main job defaults to HP_STANDBACK 70 (mobutils SetupJob): mob would stay at range above 70% HP.
    -- Voidwatch NMs must close to melee; -1 disables standback (precedent: Bahamut).
    mob:setMobMod(MOBMOD_HP_STANDBACK, -1);
end;

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
    -- [J wikiwiki.jp, F] Arrow-barrage bird/Aern-type caster NM. Mods below are [D] amounts.
    mob:setMod(MOD_DOUBLE_ATTACK, 10);
    mob:setMod(MOD_DMGMAGIC, -30);   -- [J, F] resists magic damage; amount [D] (cap -50)
    mob:setLocalVar("BP_IDX", 0);
    mob:setLocalVar("BP_JA", 0);
    mob:setLocalVar("BP_T", os.time());
end;

-- Fixed ability order [J, F]: Spring -> Summer -> Autumn -> Winter Breeze -> Cyclonic Turmoil -> (Norn Arrows: NOT BUILT, see UNIMPLEMENTED.md).
-- Skills 2195-2199; pool skill list is empty so the engine never picks one at random.
local BREEZES = {2195, 2196, 2197, 2198, 2199};

-- Spells [J wikiwiki.jp Belphoebe]: -ga/-ja tiers by HP; Death only below 50% (infrequent) [J,B; F says 25%].
function onMonsterMagicPrepare(mob, target)
    if (mob:getLocalVar("VW_DEADLINE") - os.time() > LIMIT - 10) then return nil; end -- [D] no spells just after spawn
    local hpp = mob:getHPP();
    if (mob:getLocalVar("BP_JA") == 1) then
        mob:setLocalVar("BP_JA", 0);
        return ({496, 497, 498, 499, 500, 501})[math.random(6)]; -- [J] -ja nuke after a special skill
    end
    local pool = {365, 366, 273, 360, 359, 252, 286}; -- Breakga, Graviga, Sleepga, Dispelga, Silencega, Stun, Addle [J]
    if (hpp >= 50) then
        for _, s in ipairs({176, 181, 186, 191, 196, 201, 147, 152, 157, 162, 167, 172}) do table.insert(pool, s); end -- -ga III + tier IV (single)
    else
        for _, s in ipairs({177, 182, 187, 192, 197, 202, 178, 183, 188, 193, 198, 203}) do table.insert(pool, s); end -- -ga IV/V
        if (math.random(100) <= 10) then return 367; end -- Death, infrequent [J]; rate [D]
    end
    return vwPick(mob, target, pool);
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
    if (mob:getTP() >= 1000 and os.time() - mob:getLocalVar("BP_T") >= 4) then
        local i = mob:getLocalVar("BP_IDX");
        mob:setLocalVar("BP_T", os.time());
        mob:setLocalVar("BP_IDX", (i + 1) % #BREEZES);
        mob:setLocalVar("BP_JA", 1);
        mob:useMobAbility(BREEZES[i + 1]);
    end
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17203696;
    vwOnKill(mob, player, {
        region = "THREE", stage = 3, -- [F] stage table; cruor/EXP base
        pyxisId = 17203942 + idx,
        drops = {17057, 16498}, -- Tefnut Wand, Carabineer's Dagger [F, J]; ids checked vs DSP item_basic
        keyitem = ATMACITE_OF_DEVOTION, -- 1806 [W/F]; DSP keyitems.lua name; client-id check pending
        msgKeyItem = 12245,
        msgCruor = 12241, msgFinalBR = 12238, msgFinalYG = 12236, msgFinalW = 12237,
    });
end;
