-----------------------------------
-- Sunbreeze 2021 add-on: "Fantastic Fraulein Mumor Superheroine Stage Show"
-- Optional module. Default OFF. Everything gates on isSunbreeze2021AddonEnabled().
-- Status: SKELETON. Fixed-beat scripted show only (no player cheer/dance input yet; see README).
-----------------------------------
require("scripts/globals/settings");

SUNBREEZE2021 = SUNBREEZE2021 or {};

-- Admin switch (add to settings.lua): 0 = off (default), 1 = on
function isSunbreeze2021AddonEnabled()
    return (SUNBREEZE_2021_ADDON ~= nil and SUNBREEZE_2021_ADDON ~= 0);
end;

-- Per-zone offset from the CLIENT dialog id (dialog.yml of our client) to this server's TextIDs value.
-- Windurst Walls (239) = -2 is DERIVED from DSP data in other zones, NOT verified for this zone's 10000+ range:
-- confirm with the in-game test in README before enabling. Other zones intentionally absent until measured.
SUNBREEZE2021.TEXT_OFFSET = {
    [239] = -2,
};

-- Show timeline, built from capture 479 (Windurst, Perfect run): {ms, speaker, CLIENT dialog id}.
-- Waits for players are compressed to <= 15 s; the live show is player-paced (see README, "Missing pieces").
SUNBREEZE2021.SHOW_MAIN = {
        { 0, "Mumor", 10016 },
        { 3000, "Mumor", 10017 },
        { 7000, "Mumor", 10018 },
        { 12000, "???", 10019 },
        { 16000, "Mumor", 10020 },
        { 23000, "Ullegore", 10021 },
        { 26000, "Mumor", 10022 },
        { 30000, "Ullegore", 10023 },
        { 37000, "Uka Totlihn", 10024 },
        { 41000, "Mumor", 10025 },
        { 44000, "Ullegore", 10026 },
        { 47000, "Uka Totlihn", 10027 },
        { 51000, "Mumor", 10028 },
        { 54000, "Uka Totlihn", 10029 },
        { 58000, "Mumor", 10030 },
        { 65000, "Diva", 10031 },
        { 68000, "Mumor", 10032 },
        { 72000, "Diva", 10033 },
        { 76000, "Ullegore", 10034 },
        { 79000, "Diva", 10035 },
        { 83000, "Diva", 10036 },
        { 88000, "Mumor", 10037 },
        { 94000, "Mumor", 10038 },
        { 109000, "Uka Totlihn", 10056 },
        { 113000, "Ullegore", 10057 },
        { 116000, "Mumor", 10058 },
        { 125000, "Ullegore", 10059 },
        { 129000, "Ullegore", 10060 },
        { 140000, "Mumor", 10061 },
        { 144000, "Ullegore", 10062 },
        { 147000, "Ullegore", 10063 },
        { 151000, "Ullegore", 10064 },
        { 156000, "Mumor", 10065 },
        { 164000, "Mumor", 10066 },
        { 169000, "Mumor", 10067 },
        { 171000, "Mumor", 10068 },
        { 174000, "Ullegore", 10069 },
        { 179000, "Mumor", 10070 },
        { 188000, "Mumor", 10071 },
        { 196000, "Mumor", 10072 },
        { 204000, "Mumor", 10073 },
        { 215000, "Ullegore", 10074 },
        { 219000, "Uka Totlihn", 10075 },
        { 222000, "Mumor", 10076 },
        { 225000, "Uka Totlihn", 10077 },
        { 229000, "Mumor", 10078 },
        { 231000, "Mumor", 10079 },
        { 243000, "Ullegore", 10082 },
        { 247000, "Diva", 10083 },
        { 252000, "Ullegore", 10084 },
        { 256000, "Mumor", 10085 },
        { 260000, "Ullegore", 10086 },
        { 264000, "Foudeel", 10087 },
        { 268000, "Mumor", 10088 },
        { 274000, "Ullegore", 10089 },
        { 278000, "Ullegore", 10090 },
        { 282000, "Mumor", 10091 },
        { 290000, "Bongo", 10092 },
        { 295000, "Mumor", 10093 },
        { 300000, "Bongo", 10095 },
        { 303000, "Uka Totlihn", 10096 },
        { 308000, "Mumor", 10098 },
        { 315000, "Mumor", 10099 },
        { 318000, "Mumor", 10100 },
        { 321000, "Mumor", 10101 },
        { 327000, "Mumor", 10102 }
};

