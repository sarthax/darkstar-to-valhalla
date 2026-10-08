-----------------------------------
-- Area: Maze of Shakhrami (198)
--  MOB: Ogbunabali (Voidwatch, Jade II / Windurst Stage II)
-- Voidwatch slice: 30 minute limit + cleanup. Ticks via onMobRoam/onMobFight
-- (open-zone mob, no instance). Message ids = z95 ids - 997 [V: z198 dialog.yml text-checked, 138 matches].
-----------------------------------

require("scripts/globals/voidwatch");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/msg");
local VW_MINUTES_TO_COMPLETE = 7399;
local VW_MINUTES_REMAINING   = 7400;
local VW_SECONDS_REMAINING   = 7401;
local VW_TIME_UP             = 7402;
local VW_FADES               = 7403;
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

local VWMSG = {msgWeakElem = 7513, msgBlitzOn = 7520, msgBlitzOff = 7521, msgBlitzGain = 7522, msgBR = 7523, msgW = 7524};

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
    -- [F,J] high attack speed, Store TP-like spam, double attack. Amounts [D]. Does not cast magic (spellList 0).
    mob:setMod(MOD_DOUBLE_ATTACK, 10);
    mob:setMod(MOD_STORETP, 30);
end;

function onMobRoam(mob) tick(mob); end;

function onMobFight(mob, target)
    tick(mob);
end;

function onMobDeath(mob, player, isKiller)
    mob:setLocalVar("VW_DEADLINE", 0);

    vwEndOperation(mob);
    local idx = mob:getID() - 17588707;
    vwOnKill(mob, player, {
        region = "THREE", stage = 2, -- [F] Windurst Stage II; 5500 base cruor (capture 7040 = 5500 x 1.28 green)
        pyxisId = 17588785 + idx,
        drops = {19140, 11771, 3510, 798, 5755}, -- Mantodea Harpe, Pipilaka Belt, Silver Mirror, Turquoise, Slab of Ruszor Meat [F]; JP lists Rift Sand instead of Ruszor Meat; ids vs DSP item_basic
        petrifact = true, -- Jade (Windurst) path: Maddening Petrifact rare [U 2026-10-07]
        keyitem = VIVID_PERIAPT_OF_FOCUS, -- 1792 [W/B/J]; DSP keyitems.lua name; client-id check pending
        msgKeyItem = 7497,
        msgCruor = 7493, msgFinalBR = 7490, msgFinalYG = 7488, msgFinalW = 7489,
    });
end;
