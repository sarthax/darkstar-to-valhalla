-----------------------------------
-- Chocobo Raising (VCS) - Finbarr's VCS Honeymoon: buy a ticket, trade ticket + both chococards, collect the bred egg,
-- and hatch it at the trainer. Ported from LandSandBoat hobbies/chocobo_raising/breeding.lua.
--
-- EVIDENCE: events 10101-10108 exist on Finbarr (entity 17776821) in the Upper Jeuno client DAT, with the same numbers
-- LSB uses; dialog 11710 is the client text "trade your ticket and both of the chocobo's chococards to me" (LSB 11748,
-- this client is 38 lower). Item ids 2344 (ticket), 2339/2342 (cards), 2312-2319 (eggs) are in item_basic.
-- NO CAPTURE shows any of it. The event parameters, the menu option numbers (finish option 1-4 = plan), the exdata
-- layouts (LSB Exdata::HoneymoonTicket / ChocoboEgg / ChocoboCard) and EVERY number below are LSB's.
-- LSB GUESSES (change here if evidence turns up): TICKET_PRICE (LSB gives no source), MUTATION_CHANCE 5%,
-- ABILITY_BASE 60 + 3 per receptivity rank, the Sports/Jeuno Tour ability lean (70%), PLAN_MALE_CHANCE, PLAN_STAT_SEED 8,
-- and the egg item each plan lays (Sports and Hiking are guesses even in LSB).
-----------------------------------

CHOCOBO_RAISING = CHOCOBO_RAISING or {};
local CR = CHOCOBO_RAISING;

local ITEM_TICKET  = 2344;
local ITEM_CARD_M  = 2339;
local ITEM_CARD_F  = 2342;

local TICKET_PRICE    = 3500; -- LSB
local MUTATION_CHANCE = 5;    -- LSB guess: percent per gene
local ABILITY_BASE    = 60;   -- LSB guess
local ABILITY_PER_RANK = 3;   -- LSB guess
local LEAN_CHANCE     = 70;   -- LSB guess
local PLAN_STAT_SEED  = 8;    -- LSB: points a bred egg adds to its plan's stat at hatching

local PLAN = { GOURMET = 1, SPORTS = 2, HIKING = 3, JEUNO_TOUR = 4 };

local EVENT =
{
    DATE        = 10102,
    WAITING     = 10105,
    EGG_LAID    = 10107,
    TICKET_MENU = 10108,
};

local COLORS = { 0, 1, 2, 3, 4 }; -- yellow, black, blue, red, green

-- LSB guess: percent chance of a male; other plans are even.
local PLAN_MALE_CHANCE = { [PLAN.GOURMET] = 70, [PLAN.HIKING] = 30 };

-- The stat each plan's egg is seeded with.
local PLAN_STAT = { [PLAN.GOURMET] = "strength", [PLAN.SPORTS] = "endurance", [PLAN.HIKING] = "discernment", [PLAN.JEUNO_TOUR] = "receptivity" };

-- The egg each plan lays (somewhat / a little / a bit warm). Sports and Hiking are guesses.
local BRED_EGG_ITEM = { [PLAN.GOURMET] = 2319, [PLAN.SPORTS] = 2318, [PLAN.HIKING] = 2318, [PLAN.JEUNO_TOUR] = 2317 };

