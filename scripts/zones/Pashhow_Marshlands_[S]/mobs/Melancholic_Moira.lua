-----------------------------------
-- Area: Pashhow Marshlands [S] (90)
--  MOB: Melancholic Moira (Voidwatch, Indigo III)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z82 ids - 566 [V: z90 dialog.yml text-checked this session].
-- Evidence: [C] capture Raguza 2021.03.27, [B] BG forum #106/#176/#611/#1357, [D] design guess.
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 8072;
local VW_MINUTES_REMAINING   = 8073;
local VW_SECONDS_REMAINING   = 8074;
local VW_TIME_UP             = 8075;
local VW_FADES               = 8076;
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

local VWMSG = {msgWeakElem = 8186, msgBlitzOn = 8193, msgBlitzOff = 8194, msgBlitzGain = 8195, msgBR = 8196, msgW = 8197};

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
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);
    vwEndOperation(mob);
    local idx = mob:getID() - 17146510;
    vwOnKill(mob, player, {
        region = "THREE", stage = 3, -- [C] 12300 cruor = 6000 * 205% green
        pyxisId = 17146654 + idx,
        drops = {11815}, -- Appetence Crown [B #176]; id checked vs live item_basic. Rate [D]. Silver Mirror/Black Rock/Darksteel Ingot [B #106,#1357] are commons, not modelled (placeholder pool)
        keyitem = ATMACITE_OF_INCURSION, -- 1810 [W/F]; KI-VERIFICATION.md: client id OK
        msgKeyItem = 8170,
        msgCruor = 8166, msgFinalBR = 8163, msgFinalYG = 8161, msgFinalW = 8162,
    });
end;