-- Bongo's announcement opens the show (capture 479: 13 lines, +0..+43 s; Mumor's greeting follows at +53 s). [C]
SUNBREEZE2021.SHOW_INTRO_OFFSETS = { 0, 4000, 7000, 10000, 14000, 18000, 21000, 25000, 28000, 32000, 35000, 39000, 43000 };
SUNBREEZE2021.SHOW_MAIN_DELAY = 53000;
SUNBREEZE2021.SHOW = {};
for i, t in ipairs(SUNBREEZE2021.SHOW_INTRO_OFFSETS) do
    table.insert(SUNBREEZE2021.SHOW, { t, "Bongo", 10146 + i });
end
for _, b in ipairs(SUNBREEZE2021.SHOW_MAIN) do
    table.insert(SUNBREEZE2021.SHOW, { b[1] + SUNBREEZE2021.SHOW_MAIN_DELAY, b[2], b[3] });
end

require("scripts/globals/events/sunbreeze_2021_curtain_call_anims");

-- Show-time home positions (match npc_list rows; capture 479 / 473 positions). {x, y, z, rot}
SUNBREEZE2021.HOME = {
    Mumor    = { 4.310, -9.670, 1.620, 247 },   Uka      = { 6.727, -9.090, 2.143, 119 },
    Diva     = { 2.687, -9.490, 0.450, 239 },   Ullegore = { 9.026, -10.000, 2.759, 118 },
    blank    = { 8.272, -10.000, 1.489, 152 },  Foudeel  = { 1.403, -9.370, 1.122, 248 },
    Bashraf  = { 1.768, -9.540, 2.466, 248 },   Wahboud  = { 1.037, -9.210, -0.215, 248 },
    Tango    = { 15.490, -10.020, 6.142, 120 }, Bongo    = { 16.062, -10.000, 5.050, 120 },
    Fandango = { 12.875, -10.000, 2.957, 120 },
};
-- Tango, Bongo and Fandango run in when Bongo cries "D-d-don't!" and run back out before the fade [C 479 0x00E, 16:40:08 / 16:40:49].
SUNBREEZE2021.RUN_IN = { Tango = { 7.8, -10.0, 4.1 }, Bongo = { 8.3, -10.0, 3.0 }, Fandango = { 9.0, -10.0, 1.9 } };
-- Foudeel, Bashraf and Wahboud run west at the end [C 479 0x00E, 16:40:49-56].
SUNBREEZE2021.RUN_OFF = { Foudeel = { -6.8, -7.8, 0.9 }, Bashraf = { -6.44, -8.65, 2.18 }, Wahboud = { -8.43, -7.92, -0.48 } };
-- After the curtain closes Mumor and Uka stand here selling fireworks [C 479 0x00E from 16:41:03]. Wahboud's spot is not
-- in the capture (his entity is a run-away at that point); he stands at his show position [U: "appear in the spot the show was at"].
SUNBREEZE2021.VENDOR_SPOT = { Mumor = { 6.89, -9.91, 3.83, 61 }, Uka = { 4.31, -9.70, 3.59, 50 }, Wahboud = { 1.037, -9.21, -0.215, 248 } };
-- Vendor chatter: client dialog 10108 (Mumor) / 10109 (Uka), repeated about every 20 s with emote 10 / 11 [C 479 16:41:16-16:42:42].
SUNBREEZE2021.VENDOR_LINES = { Mumor = { 10108, 10, 0 }, Uka = { 10109, 11, 9000 } };
-- Fireworks shop [C 479 0x03C 16:41:09]: price/item pairs in packet order (ids verified against item_basic).
SUNBREEZE2021.SHOP = { 5883, 125, 5881, 125, 5882, 125, 3643, 10000, 3644, 10000, 3645, 10000 };

local function stand(npc, h, visible)
    npc:setPos(h[1], h[2], h[3], h[4]);
    npc:setStatus(visible and STATUS_NORMAL or STATUS_DISAPPEAR);
end

-- Run to (x,y,z); the final setPos guarantees arrival even if the NPC path fails.
local function runTo(npc, d, rot)
    if (npc.pathTo ~= nil) then npc:pathTo(d[1], d[2], d[3], 9); end -- RUN|SCRIPT
    npc:timer(3500, function(n) n:setPos(d[1], d[2], d[3], rot or n:getRotPos()); end);
