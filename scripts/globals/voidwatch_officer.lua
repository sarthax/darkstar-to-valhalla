-----------------------------------
-- Voidwatch officers + Atmacite refiners (shared logic). FIRST PASS, UNTESTED IN-GAME.
-- Evidence tags: [C] capture (Playthrough Captures/voidwatch_captures 708-721, 699)  [V] client/decompile  [H] hypothesis from captures  [D] design choice (invented, flagged)
--
-- Officer event (963 SandOria / 9 Bastok / 1024 Windurst) reads ONLY params 0..2 [V]. Refiner event (962 / 8 / 1023) reads params 0..6 [V].
-- Menu options [C]: 5 = grant first stratum abyssite, 4 = query stock (updateEvent stock), 3 = request voidstones, 1 = confirm, 0 = exit.
-- Hook needed in voidwatch.lua vwOnKill (not applied here, file has unrelated pending edits):  vwoMarkKill(mob, player);
-----------------------------------
require("scripts/globals/status");
require("scripts/globals/keyitems");

VWO = {};

-- path index: Crimson 0, Indigo 1, Jade 2 [C]
VWO.PATHS = {
    {name = "Crimson", ki = {CRIMSON_STRATUM_ABYSSITE, CRIMSON_STRATUM_ABYSSITE_II, CRIMSON_STRATUM_ABYSSITE_III, CRIMSON_STRATUM_ABYSSITE_IV}},
    {name = "Indigo",  ki = {INDIGO_STRATUM_ABYSSITE, INDIGO_STRATUM_ABYSSITE_II, INDIGO_STRATUM_ABYSSITE_III, INDIGO_STRATUM_ABYSSITE_IV}},
    {name = "Jade",    ki = {JADE_STRATUM_ABYSSITE, JADE_STRATUM_ABYSSITE_II, JADE_STRATUM_ABYSSITE_III, JADE_STRATUM_ABYSSITE_IV}},
};
-- Outland/other paths (no captures; KI ids from keyitems.lua). Index 3.. use the second tier var (see tierVar).
VWO.PATHS[4] = {name = "White",    ki = {WHITE_STRATUM_ABYSSITE, WHITE_STRATUM_ABYSSITE_II, WHITE_STRATUM_ABYSSITE_III, WHITE_STRATUM_ABYSSITE_IV, WHITE_STRATUM_ABYSSITE_V, WHITE_STRATUM_ABYSSITE_VI}};
VWO.PATHS[5] = {name = "Ashen",    ki = {ASHEN_STRATUM_ABYSSITE, ASHEN_STRATUM_ABYSSITE_II, ASHEN_STRATUM_ABYSSITE_III}};
VWO.PATHS[6] = {name = "Hyacinth", ki = {HYACINTH_STRATUM_ABYSSITE, HYACINTH_STRATUM_ABYSSITE_II}};
VWO.PATHS[7] = {name = "Amber",    ki = {AMBER_STRATUM_ABYSSITE, AMBER_STRATUM_ABYSSITE_II}};
VWO.VOIDSTONES = {VOIDSTONE1, VOIDSTONE2, VOIDSTONE3, VOIDSTONE4, VOIDSTONE5, VOIDSTONE6}; -- [V] 1539-1544

