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
SUNBREEZE2021.SHOW = {
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

-- Start the fixed-beat show. `cast` = {Mumor=npc, Uka=npc, Diva=npc, Ullegore=npc, Foudeel=npc, Bongo=npc}
-- (Bongo speaks the explainer in the capture; the first entry may be adjusted per zone).
function SUNBREEZE2021.startShow(zoneId, cast)
    if (not isSunbreeze2021AddonEnabled()) then return; end
    local key = { ["Uka Totlihn"] = "Uka" };
    for _, beat in ipairs(SUNBREEZE2021.SHOW) do
        local ms, who, dialogId = beat[1], beat[2], beat[3];
        local npc = cast[key[who] or who];
        if (npc ~= nil) then
            -- timers hang off the speaking NPC entity, cumulative from show start (no player-captured closures)
            npc:timer(ms, function(n) SUNBREEZE2021.say(n, zoneId, dialogId); end);
        end
    end
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