-- Char vars: the laid egg waits until the JST midnight after the date. (No brackets in names: DSP's var writer rejects them.)
local VAR_EGG_ITEM  = "ChocoBreedEggItem";
local VAR_EGG_GENES = "ChocoBreedEggGenes"; -- dna1 | dna2<<3 | dna3<<6 | ability<<9 | plan0<<14
local VAR_EGG_READY = "ChocoBreedEggReady";

-- Local vars: the date's egg is rolled when the items are traded and written when the scene finishes.
local LV_DATE_ITEM  = "ChocoBreedDateItem";
local LV_DATE_GENES = "ChocoBreedDateGenes";

-- Local vars: a bred egg handed to a trainer, read at trade time because the item is gone by the time the scene ends.
local LV_BRED_FLAG  = "ChocoboRaisingEggBred";
local LV_BRED_GENES = "ChocoboRaisingEggGenes";

local function byteWord(bytes, first)
    return bytes[first] + bytes[first + 1] * 256 + bytes[first + 2] * 65536 + bytes[first + 3] * 16777216;
end

-- Card exdata (LSB Exdata::ChocoboCard): the fields breeding needs.
local function readCard(item)
    local b    = item:getExData();
    local word = byteWord(b, 5);
    return
    {
        dna         = { word % 8, math.floor(word / 8) % 8, math.floor(word / 64) % 8 },
        abilities   = { math.floor(word / 512) % 16, math.floor(word / 8192) % 16 },
        receptivity = math.floor(b[4] / 32), -- rank, 0-7
        color       = math.floor(word / 33554432) % 8,
    };
end

local function packGenes(egg)
    return egg.dna[1] + egg.dna[2] * 8 + egg.dna[3] * 64 + egg.ability * 512 + egg.plan0 * 16384;
end

local function unpackGenes(word)
    return
    {
        dna    = { word % 8, math.floor(word / 8) % 8, math.floor(word / 64) % 8 },
        ability = math.floor(word / 512) % 16,
        plan0  = math.floor(word / 16384) % 4,
    };
end

-- Egg exdata (LSB Exdata::ChocoboEgg): the word is dna1:3 dna2:3 dna3:3 ability:4 unknown:1 plan:2 ... isBred at bit 31.
local function eggExData(egg)
    local word = packGenes(egg) + 2147483648;
    local data = {};
    for i = 0, 3 do data[#data + 1] = math.floor(word / 2 ^ (8 * i)) % 256; end
    for i = 1, 20 do data[#data + 1] = 0; end
    return data;
end

local function inheritDNA(sire, dam)
    local dna = {};
    for i = 1, 3 do
        local gene = sire[i];
        if (math.random(1, 2) == 2) then
            gene = dam[i];
        end
        if (math.random(1, 100) <= MUTATION_CHANCE) then
            gene = COLORS[math.random(1, #COLORS)];
        end
        dna[i] = gene;
    end
    return dna;
end

local function listAbilities(card)
    local out = {};
    for _, ability in ipairs(card.abilities) do
        if (ability ~= 0) then
            table.insert(out, ability);
        end
    end
    return out;
end

local function inheritAbility(sire, dam, plan)
    local sireAbilities, damAbilities = listAbilities(sire), listAbilities(dam);
    if (#sireAbilities + #damAbilities == 0) then
        return 0;
    end

    local rank = (sire.receptivity + dam.receptivity) / 2;
    if (math.random(1, 100) > ABILITY_BASE + math.floor(rank * ABILITY_PER_RANK)) then
        return 0;
    end

    -- LSB guess: Sports leans to the sire's abilities and Jeuno Tour to the dam's.
    local favoured = nil;
    if (plan == PLAN.SPORTS) then
        favoured = sireAbilities;
    elseif (plan == PLAN.JEUNO_TOUR) then
        favoured = damAbilities;
    end
    if (favoured ~= nil and #favoured > 0 and math.random(1, 100) <= LEAN_CHANCE) then
        return favoured[math.random(1, #favoured)];
    end

    local pool = {};
    for _, a in ipairs(sireAbilities) do table.insert(pool, a); end
    for _, a in ipairs(damAbilities) do table.insert(pool, a); end
    return pool[math.random(1, #pool)];
end

-- The ticket stores its plan in byte 1 and "PlanA".."PlanD" in the 12-byte name signature.
local function ticketExData(plan)
    local data = { plan };
    for i = 1, 11 do data[#data + 1] = 0; end
    for _, b in ipairs(CR.encodeSignature("Plan" .. string.char(64 + plan))) do data[#data + 1] = b; end
    return data;
end

local function nextJstMidnight()
    return math.floor((os.time() + 32400) / 86400) * 86400 + 86400 - 32400;
end

local function pendingEgg(player)
    local itemId = player:getVar(VAR_EGG_ITEM);
    if (itemId == 0) then
        return nil;
    end
    return { itemId = itemId, genes = unpackGenes(player:getVar(VAR_EGG_GENES)), ready = os.time() >= player:getVar(VAR_EGG_READY) };
end

local function loadTownTextIDs(player)
    package.loaded["scripts/zones/Upper_Jeuno/TextIDs"] = nil;
    require("scripts/zones/Upper_Jeuno/TextIDs");
end

-----------------------------------
-- Finbarr hooks (Upper Jeuno)
-----------------------------------

function CR.breedingTrigger(player, npc)
    local egg = pendingEgg(player);
    if (egg ~= nil and egg.ready) then
        player:startEvent(EVENT.EGG_LAID);
    elseif (egg ~= nil) then
        player:startEvent(EVENT.WAITING);
    else
        player:startEvent(EVENT.TICKET_MENU);
    end
end

function CR.breedingTrade(player, npc, trade)
    if (pendingEgg(player) ~= nil) then
        player:startEvent(EVENT.WAITING);
        return;
    end

    -- Exactly the ticket and one card of each sex.
    local items = {};
    if (trade:getSlotCount() == 3 and trade:getItemCount() == 3) then
        for slot = 0, 7 do
            local id = trade:getItemId(slot);
            if (id == ITEM_TICKET) then items.ticket = trade:getItem(slot);
            elseif (id == ITEM_CARD_M) then items.sire = trade:getItem(slot);
            elseif (id == ITEM_CARD_F) then items.dam = trade:getItem(slot); end
        end
    end
    if (items.ticket == nil or items.sire == nil or items.dam == nil) then
        player:startEvent(EVENT.TICKET_MENU);
        return;
    end

    local plan = items.ticket:getExData()[1];
    if (plan < PLAN.GOURMET or plan > PLAN.JEUNO_TOUR) then
        plan = PLAN.GOURMET; -- LSB: a ticket with no plan is a Gourmet one
    end

    local sire, dam = readCard(items.sire), readCard(items.dam);
    player:setLocalVar(LV_DATE_ITEM, BRED_EGG_ITEM[plan]);
    player:setLocalVar(LV_DATE_GENES, packGenes({ dna = inheritDNA(sire.dna, dam.dna), ability = inheritAbility(sire, dam, plan), plan0 = plan - 1 }));

    -- Event 10102 params: plan, then the sire's and dam's look (colour in bits 9-11, bit 12 marks the male).
    player:startEvent(EVENT.DATE, plan, sire.color * 512 + 4096, dam.color * 512);
end

local function buyTicket(player, npc, plan)
    loadTownTextIDs(player);
    if (player:getGil() < TICKET_PRICE) then
        player:messageSpecial(NOT_HAVE_ENOUGH_GIL);
        return;
    end
    -- The ticket is Rare.
    if (player:getFreeSlotsCount() == 0 or player:hasItem(ITEM_TICKET)) then
        player:messageSpecial(ITEM_CANNOT_BE_OBTAINED, ITEM_TICKET);
        return;
    end

    if (player:addItemExData(ITEM_TICKET, ticketExData(plan), true)) then
        player:delGil(TICKET_PRICE);
        player:showText(npc, FINBARR_TRADE_TICKET_AND_CARDS);
        player:messageSpecial(ITEM_OBTAINED, ITEM_TICKET);
    end
end

local function giveEgg(player)
    local egg = pendingEgg(player);
    if (egg == nil) then
        return;
    end
    loadTownTextIDs(player);
    -- LSB TODO: no reply for a full bag; the egg waits.
    if (player:getFreeSlotsCount() == 0) then
        player:messageSpecial(ITEM_CANNOT_BE_OBTAINED, egg.itemId);
        return;
    end
    if (player:addItemExData(egg.itemId, eggExData({ dna = egg.genes.dna, ability = egg.genes.ability, plan0 = egg.genes.plan0 }), true)) then
        player:messageSpecial(ITEM_OBTAINED, egg.itemId);
        player:setVar(VAR_EGG_ITEM, 0);
        player:setVar(VAR_EGG_GENES, 0);
        player:setVar(VAR_EGG_READY, 0);
    end
end

function CR.breedingFinish(player, csid, option, npc)
    if (csid == EVENT.TICKET_MENU and option >= PLAN.GOURMET and option <= PLAN.JEUNO_TOUR) then
        buyTicket(player, npc, option);
    elseif (csid == EVENT.DATE) then
        local itemId = player:getLocalVar(LV_DATE_ITEM);
        if (itemId == 0) then
            return;
        end
        local genes = player:getLocalVar(LV_DATE_GENES);
        player:setLocalVar(LV_DATE_ITEM, 0);
        player:setVar(VAR_EGG_ITEM, itemId);
        player:setVar(VAR_EGG_GENES, genes);
        player:setVar(VAR_EGG_READY, nextJstMidnight());
        player:tradeComplete();
    elseif (csid == EVENT.EGG_LAID) then
        giveEgg(player);
    end
end

-----------------------------------
-- Hatching a bred egg at the trainer (LSB choco_data.lua: rollEggGender / rollEggAlleles / ability / seedEggStats)
-----------------------------------

-- Called from the trainer's onTrade: remembers a bred egg's genes (an unbred egg's exdata is all zero).
function CR.stashEgg(player, trade)
    player:setLocalVar(LV_BRED_FLAG, 0);
    player:setLocalVar(LV_BRED_GENES, 0);
    local item = trade:getItem(0);
    if (item == nil) then
        return;
    end
    local b = item:getExData();
    if (b ~= nil and b[4] >= 128) then
        player:setLocalVar(LV_BRED_FLAG, 1);
        player:setLocalVar(LV_BRED_GENES, b[1] + b[2] * 256); -- every gene sits in the low 16 bits
    end
end

-- Applies the stashed bred egg (if any) to a freshly rolled chocobo row.
function CR.applyBredEgg(player, choco)
    local bred = player:getLocalVar(LV_BRED_FLAG);
    local word = player:getLocalVar(LV_BRED_GENES);
    player:setLocalVar(LV_BRED_FLAG, 0);
    player:setLocalVar(LV_BRED_GENES, 0);
    if (bred ~= 1) then
        return;
    end

    local egg  = unpackGenes(word);
    local plan = egg.plan0 + 1;
    choco.allele1, choco.allele2, choco.allele3 = egg.dna[1], egg.dna[2], egg.dna[3];
    choco.color   = CR.allelesToColor(egg.dna);
    choco.ability1 = egg.ability;
    choco.sex     = (math.random(1, 100) <= (PLAN_MALE_CHANCE[plan] or 50)) and 0 or 1;
    local field = PLAN_STAT[plan];
    if (field ~= nil) then
        choco[field] = choco[field] + PLAN_STAT_SEED;
    end
end