end

function SUNBREEZE2021.placeCast(cast)
    for name, id in pairs(cast) do
        local npc = GetNPCByID(id);
        local h = SUNBREEZE2021.HOME[name];
        if (npc ~= nil and h ~= nil) then stand(npc, h, true); end
    end
end

-- Post-show vendor phase: Mumor, Uka and Wahboud stand at the stage; Mumor and Uka repeat their pitch until the next show.
function SUNBREEZE2021.startVendors(zoneId, cast)
    local st = SUNBREEZE2021.state[zoneId];
    if (st == nil) then return; end
    st.vendorRun = (st.vendorRun or 0) + 1;
    local token = st.vendorRun;
    for name, spot in pairs(SUNBREEZE2021.VENDOR_SPOT) do
        local npc = cast[name] and GetNPCByID(cast[name]) or nil;
        if (npc ~= nil) then stand(npc, spot, true); end
    end
    for name, line in pairs(SUNBREEZE2021.VENDOR_LINES) do
        local id = cast[name];
        local function tick(m)
            local cur = SUNBREEZE2021.state[zoneId];
            local npc = id and GetNPCByID(id) or nil;
            if (cur == nil or cur.vendorRun ~= token or npc == nil) then return; end
            SUNBREEZE2021.say(npc, zoneId, line[1]);
            npc:sendEntityEmote(npc, line[2], 2);
            npc:timer(20000, tick);
        end
        local npc = id and GetNPCByID(id) or nil;
        if (npc ~= nil) then npc:timer(20000 + line[3], tick); end
    end
end