-- NM name (mob:getName()) -> {pathIdx(0..2), tier(1..4)} [W tracker]. Jade IV has no NM listed (gap).
VWO.NM_TIER = {
    Cottus = {0, 1}, Sarimanok = {0, 1}, Krabimanjaro = {0, 2}, Belphoebe = {0, 3}, Kholomodumo = {0, 3}, Hahava = {0, 4},
    Sallow_Seymour = {1, 1}, Ushumgal = {1, 1}, Lorbulcrud = {1, 2}, Melancholic_Moira = {1, 3}, ["Murk-veined_Baneberry"] = {1, 3}, Celaeno = {1, 4},
    Pancimanci = {2, 1}, Virvatuli = {2, 1}, Ogbunabali = {2, 2}, Lord_Asag = {2, 3},
    -- tracker entries with a known tier only (others unknown, not guessed)
    Lancing_Lamorak = {3, 4}, Stachysaurus = {3, 5}, Smierc = {3, 5}, Ig_Alima = {3, 6}, Botulus_Rex = {3, 6},
    Ildebrann = {4, 1}, Aello = {4, 3},
    -- [J] wikiwiki.jp route step pages. Both live and framework-SQL spellings are listed where they differ. Index: White 3, Ashen 4, Hyacinth 5, Amber 6.
    Voidwrought = {2, 4}, Akupara = {2, 3}, -- Akupara: Jade III [user-confirmed]
    -- Cetus is NOT a Voidwatch NM (Rhapsodies of Vana'diel mission 2-18); intentionally absent
    Cherufe = {3, 1}, Taweret = {3, 1}, Yatagarasu = {3, 1}, Agathos = {3, 1}, Goji = {3, 1}, Gugalanna = {3, 1},
    Gasha = {3, 2}, Giltine = {3, 2}, Mellonia = {3, 2}, Nympha_Eunomia = {3, 2}, ["Roly-Poly"] = {3, 2}, Roly_Poly = {3, 2}, Laidly_Laurence = {3, 2},
    Pil = {3, 3}, Akvan = {3, 3},
    Bhishani = {3, 4}, Rw_Nw_Prt_M_Hrw = {3, 4}, RwNwPrtMHrw = {3, 4},
    Gwynn_ap_Nudd = {3, 5}, GwynnapNudd = {3, 5},
    Gaunab = {3, 6}, Ocythoe = {3, 6}, Kalasutrax = {3, 6},
    Holy_Moly = {4, 1}, Neith = {4, 1}, Sabotender_Campeador = {4, 1}, Tangaroa = {4, 1}, Malleator_Maurok = {4, 1},
    Cath_Palug = {4, 2}, Cath_palug = {4, 2}, Mimic_King = {4, 2},
    Uptala = {4, 3}, Qilin = {4, 3},
    Abununnu = {5, 1}, ["Tsui-Goab"] = {5, 1}, Isarukitsck = {5, 1}, Fjalar = {5, 1}, Bismarck = {5, 2},
    Dimgruzub = {6, 1}, Vanasarvik = {6, 1}, Yalungur = {6, 1}, Brekekekex = {6, 1}, Morta = {6, 2},
};
-- Which NMs must ALL be beaten before the refiner upgrades a tier [W]: only I->II and IV->V style gates; others are quest-driven.
VWO.REFINE_NEEDS_ALL = {[1] = true, [4] = true};

local STOCK_PERIOD = 20 * 3600; -- [W ffxiclopedia Voidstone] one voidstone per 20 hours, unlimited accumulation in officer stock
local STOCK_PERIOD_PERIAPT = 16 * 3600; -- [W] with Vivid Periapt of Exploration
local CARRY = 3; -- [W] carry 3; 6 with a Vivid/Dusky/Neutral Periapt of Frontiers
local TIER_VAR = "VWO_TIERS";    -- bit = path*4 + tier-1 [H, matches refiner p5 bits 0..11]
local STOCK_VAR = "VWO_STOCK";
local STOCK_TS = "VWO_STOCK_TS";

-- tier completion storage: paths 0-2 -> VWO_TIERS bit path*4+tier-1 (matches refiner p5 [H]); paths 3+ -> VWO_TIERS2 bit (path-3)*8+tier-1
local function tierVar(path, tier)
    if (path <= 2) then return TIER_VAR, path * 4 + tier - 1; end
    return TIER_VAR .. "2", (path - 3) * 8 + tier - 1;
end

local function tierGet(player, path, tier)
    local v, b = tierVar(path, tier);
    return math.floor(player:getVar(v) / 2 ^ b) % 2 == 1;
end

function vwoHeldTier(player, p) -- highest held tier of path p (1..4) or 0
    local ki = VWO.PATHS[p + 1].ki;
    for t = #ki, 1, -1 do
        if (player:hasKeyItem(ki[t])) then return t; end
    end
    return 0;
end

function vwoStock(player)
    local ts = player:getVar(STOCK_TS);
    if (ts == 0) then return 0; end
    local stock = player:getVar(STOCK_VAR);
    local period = player:hasKeyItem(VIVID_PERIAPT_OF_EXPLORATION) and STOCK_PERIOD_PERIAPT or STOCK_PERIOD;
    local gain = math.floor((os.time() - ts) / period);
    if (gain > 0) then
        stock = stock + gain;
        player:setVar(STOCK_VAR, stock);
        player:setVar(STOCK_TS, ts + gain * period);
    end
    return stock;
end

local function vwoStartClock(player) -- clock starts at the first level 75+ officer talk, initial stock 1 [W/D]
    if (player:getVar(STOCK_TS) == 0 and player:getMainLvl() >= 75) then
        player:setVar(STOCK_VAR, 1);
        player:setVar(STOCK_TS, os.time());
    end
end

local function anyStratum(player)
    for p = 0, #VWO.PATHS - 1 do if (vwoHeldTier(player, p) > 0) then return true; end end
    return false;
end

local function voidstoneLevel(player)
    for n = 6, 1, -1 do if (player:hasKeyItem(VWO.VOIDSTONES[n])) then return n; end end
    return 0;
end

function vwoSetVoidstones(player, n) -- KI level = stack count, replaces the previous level [C]
    for i = 1, 6 do player:delKeyItem(VWO.VOIDSTONES[i]); end
    if (n > 0) then player:addKeyItem(VWO.VOIDSTONES[math.min(n, 6)]); end
end

function vwoMarkKill(mob, player)
    if (player == nil) then return; end
    local e = VWO.NM_TIER[mob:getName()];
    if (e == nil) then return; end
    local v, bit = tierVar(e[1], e[2]);
    local zone = player:getZoneID();
    for _, m in pairs(player:getAlliance()) do
        if (m:getZoneID() == zone) then
            local cur = m:getVar(v);
            if (math.floor(cur / 2 ^ bit) % 2 == 0) then m:setVar(v, cur + 2 ^ bit); end
        end
    end
end

-- [H] officer params. cfg = {nation=1..3 [C], city=f7 2/1/3 [C], csid, kiMsg}
local function officerParams(player, cfg)
    local n = voidstoneLevel(player);
    local p0 = 2 + (cfg.nation or 0) * 4 + 2 * 256 + n * 2048 + 3 * 262144 + (cfg.city or 0) * 2097152; -- Lua 5.1: no bit operators
    local p2 = anyStratum(player) and 1 or 0; -- bit0 [C]; bits 1-6 unresolved
    return p0, player:getCurrency("cruor"), p2;
end

function vwoOfficerTrigger(player, cfg)
    vwoStartClock(player);
    local p0, p1, p2 = officerParams(player, cfg);
    player:startEvent(cfg.officerCsid, p0, p1, p2, 0, 0, 0, 0, 0);
end

function vwoOfficerUpdate(player, cfg, option)
    if (option == 4 or option == 3) then
        player:updateEvent(vwoStock(player), 0, 0, 0, 0, 0, 0, 0);
    end
end

function vwoOfficerFinish(player, cfg, option)
    if (option == 5) then
        local first = cfg.grantPath and VWO.PATHS[cfg.grantPath].ki[1] or nil; -- sub-quest NPCs (Hildegard, Gushing Spring) have no grant
        if (first ~= nil and vwoHeldTier(player, cfg.grantPath - 1) == 0 and player:getMainLvl() >= 75) then
            player:addKeyItem(first);
            player:messageSpecial(cfg.kiMsg, first);
        end
    elseif (option == 1) then
        local stock = vwoStock(player);
        local cap = CARRY;
        if (player:hasKeyItem(VIVID_PERIAPT_OF_FRONTIERS) or player:hasKeyItem(DUSKY_PERIAPT_OF_FRONTIERS) or player:hasKeyItem(NEUTRAL_PERIAPT_OF_FRONTIERS)) then cap = 6; end
        local held = voidstoneLevel(player);
        local add = math.min(stock, cap - held); -- [D] amount selection not decoded: top up to the carry cap; carried stones count against it
        if (add > 0) then
            player:setVar(STOCK_VAR, stock - add);
            vwoSetVoidstones(player, held + add); -- no message: the numbered "Obtained key item: N voidstones" id is not capture-verified
        end
    end
end

-- [H] refiner params (see header of Atmacite_Refiner.lua)
VWO_PROBE = true; -- set false/remove after refiner menu gating is decoded
local function refinerParams(player, cfg)
    local held = anyStratum(player);
    local p0 = (cfg.nation or 0) * 262144 + 2 -- nation unknown for outland refiners [D=0]
         + (held and 4 or 0);
    local p1 = held and 16 or 0;
    local tiers = player:getVar(TIER_VAR);
    local p5 = 0x800000 + (tiers % 4096); -- first three paths only [H]
    local p6 = 0;
    for p = 0, 2 do -- p6 encoding known for Crimson/Indigo/Jade only [H]
        local t = vwoHeldTier(player, p);
        if (t > 0) then
            p6 = p6 + 2 ^ (2 * p) + ((t % 2 == 1) and 2 ^ (2 * p + 1) or 0);
        end
    end
    if (VWO_PROBE) then -- TEMPORARY diagnostic: all menu-gating bits set to see which sections the client unlocks
        p5, p6 = 0xFFFFFF, 0xFFFFFFF;
        printf("[VWO refiner probe] p5=%d p6=%d (normal p5/p6 overwritten)", p5, p6);
    end
    return p0, p1, 0, 0, player:getCurrency("cruor"), p5, p6;
end

function vwoRefinerTrigger(player, cfg)
    local p0, p1, p2, p3, p4, p5, p6 = refinerParams(player, cfg);
    player:startEvent(cfg.refinerCsid, p0, p1, p2, p3, p4, p5, p6, 7);
end

-- True when every NM of (path, tier) is recorded complete [H: bitmask holds one bit per tier, set by any tier NM kill, so this gate is only an approximation]
local function tierDone(player, p, t)
    return tierGet(player, p, t);
end

-- voidwatch_warps.lua is GENERATED by the Mission Toolkit (Voidwatch > Atmacite warp checklist) and only holds destinations marked complete + validated.
-- pcall so a server without the generated file still loads; unmapped options just log.
pcall(require, "scripts/globals/voidwatch_warps");
local WARP_COST = 1000; -- cruor [W ffxiclopedia Atmacite Refiner]

local function vwoRefinerWarp(player, option)
    local w = VWO_WARPS and VWO_WARPS[option];
    if (w == nil) then return false; end
    local inPast = string.find(player:getZoneName(), "%[S%]") ~= nil;
    if ((w.era == "past") ~= inPast) then
        printf("[VWO refiner] option %d is a %s destination but %s is in the %s refiner zone", option, w.era, player:getName(), inPast and "past" or "present");
        return true;
    end
    -- [D] the abyssite gate: holding any key item of the destination's stratum path. Per-tier gating is not decoded.
    local held = false;
    for p = 0, #VWO.PATHS - 1 do
        if (VWO.PATHS[p + 1].name == w.stone and vwoHeldTier(player, p) > 0) then held = true; end
    end
    if (not held) then return true; end
    if (player:getCurrency("cruor") < WARP_COST) then return true; end
    player:delCurrency("cruor", WARP_COST);
    player:setPos(w.x, w.y, w.z, w.rot, w.zone);
    return true;
end

function vwoRefinerFinish(player, cfg, option)
    if (option ~= 1) then
        -- Teleport options: (destId << 16) | 2 [C]. Mapped ones warp via VWO_WARPS; any other option is logged so it can be added in the toolkit.
        if (option ~= 0 and not vwoRefinerWarp(player, option)) then
            printf("[VWO refiner] unhandled option=%d (%s) char=%s zone=%d", option, string.format("0x%X", option), player:getName(), player:getZoneID());
        end
        return;
    end
    for p = 0, #VWO.PATHS - 1 do
        local t = vwoHeldTier(player, p);
        local ki = VWO.PATHS[p + 1].ki;
        if (t > 0 and t < #ki and tierDone(player, p, t)) then
            player:delKeyItem(ki[t]);
            player:addKeyItem(ki[t + 1]);
            player:messageSpecial(cfg.kiMsg, ki[t + 1]);
            return; -- [D] upgrades one stone per confirm; multi-stone selection encoding unknown
        end
    end
end
