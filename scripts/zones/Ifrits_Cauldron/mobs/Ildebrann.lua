-----------------------------------
-- Area: Ifrit's Cauldron (205)
--  MOB: Ildebrann (Voidwatch, Jeuno Stage VI / Ashen I)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z118 ids - 3939 = z95 - 888 [V: z205 dialog.yml text-checked, 96 matches].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 7508;
local VW_MINUTES_REMAINING   = 7509;
local VW_SECONDS_REMAINING   = 7510;
local VW_TIME_UP             = 7511;
local VW_FADES               = 7512;
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

local VWMSG = {msgWeakElem = 7622, msgBlitzOn = 7629, msgBlitzOff = 7630, msgBlitzGain = 7631, msgBR = 7632, msgW = 7633};

function onMagicHit(caster, target, spell)
    vwOnMagicHit(target, caster, spell, VWMSG);
end;

function onMobSpawn(mob)
    mob:setLocalVar("VW_DEADLINE", os.time() + LIMIT);
    mob:setLocalVar("VW_WARNED", LIMIT + 1);
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
    vwWeaknessInit(mob);
    mob:setLocalVar("VW_SUMMON", 0);
end;

-- [C] Firaga IV 177, Fire V 148, Firaja 496. Spell choice/rates [D].
function onMonsterMagicPrepare(mob, target)
    local pool = {177, 148, 496};
    return pool[math.random(#pool)];
end;

-- [B #1004] Hraun Dragon pets are summoned at 100/75/50/25% HP (only if not already up) [F: x2, may be resummoned].
local SUMMON_MARKS = {100, 75, 50, 25};
local function summon(mob)
    local pos = mob:getPos();
    local tgt = mob:getTarget();
    for i = 1, 2 do
        local pid = mob:getID() + i;
        local p = GetMobByID(pid);
        if (p ~= nil and not p:isSpawned()) then
            local m = SpawnMob(pid);
            if (m ~= nil) then
                m:setPos(pos.x, pos.y, pos.z, pos.rot);
                if (tgt ~= nil) then m:updateEnmity(tgt); end
            end
        end
    end
end

local function dismiss(mob)
    DespawnMob(mob:getID() + 1);
    DespawnMob(mob:getID() + 2);
end

local function tick(mob)
    vwWeaknessTick(mob, VWMSG);
    local stage = mob:getLocalVar("VW_SUMMON");
    if (stage < #SUMMON_MARKS and mob:getHPP() <= SUMMON_MARKS[stage + 1] and mob:getTarget() ~= nil) then
        mob:setLocalVar("VW_SUMMON", stage + 1);
        summon(mob);
    end
    local left = mob:getLocalVar("VW_DEADLINE") - os.time();
    if (left <= 0) then
        notify(mob, VW_TIME_UP);
        notify(mob, VW_FADES);
        mob:setLocalVar("VW_DEADLINE", 0);
        vwEndOperation(mob);
        dismiss(mob);
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

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    dismiss(mob);
    local idx = (mob:getID() - 17617166) / 3;
    vwOnKill(mob, player, {
        region = "ZILART", stage = 1, -- [C] Ashen I; [F stage table] 7000 cruor
        pyxisId = 17617264 + idx,
        drops = {10816, 19173, 3510}, -- Glassblower's Belt, Gram, Silver Mirror [F]; ids vs DSP item_basic
        keyitem = VIVID_PERIAPT_OF_ADAPTABILITY, -- DSP id 1798 [F: 'Vivid Periapt of adaptability']; client-id check pending
        msgKeyItem = 7606,
        msgCruor = 7602, msgFinalBR = 7599, msgFinalYG = 7597, msgFinalW = 7598,
    });
end;