-- Shared onTrigger for the post-show vendors (Mumor.lua, Uka_Totlihn.lua, Wahboud.lua in the zone's npcs/).
function SUNBREEZE2021.vendorTrigger(player, npc, name)
    if (not isSunbreeze2021AddonEnabled()) then return; end
    local zoneId = player:getZoneID();
    local st = SUNBREEZE2021.state[zoneId];
    if (st == nil or (st.showEnd or 0) > os.time() or st.vendorRun == nil) then return; end -- only after the show
    local line = SUNBREEZE2021.VENDOR_LINES[name == "Wahboud" and "Mumor" or name];
    local off = SUNBREEZE2021.TEXT_OFFSET[zoneId];
    if (line ~= nil and off ~= nil) then player:showText(npc, line[1] + off); end
    showShop(player, STATIC, SUNBREEZE2021.SHOP);
end

-- Speak one line from `npc` to every player in the zone within 50 yalms of it.
function SUNBREEZE2021.say(npc, zoneId, dialogId)
    local off = SUNBREEZE2021.TEXT_OFFSET[zoneId];
    if (off == nil) then return; end
    local zone = npc:getZone();
    for _, p in pairs(zone:getPlayers()) do
        if (npc:checkDistance(p) <= 50) then
            p:showText(npc, dialogId + off);
        end
    end
end;

-- Start the fixed-beat show. `cast` = {name=npcId,...} (server NPC ids, not entities: every timed step re-resolves its NPC so a
-- stale entity is skipped, never dereferenced). Every started run gets a new token; steps from an older run do nothing.
-- Timeline: dialog beats (SHOW) + emote/animation cues (ANIMS, anchored to a dialog line) + the finale (run off, fade) + vendors.
function SUNBREEZE2021.startShow(zoneId, cast, beats)
    if (not isSunbreeze2021AddonEnabled()) then return; end
    local st = SUNBREEZE2021.state[zoneId];
    if (st == nil) then return; end
    beats = beats or SUNBREEZE2021.SHOW;
    st.run = (st.run or 0) + 1;
    st.vendorRun = (st.vendorRun or 0) + 1; -- stops the previous vendor chatter
    local run = st.run;
    local finaleMs = beats[#beats][1];
    st.showEnd = os.time() + (finaleMs + 16000) / 1000;
    local anchor = GetNPCByID(cast.Mumor);
    if (anchor == nil) then return; end
    SUNBREEZE2021.placeCast(cast);
    local function at(ms, fn)
        -- timers hang off the Mumor anchor NPC; closures capture only ids and the run token, never players
        anchor:timer(math.max(ms, 1), function(m)
            local cur = SUNBREEZE2021.state[zoneId];
            if (cur ~= nil and cur.run == run) then fn(); end
        end);
    end
    local function npcOf(name) local id = cast[name]; return id and GetNPCByID(id) or nil; end
    local key = { ["Uka Totlihn"] = "Uka" };
    local off = {};
    for _, beat in ipairs(beats) do
        local ms, who, dialogId = beat[1], beat[2], beat[3];
        if (off[dialogId] == nil) then off[dialogId] = ms; end
        local name = key[who] or who;
        at(ms, function()
            local npc = npcOf(name);
            if (npc ~= nil) then SUNBREEZE2021.say(npc, zoneId, dialogId); end
        end);
    end
    for _, a in ipairs(SUNBREEZE2021.ANIMS) do
        local base = off[a[1]];
        if (base ~= nil and cast[a[3]] ~= nil) then
            local name, kind, value = a[3], a[4], a[5];
            at(base + a[2], function()
                local npc = npcOf(name);
                if (npc == nil) then return; end
                if (kind == "e") then
                    npc:sendEntityEmote(npc, value, 2);
                else
                    npc:entityAnimationPacket(value);
                    if (value == "kesu") then
                        npc:timer(1500, function(n) n:setStatus(STATUS_DISAPPEAR); end);
                    end
                end
            end);
        end
    end
    -- finale: the three henchmen run in at Bongo's "D-d-don't!", everyone runs/fades after "enjoy the festival!"
    local runIn = off[10092];
    if (runIn ~= nil) then
        at(runIn, function()
            for name, d in pairs(SUNBREEZE2021.RUN_IN) do
                local npc = npcOf(name);
                if (npc ~= nil) then runTo(npc, d, 117); end
            end
        end);
    end
    at(finaleMs + 4000, function()
        for name, h in pairs(SUNBREEZE2021.HOME) do
            if (SUNBREEZE2021.RUN_IN[name] ~= nil) then
                local npc = npcOf(name);
                if (npc ~= nil) then runTo(npc, h, h[4]); end
            end
        end
        for name, d in pairs(SUNBREEZE2021.RUN_OFF) do
            local npc = npcOf(name);
            if (npc ~= nil) then runTo(npc, d, 126); end
        end
    end);
    at(finaleMs + 16000, function() SUNBREEZE2021.startVendors(zoneId, cast); end);
end;

-- ---------------------------------------------------------------------------
-- Framework: data-driven variants + per-zone schedule (design: docs/sunbreeze-event/DESIGN.md, decided 2026-10-07).
-- Each stage zone loops its own show every `interval` seconds. A variant supplies the beats, so new shows
-- (new dialog/models, same mechanic) are added as data here, not code. Only Curtain Call exists today.
-- cast holds SERVER npc ids and stays nil until allocated (sql/slices/sunbreeze-2021-addon/); a zone with no
-- cast is skipped. Never put capture ids here.
-- ---------------------------------------------------------------------------
SUNBREEZE2021.VARIANTS = {
    curtain_call = { beats = SUNBREEZE2021.SHOW },
};

SUNBREEZE2021.SCHEDULE = {
    -- [zoneId] = { variant = "curtain_call", interval = 3600, cast = { Mumor = <npcid>, Uka = ..., Diva = ..., Ullegore = ..., Foudeel = ..., Bongo = ... } }
    [239] = { variant = "curtain_call", interval = 3600,
        cast = { Mumor = 17756358, Uka = 17756359, Diva = 17756360, Ullegore = 17756361, Foudeel = 17756363, Bongo = 17756367, Tango = 17756366, Fandango = 17756368,
            Bashraf = 17756364, Wahboud = 17756365, blank = 17756362 } }, -- server npc_list ids (== capture 477 ids in this zone)
};

-- Call from each stage zone's Zone.lua onGameHour(zone). Starts that zone's show when the interval has elapsed
-- and no run is in progress. Scheduling itself uses no timers.
function SUNBREEZE2021.onGameHour(zone)
    if (not isSunbreeze2021AddonEnabled()) then return; end
    local zoneId = zone:getID();
    local sch = SUNBREEZE2021.SCHEDULE[zoneId];
    if (sch == nil or sch.cast == nil or sch.cast.Mumor == nil) then return; end
    local mumor = GetNPCByID(sch.cast.Mumor);
    if (mumor == nil) then return; end
    if (SUNBREEZE2021.state[zoneId] == nil) then
        SUNBREEZE2021.registerMumor(zoneId, mumor);
    end
    local st = SUNBREEZE2021.state[zoneId];
    local now = os.time();
    if ((st.showEnd or 0) > now) then return; end
    if (st.lastStart ~= nil and now - st.lastStart < sch.interval) then return; end
    st.lastStart = now;
    st.mumor = mumor;
    SUNBREEZE2021.startShow(zoneId, sch.cast, SUNBREEZE2021.VARIANTS[sch.variant].beats);
end;

-- ---------------------------------------------------------------------------
-- Emote input (modeled on tpz.wakeThePuppet.onEmote).
-- Engine hook: Topaz already calls tpz.player.onPlayerEmote(player, emoteId); DSP needs the small
-- C++ patch in README.md. The hook carries NO target, so proximity to Mumor is resolved here.
-- Emote ids: char_emotion.h (WAVE=8, CHEER=12, CLAP=13, DANCE1..4=65..68). Bongo's explainer
-- (client dialog 10157-10163) confirms /clapping /cheering /waving build her energy and
-- /dance1 Samba, /dance2 Waltz, /dance3 Neo Crystal Jig, /dance4 Super Crusher Jig.
-- NOT VERIFIED: accolade thresholds, dance-window length, tier cutoffs and the bond-meter
-- rules are placeholders until decoded from captures; marked PLACEHOLDER.
-- ---------------------------------------------------------------------------
SUNBREEZE2021.EMOTE = { WAVE = 8, CHEER = 12, CLAP = 13, DANCE1 = 65, DANCE2 = 66, DANCE3 = 67, DANCE4 = 68 };
SUNBREEZE2021.CHEER_RANGE = 20;          -- PLACEHOLDER
SUNBREEZE2021.ACCOLADES_PER_DANCE = 10;  -- PLACEHOLDER
SUNBREEZE2021.DANCE_WINDOW_MS = 10000;   -- PLACEHOLDER

-- per-zone live state: show.mumor (npc), show.accolades, show.danceCall (emote id or nil), show.danceStart (ms)
SUNBREEZE2021.state = {};

local function nowMs() return os.time() * 1000; end

function SUNBREEZE2021.onEmote(player, emoteId)
    if (not isSunbreeze2021AddonEnabled()) then return; end
    local st = SUNBREEZE2021.state[player:getZoneID()];
    if (st == nil or st.mumor == nil) then return; end
    local E = SUNBREEZE2021.EMOTE;
    if (player:checkDistance(st.mumor) > SUNBREEZE2021.CHEER_RANGE) then return; end

    if (emoteId == E.CHEER or emoteId == E.CLAP or emoteId == E.WAVE) then
        st.accolades = (st.accolades or 0) + 1;
        if (st.accolades >= SUNBREEZE2021.ACCOLADES_PER_DANCE and st.danceCall == nil) then
            SUNBREEZE2021.callDance(st, st.nextDance or E.DANCE1);
        end
    elseif (emoteId >= E.DANCE1 and emoteId <= E.DANCE4 and st.danceCall ~= nil) then
        local inWindow = (nowMs() - st.danceStart) <= SUNBREEZE2021.DANCE_WINDOW_MS;
        if (inWindow and st.danced[player:getID()] == nil) then
            st.danced[player:getID()] = (emoteId == st.danceCall);
        end
    end
end;

-- Mumor announces a dance (the call lines are the client dialog ids 10051-10054 per capture; the
-- text->dialog mapping is in the CSV) and opens the response window.
SUNBREEZE2021.DANCE_CALL_TEXT = { [65] = 10053, [66] = 10054, [67] = 10051, [68] = 10052 };

function SUNBREEZE2021.callDance(st, emoteId)
    st.danceCall, st.danceStart, st.danced = emoteId, nowMs(), {};
    local zoneId = st.mumor:getZoneID();
    SUNBREEZE2021.say(st.mumor, zoneId, SUNBREEZE2021.DANCE_CALL_TEXT[emoteId]);
    st.mumor:timer(SUNBREEZE2021.DANCE_WINDOW_MS, function(m) SUNBREEZE2021.endDance(zoneId); end);
end;

-- Sync message (decoded from captures 441: Perfect / Trust II, 0x02A packets):
--   * one message per matched dance, sent only to players who matched; Data0 (param1) = tier 0-3.
--   * tier text via dialog 10104: "...synchronized" / " a good deal" / " exceptionally well" / " to the utmost degree of perfection".
--   * Phase 1 dances: tier is always 0 in every capture. Firesday Night Fever dances (4 calls): tiers 0,1,2,3
--     in order on four consecutive matches (both captures) -> tier = consecutive-match streak, capped at 3.
--     (Streak reset on a miss is INFERRED, no capture contains a miss in Firesday.)
--   * Trust II capture sends dialog 10103 ("You are overflowing with trust!" family, 3 texts) in the Firesday
--     window instead of 10104, with Data3 = 4000 on the first three and 0/-1 junk on the last. What selects
--     10103 vs 10104 is NOT decoded (hypothesis: player is on the Trust reward track). Exposed as
--     st.bondVariant (default off); Data3 is left 0 because its meaning is unknown.
SUNBREEZE2021.SYNC_MSG = 10104;   -- client dialog id (+TEXT_OFFSET)
SUNBREEZE2021.BOND_MSG = 10103;

function SUNBREEZE2021.endDance(zoneId)
    local st = SUNBREEZE2021.state[zoneId];
    if (st == nil) then return; end
    local off = SUNBREEZE2021.TEXT_OFFSET[zoneId];
    st.streak = st.streak or {};
    for _, p in pairs(st.mumor:getZone():getPlayers()) do
        local pid = p:getID();
        if (st.danced[pid] == true) then
            local tier = 0;
            if (st.firesday) then
                tier = math.min(st.streak[pid] or 0, 3);
                st.streak[pid] = (st.streak[pid] or 0) + 1;
            end
            if (tier == 3) then
                st.perfect = st.perfect or {};
                st.perfect[pid] = true;
            end
            if (off ~= nil) then
                local msg = (st.bondVariant and SUNBREEZE2021.BOND_MSG or SUNBREEZE2021.SYNC_MSG) + off;
                p:messageSpecial(msg, tier, 0, 0, 0);
            end
        else
            st.streak[pid] = 0;
        end
    end
    st.danceCall, st.accolades = nil, 0;
end;

function SUNBREEZE2021.registerMumor(zoneId, mumorNpc)
    SUNBREEZE2021.state[zoneId] = { mumor = mumorNpc, accolades = 0, danced = {} };
end;

-- ---------------------------------------------------------------------------
-- Rewards (Moogle hand-out). Item ids verified three ways: id_bridge (Topaz = LSB),
-- dsp-fresh sql/item_basic.sql, and the 0x020 packets in the Perfect capture; spot-checked in
-- Valhalla's db (db.valhalla.group item 27467).
-- "Perfect" = reached sync tier 3 in Firesday Night Fever. INFERRED from the capture (the Perfect run
-- shows tiers 0-3; no capture shows what the exact threshold is). Other-run rewards from captures
-- (30 Goshikitenge / Cipher of Mumor's alter ego) and Trust Mumor II are NOT wired: their ids are unresolved.
-- ---------------------------------------------------------------------------
SUNBREEZE2021.AGENT_SET = { 25606, 26974, 27111, 27296, 27467 }; -- hood, coat, cuffs, pants, boots

-- Call from the Moogle's onTrigger after the show. `textIds` = that zone's TextIDs table
-- (ITEM_OBTAINED, ITEM_CANNOT_BE_OBTAINED). Returns true if the set was given.
function SUNBREEZE2021.giveAgentSet(player, zoneId, textIds)
    if (not isSunbreeze2021AddonEnabled()) then return false; end
    local st = SUNBREEZE2021.state[zoneId];
    local pid = player:getID();
    if (st == nil or st.perfect == nil or st.perfect[pid] ~= true) then return false; end
    -- the pieces are RaEx (Valhalla db): skip any the player already holds in any container
    local missing = {};
    for _, itemId in ipairs(SUNBREEZE2021.AGENT_SET) do
        if (not player:hasItem(itemId)) then
            table.insert(missing, itemId);
        end
    end
    if (#missing > 0 and player:getFreeSlotsCount() < #missing) then
        player:messageSpecial(textIds.ITEM_CANNOT_BE_OBTAINED, missing[1]);
        return false;
    end
    for _, itemId in ipairs(missing) do
        if (player:addItem(itemId)) then
            player:messageSpecial(textIds.ITEM_OBTAINED, itemId);
        end
    end
    st.perfect[pid] = nil; -- one set per perfect run
    return #missing > 0;
end;
