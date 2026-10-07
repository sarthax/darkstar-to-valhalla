-----------------------------------
-- Nyzul Isle Global
-----------------------------------
-- Ported from LandSandBoat's scripts/globals/nyzul.lua, adapted to this codebase's conventions
-- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
-- (tpz.* not xi.*, GetNPCByID/instance localvar API already identical). A practical slice, not a
-- full port -- see per-function notes below for what's included vs. left out.
--
-- FloorLayout and floorCost are carried over verbatim from LSB -- real reference coordinates/costs,
-- not invented here.
--
-- getTokenPenalty is ported verbatim from LSB (the formula is real, self-contained -- reads the
-- 'tokenPenalty' localvar, which defaults to 0 until pathos.lua's death-penalty effect is wired to
-- increment it, so this is a real no-op today, not a fabricated stand-in).
--
-- baseWeapons/vigilWeaponDrop/handleRunicKey are built below with real ids resolved against
-- item_weapon.sql. spawnChest/clearChests remain genuinely absent (armoury_crate.lua/
-- vending_box.lua cover the built temp-item chest mechanics instead -- see those files' headers).
--
-- Text messaging (WELCOME_TO_FLOOR, IN_OPERATION, INSUFFICIENT_TOKENS, OBJECTIVE_COMPLETE, etc.) is
-- wired in via Nyzul_Isle/IDs.lua's real, dat-extractor-confirmed ids. Only NEW_USER (the
-- first-time Runic Disc grant) remains unconfirmed -- see Rune_of_Transfer.lua's own TODO there.
-----------------------------------
require("scripts/globals/keyitems")
require("scripts/globals/nyzul/pathos")
require("scripts/zones/Nyzul_Isle/IDs")
require("scripts/globals/status")
-----------------------------------
tpz = tpz or {}
Nyzul = Nyzul or {}

-- Real per-job Vigil (floor-100 base weapon) drops -- LSB's own xi.nyzul.baseWeapons, item ids
-- resolved here against this codebase's own item_weapon.sql by internal name (not LSB's numbers) --
-- all 20 confirmed real, e.g. (18492,'sturdy_axe',...).
Nyzul.baseWeapons =
{
    [JOBS.WAR] = 18492, -- Sturdy Axe
    [JOBS.MNK] = 18753, -- Burning Fists
    [JOBS.WHM] = 18851, -- Werebuster
    [JOBS.BLM] = 18589, -- Mage's Staff
    [JOBS.RDM] = 17742, -- Vorpal Sword
    [JOBS.THF] = 18003, -- Swordbreaker
    [JOBS.PLD] = 17744, -- Brave Blade
    [JOBS.DRK] = 18944, -- Death Sickle
    [JOBS.BST] = 17956, -- Double Axe
    [JOBS.BRD] = 18034, -- Dancing Dagger
    [JOBS.RNG] = 18719, -- Killer Bow
    [JOBS.SAM] = 18443, -- Windslicer
    [JOBS.NIN] = 18426, -- Sasuke Katana
    [JOBS.DRG] = 18120, -- Radiant Lance
    [JOBS.SMN] = 18590, -- Scepter Staff
    [JOBS.BLU] = 17743, -- Wightslayer
    [JOBS.COR] = 18720, -- Quicksilver
    [JOBS.PUP] = 18754, -- Inferno Claws
    [JOBS.DNC] = 19102, -- Main Gauche
    [JOBS.SCH] = 18592, -- Elder Staff
}

Nyzul.objective =
{
    ELIMINATE_ENEMY_LEADER      = 1,
    ELIMINATE_SPECIFIED_ENEMIES = 2,
    ACTIVATE_ALL_LAMPS          = 3,
    ELIMINATE_SPECIFIED_ENEMY   = 4,
    ELIMINATE_ALL_ENEMIES       = 5,
    FREE_FLOOR                  = 6,
}

-- Real bug fix (2026-09-22, user-confirmed root cause): NyzulFloorProgress was a single flat charvar
-- with no mission-id qualifier, shared between Investigation (assault 51) and Uncharted (assault 52)
-- even though they're separate missions with separate Runic Disc progress -- clearing floor 60 in
-- one currently unlocks floor 60 access in the other, and Sorrowful Sage always reports whichever
-- mission wrote most recently, mislabeled. Fix per user's own direction ("create a new charvarname
-- based on the instance"): mission 51 keeps the literal "NyzulFloorProgress" name (no migration/reset
-- for existing live characters), every other assault id gets its own suffixed variant. Uncharted (52)
-- -> "NyzulFloorProgress52". Every read/write site below now goes through this helper instead of the
-- bare literal.
Nyzul.floorProgressVar = function(assaultId)
    if not assaultId or assaultId == 51 then
        return "NyzulFloorProgress"
    end
    return "NyzulFloorProgress" .. tostring(assaultId)
end

Nyzul.lampsObjective =
{
    REGISTER     = 1,
    ACTIVATE_ALL = 2,
    ORDER        = 3,
}

Nyzul.gearObjective =
{
    AVOID_AGRO     = 1,
    DO_NOT_DESTROY = 2,
}

Nyzul.penalty =
{
    TIME   = 1,
    TOKENS = 2,
    PATHOS = 3,
}

-- Human-readable names for Nyzul.objective, keyed the same way. Used only for the placeholder
-- PrintToPlayer feedback an unlit Rune of Transfer gives (see Rune_of_Transfer.lua) -- NOT a real
-- client text id (none of these are confirmed against our own dat-extractor cache).
Nyzul.objectiveName =
{
    [1] = "Eliminate the enemy leader.",
    [2] = "Eliminate the specified enemies.",
    [3] = "Activate all lamps.",
    [4] = "Eliminate the specified enemy.",
    [5] = "Eliminate all enemies.",
    [6] = "Free floor -- no objective.",
}

-- Real floor-layout coordinates, ported from LSB verbatim (see header note).
Nyzul.FloorLayout =
{
    [ 0] = {   -20, -0.5, -380 }, -- boss floors 20, 40, 60, 80
--  [ ?] = {  -491, -4.0, -500 }, -- boss floor 20 confirmed (LSB's own comment)
    [ 1] = {   380, -0.5, -500 },
    [ 2] = {   500, -0.5,  -20 },
    [ 3] = {   500, -0.5,   60 },
    [ 4] = {   500, -0.5, -100 },
    [ 5] = {   540, -0.5, -140 },
    [ 6] = {   460, -0.5, -219 },
    [ 7] = {   420, -0.5,  500 },
    [ 8] = {    60, -0.5, -335 },
    [ 9] = {    20, -0.5, -500 },
    [10] = {   -95, -0.5,   60 },
    [11] = {   100, -0.5,  100 },
    [12] = {  -460, -4.0, -180 },
    [13] = {  -304, -0.5, -380 },
    [14] = {  -380, -0.5, -500 },
    [15] = {  -459, -4.0, -540 },
    -- Layout 16 is the fixed layout for all boss floors (see nyzul_isle_investigation.lua's
    -- pickSetPoint), but this LSB-ported position placed the Rune of Transfer in the room adjacent
    -- to the actual large boss room, not inside it -- user-confirmed via live !logpos in the real room.
    [16] = {  -429.1022, 0.0000, -380.5669 },
    [17] = { 504.5,  0.0,  -60 },
}

-- Real per-floor gil cost / recommended level, ported from LSB verbatim.
Nyzul.floorCost =
{
    [ 1] = { level =  1, cost =    0 },
    [ 2] = { level =  6, cost =  500 },
    [ 3] = { level = 11, cost =  550 },
    [ 4] = { level = 16, cost =  600 },
    [ 5] = { level = 21, cost =  650 },
    [ 6] = { level = 26, cost =  700 },
    [ 7] = { level = 31, cost =  750 },
    [ 8] = { level = 36, cost =  800 },
    [ 9] = { level = 41, cost =  850 },
    [10] = { level = 46, cost =  900 },
    [11] = { level = 51, cost = 1000 },
    [12] = { level = 56, cost = 1100 },
    [13] = { level = 61, cost = 1200 },
    [14] = { level = 66, cost = 1300 },
    [15] = { level = 71, cost = 1400 },
    [16] = { level = 76, cost = 1500 },
    [17] = { level = 81, cost = 1600 },
    [18] = { level = 86, cost = 1700 },
    [19] = { level = 91, cost = 1800 },
    [20] = { level = 96, cost = 1900 },
}

local function getTokenRate(instance)
    local partySize = instance:getLocalVar("partySize")
    local rate = 1

    if partySize > 3 then
        rate = rate - (partySize - 3) * 0.1
    end

    return rate
end

local function calculateTokens(instance)
    local relativeFloor = Nyzul.getRelativeFloor(instance)
    local rate = getTokenRate(instance)
    local potentialTokens = instance:getLocalVar("potential_tokens")
    local floorBonus = 0

    if relativeFloor > 1 then
        floorBonus = 10 * math.floor((relativeFloor - 1) / 5)
    end

    return math.floor(potentialTokens + (200 + floorBonus) * rate)
end

Nyzul.getRelativeFloor = function(instance)
    local currentFloor = instance:getLocalVar("Nyzul_Current_Floor")
    local startingFloor = instance:getLocalVar("Nyzul_Isle_StartingFloor")

    if currentFloor < startingFloor then
        return currentFloor + 100
    end

    return currentFloor
end

-- Real floor-100 rewards -- ported from LSB's xi.nyzul.handleRunicKey/vigilWeaponDrop, adapted to
-- this codebase's real API (getCharVar/hasKeyItem/getPlayerByID -- confirmed real bindings; LSB's
-- entity:getVar/setVar don't exist here, and the global is lowercase getPlayerByID not
-- GetPlayerByID, though other scripts in this codebase call it capitalized -- kept consistent with
-- that existing usage, e.g. Uzhahn.lua). RUNIC_DISK_SAVE's "everyone can save" branch was already
-- the one chosen for Rune_of_Transfer.lua's Leave-Assault payout (iterates every player, not just
-- diskHolder) -- kept consistent here rather than reintroducing the other real historical variant.
Nyzul.handleRunicKey = function(mob)
    local instance = mob:getInstance()

    if instance:getLocalVar("Nyzul_Current_Floor") == 100 then
        local chars = instance:getChars()
        local startFloor = instance:getLocalVar("Nyzul_Isle_StartingFloor")

        -- Confirmed directly against real LSB source (nyzul.lua:180-208), which uses this exact
        -- per-player check: "Does players Runic Disk have data saved to a floor of entering or
        -- higher." NyzulFloorProgress is each player's OWN personally-saved disc floor (the highest
        -- floor THEY have individually climbed and saved to) -- this condition is the real anti-warp
        -- mechanic (per user: "a player must climb all the floors to get their progress recorded...
        -- skipping does not give them credit"). A player who never played has floorProgress=0, so a
        -- run starting at floor 96 fails this check for them even if the rest of the party
        -- qualifies. Kept LSB's RUNIC_DISK_SAVE=true branch (everyone who qualifies gets the key,
        -- not just diskHolder) -- this codebase's deliberate choice, no such setting exists here.
        for _, entity in pairs(chars) do
            local floorProgress = entity:getVar(Nyzul.floorProgressVar(entity:getCurrentAssault())) or 0
            if floorProgress + 1 >= startFloor and not entity:hasKeyItem(RUNIC_KEY) then
                npcUtil.giveKeyItem(entity, RUNIC_KEY)
            end
        end
    end
end

-- Real boss armor drop table -- per BG Wiki (Nyzul Isle Investigation), each floor 20/40/60/80/100
-- boss has a chance to drop one piece from 3 real 5-piece sets (Askar Korazin, Goliard Saio, Denali
-- Jacket), which piece determined by the FLOOR fought on, not the boss itself. LSB's own
-- scripts/mixins/nyzul_boss_drops.lua is a stub for this (every floor branch just calls
-- mob:setDropID(0)) -- not portable, built directly from the wiki's real item/floor mapping
-- instead. Item ids resolved by name against this codebase's own item_basic.sql (all 15 confirmed
-- real, e.g. 14568 'askar_korazin').
--
-- Rates are a deliberate house rule (user's explicit choice), not the wiki's own varying per-floor
-- percentages -- flat 20% per item / 60% combined / 40% no-drop, same odds on every boss floor.
-- Permille scale (addTreasure's own native scale) -- single mutually-exclusive roll per kill, not 3
-- independent per-set rolls.
Nyzul.bossArmorDrops =
{
    [ 20] = { { item = 15734, rate = 200 }, { item = 15733, rate = 200 }, { item = 15735, rate = 200 } }, -- Denali Gamashes / Askar Gambieras / Goliard Clogs
    [ 40] = { { item = 15648, rate = 200 }, { item = 15647, rate = 200 }, { item = 15649, rate = 200 } }, -- Denali Kecks / Askar Dirs / Goliard Trews
    [ 60] = { { item = 14984, rate = 200 }, { item = 14983, rate = 200 }, { item = 14985, rate = 200 } }, -- Denali Wristbands / Askar Manopolas / Goliard Cuffs
    [ 80] = { { item = 14569, rate = 200 }, { item = 14568, rate = 200 }, { item = 14570, rate = 200 } }, -- Denali Jacket / Askar Korazin / Goliard Saio
    [100] = { { item = 16107, rate = 200 }, { item = 16106, rate = 200 }, { item = 16108, rate = 200 } }, -- Denali Bonnet / Askar Zucchetto / Goliard Chapeau
}

-- Uncharted-only boss armor drops (item 5, 2026-09-23, user-directed): "these armor sets replace
-- the goliard/askar/denali armor drops" -- read as replacing them for Uncharted Area Survey
-- (assault 52) specifically, not globally, consistent with this whole build-out's standing
-- instance-52-only/no-Investigation-impact constraint (item 3). Nyzul.bossArmorDrops above is
-- left completely untouched, so Investigation's 6 boss scripts (Adamantoise/Behemoth/Cerberus/
-- Fafnir/Hydra/Khimaira -- all of which also call bossArmorDrop) keep their real, original
-- Denali/Askar/Goliard output. Same floor->slot mapping as that table (20=feet, 40=legs, 60=hands,
-- 80=body, 100=head), same flat 20%/20%/20% (60% combined) house-rule odds, tiered by floor per
-- the user's spec: 20=NQ, 40=+1, 60=+2, 80=+3, 100=the alternate HQ line (Thaumas/Phorcys/Nares,
-- not "+4" -- these are separate real items, not augments). All 30 item ids resolved by exact name
-- against this codebase's own item_basic (lsb_item_basic/topaz_item_basic, zero drift on any of
-- them) -- none invented.
Nyzul.unchartedBossArmorDrops =
{
    [ 20] = { { item = 10621, rate = 334 }, { item = 10616, rate = 333 }, { item = 10626, rate = 333 } }, -- Euxine Nails / Rheic Schuhs / Tethyan Clogs
    [ 40] = { { item = 10556, rate = 334 }, { item = 10551, rate = 333 }, { item = 10561, rate = 333 } }, -- Euxine Kecks +1 / Rheic Dirs +1 / Tethyan Trews +1
    [ 60] = { { item = 10526, rate = 334 }, { item = 10521, rate = 333 }, { item = 10531, rate = 333 } }, -- Euxine Gloves +2 / Rheic Mitts +2 / Tethyan Cuffs +2
    [ 80] = { { item = 10478, rate = 334 }, { item = 10473, rate = 333 }, { item = 10483, rate = 333 } }, -- Euxine Coat +3 / Rheic Korazin +3 / Tethyan Saio +3
    [100] = { { item = 10906, rate = 334 }, { item = 10901, rate = 333 }, { item = 10911, rate = 333 } }, -- Thaumas Hat / Phorcys Salade / Nares Cap
}

local function rollBossArmorDrop(player, mob, drops)
    local roll = math.random(1, 1000)
    local cumulative = 0
    for _, drop in ipairs(drops) do
        cumulative = cumulative + drop.rate
        if roll <= cumulative then
            player:addTreasure(drop.item, mob)
            return
        end
    end
end

-- Uncharted-only, 2026-09-23 (user-directed follow-up): once an item is selected above, grant it
-- 1-3 times instead of a flat 1 -- independent stacking rolls, not a single 1-in-3 pick: 1 is
-- guaranteed, then a 50% roll for a 2nd, then (only if the 2nd hit) a 25% roll for a 3rd. Scoped to
-- the new Uncharted table only, same as the rest of this armor system -- Investigation's original
-- bossArmorDrops output (still exactly 1 per kill) is untouched.
local function rollBossArmorDropStacked(player, mob, drops)
    -- 2026-09-26 (issue #2): the extra drops used to re-grant the SAME item (1-3 copies of one
    -- piece). Each extra now rolls again from the items NOT already dropped, so a stacked kill yields
    -- different pieces from the pool. Weighted by each item's own rate among the remaining items.
    local pool = {}
    for _, drop in ipairs(drops) do
        table.insert(pool, drop)
    end

    -- picks a drop from `pool` weighted by rate and removes it; nil if the pool is empty
    local function pickFromPool()
        local total = 0
        for _, drop in ipairs(pool) do
            total = total + drop.rate
        end
        if total <= 0 then
            return nil
        end
        local roll = math.random(1, total)
        local cumulative = 0
        for i, drop in ipairs(pool) do
            cumulative = cumulative + drop.rate
            if roll <= cumulative then
                table.remove(pool, i)
                return drop
            end
        end
        return nil
    end

    -- first item keeps the original single mutually-exclusive 1000-permille roll (60/40 odds unchanged)
    local roll = math.random(1, 1000)
    local cumulative = 0
    for _, drop in ipairs(drops) do
        cumulative = cumulative + drop.rate
        if roll <= cumulative then
            player:addTreasure(drop.item, mob)
            for i, d in ipairs(pool) do
                if d == drop then
                    table.remove(pool, i)
                    break
                end
            end
            -- 50% for a 2nd DIFFERENT item, then (only if the 2nd hit) 25% for a 3rd different one
            if math.random(1, 100) <= 50 then
                local second = pickFromPool()
                if second then
                    player:addTreasure(second.item, mob)
                    if math.random(1, 100) <= 25 then
                        local third = pickFromPool()
                        if third then
                            player:addTreasure(third.item, mob)
                        end
                    end
                end
            end
            return
        end
    end
end

Nyzul.bossArmorDrop = function(player, mob)
    if not player then
        return
    end

    local currentFloor = mob:getInstance():getLocalVar("Nyzul_Current_Floor")

    if player:getCurrentAssault() == 52 then
        local drops = Nyzul.unchartedBossArmorDrops[currentFloor]
        if drops then
            rollBossArmorDropStacked(player, mob, drops)
        end
        return
    end

    local drops = Nyzul.bossArmorDrops[currentFloor]
    if not drops then
        return
    end

    rollBossArmorDrop(player, mob, drops)
end

-- ENABLE_VIGIL_DROPS (LSB settings toggle) doesn't exist in this codebase -- omitted, the 20%
-- fodder-NM drop chance below always applies (real rate, LSB's own number).
Nyzul.vigilWeaponDrop = function(player, mob)
    if not player then
        return
    end

    local instance = mob:getInstance()

    if instance:getLocalVar("Nyzul_Current_Floor") == 100 then
        local diskHolder = GetPlayerByID(instance:getLocalVar("diskHolder"))
        local chars = instance:getChars()

        -- Real crash fixed: Nyzul.baseWeapons only covers jobs 1-20 (WAR..SCH); JOB_GEO (21)
        -- and JOB_RUN (22) have no entry, so a nil itemID reached hasItem's required uint16
        -- parameter whenever the Runic Disc holder was GEO/RUN. Matches the wiki's own documented
        -- special case: "for GEO/RUN (who have no vigil weapon) both are random" -- the
        -- unconditional random drop below already covers that; this job-matched branch just needs
        -- to skip cleanly when there's no matching weapon.
        local diskHolderWeapon = diskHolder ~= nil and Nyzul.baseWeapons[diskHolder:getMainJob()]
        if diskHolderWeapon then
            for _, entity in pairs(chars) do
                if not entity:hasItem(diskHolderWeapon) then
                    player:addTreasure(diskHolderWeapon, mob)
                    break
                end
            end
        end

        player:addTreasure(Nyzul.baseWeapons[math.random(1, #Nyzul.baseWeapons)], mob)
    -- User-confirmed wiki text: "All the HNM bosses every twenty floors will always drop one random
    -- weapon" -- a DIFFERENT, guaranteed mechanic from the regular per-floor Notorious Monsters'
    -- real 20% chance ("Notorious Monsters also have a chance of dropping one of the 20 Vigil
    -- Weapons"). This shared function is called from both populations (every boss's onMobDeath, and
    -- other real NM kills elsewhere), so floor % 20 == 0 (20/40/60/80 -- 100 handled separately
    -- above) distinguishes an every-20th-floor HNM boss kill from a regular floor NM kill without
    -- needing to know which specific mob called it.
    elseif instance:getLocalVar("Nyzul_Current_Floor") > 0 and instance:getLocalVar("Nyzul_Current_Floor") % 20 == 0 then
        player:addTreasure(Nyzul.baseWeapons[math.random(1, #Nyzul.baseWeapons)], mob)
    elseif math.random(1, 100) <= 20 then
        player:addTreasure(Nyzul.baseWeapons[math.random(1, #Nyzul.baseWeapons)], mob)
    end
end

-- Ported verbatim from LSB. floorPenalities (real spelling, kept as-is) reads the 'tokenPenalty'
-- localvar -- currently always 0 here since nothing increments it yet (that's pathos.lua's
-- death-penalty effect, not wired to this localvar in this port), so this is a real formula
-- returning a real 0 today, not a fabricated stand-in.
Nyzul.getTokenPenalty = function(instance)
    local floorPenalities = instance:getLocalVar("tokenPenalty")
    local rate = getTokenRate(instance)

    return math.floor(117 * rate * floorPenalities)
end

-- Called from instance_object.onInstanceProgressUpdate. Returns true once the current floor's
-- objective is satisfied (caller is then responsible for activating the Rune of Transfer).
--
-- Runic Disc progress-saving happens here (every real floor clear) rather than tied to the "Exit
-- the Assault" menu choice -- confirmed via a real map-server packet capture that that choice is
-- handled entirely client-side (a native zone-leave packet) and never reaches any Lua hook. The
-- wiki doesn't require it to be exit-specific either: "If the party exits before clearing the fifth
-- level... eligible party members will still be recorded to that last floor" -- progress is really
-- tied to clearing floors, not to how the run ends.
Nyzul.handleProgress = function(instance, progress)
    local stage = instance:getStage()
    local isComplete = false

    if
        ((stage == Nyzul.objective.FREE_FLOOR or
        stage == Nyzul.objective.ELIMINATE_ENEMY_LEADER or
        stage == Nyzul.objective.ACTIVATE_ALL_LAMPS or
        stage == Nyzul.objective.ELIMINATE_SPECIFIED_ENEMY) and
        progress == 15)
        or
        ((stage == Nyzul.objective.ELIMINATE_ALL_ENEMIES or stage == Nyzul.objective.ELIMINATE_SPECIFIED_ENEMIES) and
        progress >= instance:getLocalVar("Eliminate"))
    then
        local clearedFloor = instance:getLocalVar("Nyzul_Current_Floor")
        if clearedFloor and clearedFloor > 0 then
            -- Real eligibility gate matching Rune_of_Transfer.lua's exit-path. Per the wiki (Runic
            -- Disc): "to be eligible, your own disc's progress must be at least up to the previous
            -- fifth floor ... if your party started on floor 41 ... but your own disc's progress
            -- was only up to floor 20, no progress will be saved to your disc." Without this, every
            -- floor clear gave every party member free credit regardless of their own disc's real
            -- eligibility.
            local startFloor = instance:getLocalVar("Nyzul_Isle_StartingFloor")
            for _, player in pairs(instance:getChars()) do
                local progressVar = Nyzul.floorProgressVar(player:getCurrentAssault())
                local currentProgress = player:getVar(progressVar) or 0
                if (currentProgress + 1) >= startFloor and clearedFloor > currentProgress then
                    player:setVar(progressVar, clearedFloor)
                    -- Real 2-param bug found via live-test screenshots: dialog table entry 7483 is
                    -- "Data up to and including Floor <Numeric Parameter 1> has been recorded on
                    -- your <item name, Special Code substitution reading Numeric Parameter 0>"
                    -- (confirmed against our own client's real dialog_text dump). Only one param
                    -- was ever passed (into slot 0), so the client read the raw floor number as a
                    -- KEY ITEM id for the substitution slot -- confirmed mechanically: floor 9
                    -- rendered "airship pass for Kazham" (AIRSHIP_PASS_FOR_KAZHAM = 9)
                    -- and floor 10 rendered "overdue book notification" (=10), an exact enum-value
                    -- match. Fixed: RUNIC_DISC's real key item id in slot 0, real floor in slot 1.
                    player:messageSpecial(NyzulIsle.text.RUNE_FLOOR_RECORD, RUNIC_DISC, clearedFloor)
                end
            end
        end

        instance:setProgress(0)
        instance:setLocalVar("Eliminate", 0)
        instance:setLocalVar("potential_tokens", calculateTokens(instance))

        -- Real text id confirmed via a decompiled client dialog-table dump (Dialog Table Entry
        -- 7348: "Floor <N> objective complete. Rune of Transfer activated."). messageText (used
        -- elsewhere in this port) has no numeric-param substitution support in this codebase's real
        -- binding -- messageSpecial does, so that's used here to fill in the real cleared floor.
        if clearedFloor and clearedFloor > 0 then
            for _, player in pairs(instance:getChars()) do
                player:messageSpecial(NyzulIsle.text.OBJECTIVE_COMPLETE, clearedFloor)
            end
        end

        -- Real mechanic per the wiki -- "occasionally the choice will be given to go either left or
        -- right when moving on to the next floor. One of these choices will effectively unleash a
        -- Pathos on the next floor." The real CSID/option encoding for that choice is confirmed
        -- (Rune_of_Transfer.lua's advanceToNextFloor -- csid 201's slot0=27 "left/right" variant,
        -- options 3/4) and wired.
        -- 2026-09-12, user-requested: this per-floor roll and the real left/right rune-choice roll
        -- are now two INDEPENDENT systems that both queue via `Nyzul.queuePathos()` -- both can
        -- land on the same floor and stack as two distinct effects (queuePathos itself excludes
        -- whatever's already active/queued, so the same effect never gets picked twice). The 30%
        -- roll rate is still NOT a confirmed retail number.
        if math.random(1, 100) <= 30 then
            Nyzul.queuePathos(instance)
        end

        isComplete = true
    end

    return isComplete
end

-- Corrected against the real BG Wiki page (Nyzul Isle Investigation) -- the Rune of Transfer is
-- always present/examinable (status NORMAL, set by instance_object.pickSetPoint); only its
-- animationsub (unlit -> lit) changes here once the floor's objective is won.
Nyzul.activateRuneOfTransfer = function(instance)
    local rune = instance:getEntity(bit.band(NyzulIsle.npcs.RUNE_OF_TRANSFER_OFFSET, 0xFFF), TYPE_NPC)
    if rune then
        rune:AnimationSub(1)
        -- 2026-09-15, real bug found live: AnimationSub()'s own broadcast only reaches players
        -- already within 50y (CHAR_INRANGE) -- a party member who was out of range when the
        -- objective completed, or who leaves and re-enters range afterward, never gets this update
        -- and sees the rune as still unlit. updateAnimationSub() (new C++ binding, see
        -- lua_baseentity.cpp) re-broadcasts the CURRENT value to the whole instance instead.
        rune:updateAnimationSub()
    end
end

-- Real mechanic per the wiki -- "Upon defeat of one of these NMs, it will drop an Armoury
-- Crate...100% of the time, and opening one will bestow a ??? Item that can be appraised." The real
-- ???-item/appraisal side is NOT built (see armoury_crate.lua's own header -- Topaz's
-- scripts/globals/appraisal.lua is an architecturally different, trade-to-NPC system, and building
-- LSB's auto-appraise model would mean either a parallel subsystem or a fabricated origin/item
-- mapping). What IS real and buildable: the crate actually appearing on a real NM kill. Reuses the
-- existing temp-item Armoury Crate (blue/gold, not the wiki's real brown/gold NM variant -- a real,
-- disclosed simplification) since that's the only crate mechanic actually built.
-- Real bug fix: this always targeted the SAME crate npc (ARMOURY_CRATE_OFFSET, slot 1 of the real
-- 3-crate pool this zone already uses for Free Floor), so two near-simultaneous kills (e.g. a
-- random floor NM and the Enemy Leader) would reposition/respawn that one entity twice, despawning
-- the first crate before it could be opened. Now picks any pool slot that isn't currently active,
-- using the same real NORMAL(visible/lootable)/CUTSCENE_ONLY(dormant, tempBoxFinish's own depletion
-- timer restores this) status signal Free Floor's spawn/despawn functions already use to track slot
-- availability. Falls back to slot 1 (old behavior) only if all 3 pool slots are genuinely busy.
local function findFreeCrateSlot(instance)
    for i = NyzulIsle.npcs.ARMOURY_CRATE_OFFSET, NyzulIsle.npcs.ARMOURY_CRATE_OFFSET + 2 do
        local crate = instance:getEntity(bit.band(i, 0xFFF), TYPE_NPC)
        if crate and crate:getStatus() ~= STATUS_NORMAL then
            return crate
        end
    end
    return instance:getEntity(bit.band(NyzulIsle.npcs.ARMOURY_CRATE_OFFSET, 0xFFF), TYPE_NPC)
end

local function dropArmouryCrate(mob)
    local instance = mob:getInstance()
    local crate = findFreeCrateSlot(instance)
    if crate then
        local pos = mob:getPos()
        crate:resetLocalVars()
        crate:AnimationSub(0)
        crate:setPos(pos.x, pos.y, pos.z)
        crate:setStatus(STATUS_NORMAL)
        crate:forceRespawn()
    end
end

-- Mob-kill hooks -- call these from each floor mob's onMobDeath.
Nyzul.enemyLeaderKill = function(mob)
    local instance = mob:getInstance()
    -- Stage guard added (LSB's own version doesn't have one either, but this codebase shares
    -- Imp.lua's onMobDeath across every real Imp group in the zone, including Path of Darkness's
    -- own unrelated ones -- a leader mob dying on the wrong objective/instance should never
    -- complete it).
    if instance:getStage() == Nyzul.objective.ELIMINATE_ENEMY_LEADER then
        instance:setProgress(15)
        dropArmouryCrate(mob)
    end
end

-- Real random floor NM pool (BG Wiki/FFXIclopedia: "Notorious Monsters...summoned by the archaic
-- ramparts...Upon defeat...it will drop an Armoury Crate...100% of the time"). Fires for every one
-- of these NMs regardless of the active stage (per the wiki: "it is never required for one or all
-- of these NMs to be defeated" unless the objective IS eliminate-all-enemies) -- only contributes to
-- the Eliminate counter when that's the active stage, same treatment as eliminateAllKill.
-- vigilWeaponDrop's own 20%-non-floor-100 branch already covers "chance of dropping one of the
-- Nyzul Weapons" for these NMs.
Nyzul.floorNMKill = function(mob, player)
    local instance = mob:getInstance()

    dropArmouryCrate(mob)
    Nyzul.vigilWeaponDrop(player, mob)

    if instance:getStage() == Nyzul.objective.ELIMINATE_ALL_ENEMIES then
        instance:setProgress(instance:getProgress() + 1)
    end
end

-- Uncharted-only per-NM drop table (2026-09-22, user-directed). Nyzul.floorNMKill/vigilWeaponDrop
-- above are completely untouched -- this is purely additive. Reuses the SAME real, pre-existing
-- 90-NM floor pool (ID.mob[51].NM_EVEN/NM_ODD, mob_spawn_points 17092824-17092913, zone 77) that
-- both missions already share, but gives Uncharted's own kills a chance at that NM's own real
-- canonical drop from its native (non-Nyzul) zone/encounter, instead of Investigation's generic
-- Vigil-weapon roll. Every item id below was resolved by real name via id_bridge.py against this
-- codebase's own item_basic.sql (not guessed/invented) -- sourced from each NM's own real BG Wiki
-- page Treasure table (preferring a vcdrop/rdrop/cdrop-tagged entry, i.e. that NM's own signature
-- item, over shared trash-drop materials). 20% rate is a deliberate house rule matching
-- vigilWeaponDrop's own existing 20% fodder-NM rate, not a wiki-sourced number.
--
-- 3 of the 90 pool's real names have NO confirmed drop anywhere -- their own BG Wiki pages are
-- tagged "Information Needed" (Leech_King, Nunyenunc) or the pool's "Vouivre" doesn't match any real
-- BG Wiki NM page at all (only unrelated companion mobs "Andras's Vouivre"/"Caim's Vouivre" exist,
-- neither is this NM) -- left OUT of this table deliberately rather than fabricated; those 3 names
-- fall through to the armoury-crate-only branch below (still 100% crate, no chance item) until/unless
-- a real source is found.
Nyzul.unchartedNMDrops = {
    ["Aiatar"] = { item = 15367, rate = 20 }, -- Falconer's Hose
    ["Amikiri"] = { item = 16968, rate = 20 }, -- Kamewari
    ["Aquarius"] = { item = 17925, rate = 20 }, -- Fransisca
    ["Argus"] = { item = 939, rate = 20 }, -- Hecteyes Eye
    ["Asphyxiated_Amsel"] = { item = 13512, rate = 20 }, -- Malgust Ring
    ["Bat_Eye"] = { item = 557, rate = 20 }, -- Ahriman Lens
    ["Bloodpool_Vorax"] = { item = 13058, rate = 20 }, -- Bloodbead Amulet
    ["Bloodsucker"] = { item = 13302, rate = 20 }, -- Bloodbead Ring
    ["Bloodtear_Baldurf"] = { item = 910, rate = 20 }, -- Lumbering Horn
    ["Bomb_King"] = { item = 17316, rate = 20 }, -- Bomb Arm
    ["Bonnacon"] = { item = 15323, rate = 20 }, -- Cure Clogs
    ["Buburimboo"] = { item = 13057, rate = 20 }, -- Buburimu Gorget
    ["Burned_Bergmann"] = { item = 13510, rate = 20 }, -- Malflame Ring
    ["Cactuar_Cantautor"] = { item = 14128, rate = 20 }, -- Kung Fu Shoes
    ["Capricious_Cassie"] = { item = 13978, rate = 20 }, -- Aiming Bracelets
    ["Cargo_Crab_Colin"] = { item = 881, rate = 20 }, -- Crab Shell
    ["Carnero"] = { item = 17811, rate = 20 }, -- Katayama Ichimonji
    ["Crushed_Krause"] = { item = 13508, rate = 20 }, -- Maldust Ring
    ["Daggerclaw_Dracos"] = { item = 853, rate = 20 }, -- Raptor Skin
    ["Drooling_Daisy"] = { item = 13838, rate = 20 }, -- Dodge Headband
    ["Dune_Widow"] = { item = 13137, rate = 20 }, -- Spider Torque
    ["Eastern_Shadow"] = { item = 18714, rate = 20 }, -- Vali's Bow
    ["Ellyllon"] = { item = 4386, rate = 20 }, -- King Truffle
    ["Emergent_Elm"] = { item = 15701, rate = 20 }, -- Arborist Nails
    ["Energetic_Eruca"] = { item = 18584, rate = 20 }, -- Astral Staff
    ["Falcatus_Aranei"] = { item = 18040, rate = 20 }, -- Webcutter
    ["Fraelissa"] = { item = 17211, rate = 20 }, -- Almogavar Bow
    ["Friar_Rush"] = { item = 18139, rate = 20 }, -- Bomb Core
    ["Frostmane"] = { item = 16944, rate = 20 }, -- Lockheart
    ["Fungus_Beetle"] = { item = 12371, rate = 20 }, -- Clipeus
    ["Gargantua"] = { item = 13115, rate = 20 }, -- Elemental Charm
    ["Golden_Bat"] = { item = 13576, rate = 20 }, -- Night Cape
    ["Gyre-Carlin"] = { item = 14866, rate = 20 }, -- Concealing Cuffs
    ["Helldiver"] = { item = 17281, rate = 20 }, -- Wingedge
    ["Hellion"] = { item = 18041, rate = 20 }, -- A l'Outrance
    ["Intulo"] = { item = 14759, rate = 20 }, -- Curaga Earring
    ["Jaded_Jody"] = { item = 15613, rate = 20 }, -- Jet Seraweels
    ["Jaggedy-Eared_Jack"] = { item = 13112, rate = 20 }, -- Rabbit Charm
    ["Jolly_Green"] = { item = 13228, rate = 20 }, -- Shaman's Belt
    ["Juggler_Hecatomb"] = { item = 16868, rate = 20 }, -- Heavy Halberd
    ["Keeper_of_Halidom"] = { item = 16990, rate = 20 }, -- Daihannya
    ["Leaping_Lizzy"] = { item = 15351, rate = 20 }, -- Bounding Boots
    ["Maighdean_Uaine"] = { item = 14803, rate = 20 }, -- Optical Earring
    ["Mischievous_Micholas"] = { item = 17618, rate = 20 }, -- Kidney Dagger
    ["Nightmare_Vase"] = { item = 16913, rate = 20 }, -- Shinogi
    ["Northern_Shadow"] = { item = 16723, rate = 20 }, -- Executioner
    ["Odqan"] = { item = 14658, rate = 20 }, -- Atlaua's Ring
    ["Old_Two-Wings"] = { item = 13598, rate = 20 }, -- Bat Cape
    ["Orctrap"] = { item = 15291, rate = 20 }, -- Hojutsu Belt
    ["Panzer_Percival"] = { item = 16714, rate = 20 }, -- Neckchopper
    ["Peallaidh"] = { item = 14946, rate = 20 }, -- Nightmare Gloves
    ["Peg_Powler"] = { item = 16728, rate = 20 }, -- Schwarz Axt
    ["Pelican"] = { item = 12382, rate = 20 }, -- Astral Aspis
    ["Pulverized_Pfeffer"] = { item = 13509, rate = 20 }, -- Malfrost Ring
    ["Roc"] = { item = 4799, rate = 20 }, -- Scroll of Stonega III
    ["Sabotender_Bailarin"] = { item = 14168, rate = 20 }, -- Dune Boots
    ["Sabotender_Mariachi"] = { item = 17981, rate = 20 }, -- Bano del Sol
    ["Serket"] = { item = 13552, rate = 20 }, -- Serket Ring
    ["Serpopard_Ishtar"] = { item = 13086, rate = 20 }, -- Cerulean Pendant
    ["Sewer_Syrup"] = { item = 13303, rate = 20 }, -- Jelly Ring
    ["Shadow_Eye"] = { item = 13114, rate = 20 }, -- Moon Amulet
    ["Sharp-Eared_Ropipi"] = { item = 15218, rate = 20 }, -- Entrancing Ribbon
    ["Simurgh"] = { item = 15736, rate = 20 }, -- Trotter Boots
    ["Smothered_Schmidt"] = { item = 13507, rate = 20 }, -- Malflood Ring
    ["Southern_Shadow"] = { item = 12344, rate = 20 }, -- Master Shield
    ["Spiny_Spipi"] = { item = 13607, rate = 20 }, -- Mist Silk Cape
    ["Steelfleece_Baldarich"] = { item = 911, rate = 20 }, -- Rampaging Horn
    ["Stinging_Sophie"] = { item = 16486, rate = 20 }, -- Beestinger
    ["Stray_Mary"] = { item = 17366, rate = 20 }, -- Mary's Horn
    ["Swamfisk"] = { item = 17594, rate = 20 }, -- Gelong Staff
    ["Taisaijin"] = { item = 15222, rate = 20 }, -- Spelunker's Hat
    ["Tom_Tit_Tat"] = { item = 16443, rate = 20 }, -- Fruit Punches
    ["Tottering_Toby"] = { item = 13013, rate = 20 }, -- Stumbling Sandals
    ["Trickster_Kinetix"] = { item = 16657, rate = 20 }, -- Tabar
    ["Tumbling_Truffle"] = { item = 12485, rate = 20 }, -- Fungus Hat
    ["Tyrannic_Tunnok"] = { item = 17927, rate = 20 }, -- Lohar
    ["Ungur"] = { item = 18141, rate = 20 }, -- Ungur Boomerang
    ["Unut"] = { item = 14287, rate = 20 }, -- Luna Subligar
    ["Valkurm_Emperor"] = { item = 15224, rate = 20 }, -- Empress Hairpin
    ["Western_Shadow"] = { item = 18752, rate = 20 }, -- Retaliators
    ["Wounded_Wurfel"] = { item = 13511, rate = 20 }, -- Malflash Ring
    ["Zizzy_Zillah"] = { item = 14945, rate = 20 }, -- Fencing Bracers
}

Nyzul.unchartedFloorNMDrop = function(player, mob)
    if not player then
        return
    end

    local drop = Nyzul.unchartedNMDrops[mob:getName()]
    if drop and math.random(1, 100) <= drop.rate then
        player:addTreasure(drop.item, mob)
    end
end

-- Dispatcher for the 90 shared floor-NM mob scripts (each currently calls Nyzul.floorNMKill
-- directly). Branches purely on the killing player's own active assault id: assault 52 (Uncharted)
-- gets the per-NM drop table above; every other caller (assault 51 Investigation, or anything else
-- that reuses these mob scripts/ids) falls through to the ORIGINAL, completely unmodified
-- floorNMKill/vigilWeaponDrop behavior -- so Investigation's real output is provably unchanged.
Nyzul.floorNMKillShared = function(mob, player)
    if player and player:getCurrentAssault() == 52 then
        local instance = mob:getInstance()

        dropArmouryCrate(mob)
        Nyzul.unchartedFloorNMDrop(player, mob)
        Nyzul.unchartedAlexandriteDrop(player, mob)

        if instance:getStage() == Nyzul.objective.ELIMINATE_ALL_ENEMIES then
            instance:setProgress(instance:getProgress() + 1)
        end
    else
        Nyzul.floorNMKill(mob, player)
    end
end

-- Alexandrite (item 3, 2026-09-23, user-directed): non-boss-floor NM kills in Uncharted Area
-- Survey (assault 52 only) have a chance to drop one Piece of Alexandrite, in addition to any
-- other existing drop (Armoury Crate, Vigil weapon, per-NM signature item from unchartedNMDrops).
-- Real item id 2488 ("piece_of_alexandrite") resolved via id_bridge.py -- no drift between
-- LSB/Topaz. 20% rate is a house rule (no wiki-published number), matching the existing
-- unchartedNMDrops/vigilWeaponDrop 20% convention. Callers are responsible for their own
-- assault==52 gate; this function does not check it itself -- every caller already does
-- (floorNMKillShared's uncharted branch below, already assault-gated; and the 19 leaderPool NM
-- scripts, which are instance-52-exclusive mob_pools/ids by construction, see
-- nyzul_isle_uncharted_area_survey.lua header note 1).
local ALEXANDRITE_ITEM = 2488
Nyzul.unchartedAlexandriteDrop = function(player, mob)
    if player and math.random(1, 100) <= 20 then
        player:addTreasure(ALEXANDRITE_ITEM, mob)
    end
end

-- Coin Purse boss drops (item 3, 2026-09-23, user-directed): the floor 20/40/60 bosses
-- (Stealthlord Haraal Ja/Dabargar the Stoic/Stheno) have a ~25% chance to drop a Cotton Coin
-- Purse; Lord Vryko (floor 80) always drops one; Dvali Jonah (floor 100) always drops a Linen
-- Coin Purse instead. Real item ids 5735 ("cotton_coin_purse")/5736 ("linen_coin_purse")
-- resolved via id_bridge.py -- no drift between LSB/Topaz. These 5 boss scripts are
-- instance-52-exclusive by construction (see nyzul_isle_uncharted_area_survey.lua header note 2:
-- their mob_pools/mob_groups/mob_spawn_points ids don't exist in Investigation at all), so no
-- assault gate is needed here.
local COTTON_COIN_PURSE_ITEM = 5735
local LINEN_COIN_PURSE_ITEM = 5736

Nyzul.unchartedTierBossCoinPurseDrop = function(player, mob)
    if player and math.random(1, 100) <= 25 then
        player:addTreasure(COTTON_COIN_PURSE_ITEM, mob)
    end
end

Nyzul.unchartedVrykoCoinPurseDrop = function(player, mob)
    if player then
        player:addTreasure(COTTON_COIN_PURSE_ITEM, mob)
    end
end

Nyzul.unchartedJonahCoinPurseDrop = function(player, mob)
    if player then
        player:addTreasure(LINEN_COIN_PURSE_ITEM, mob)
    end
end

-- Astraria fragment/redemption system (item 2/5, 2026-09-23, user-directed): the 5 Uncharted
-- boss floors (20/40/60/80/100) each build toward one of 5 real key items -- BRONZE/SILVER/
-- DSP-PORT-TODO: unmapped tpz.* reference -- see data/dsp_namespace_map.json
-- MYTHRIL/GOLD/PLATINUM_ASTRARIUM (tpz.ki ids 2068-2072, scripts/globals/keyitems.lua, zero
-- LSB/Topaz drift, and independently corroborated by Berangere's own real client event-data
-- array in this session's Aht_Urhgan_Whitegate mission_toolkit pull). Per user spec: a per-tier
-- char_var tracks fragments 0..5 (0..1 for Platinum only); on the 5th fragment (1st for
-- Platinum) the real key item is auto-granted and the char_var resets to 0; while the player
-- already holds that tier's key item, further boss kills can still tick the char_var up toward
-- maxFragments-1 (banking progress on the *next* one) but can never complete it -- the final
-- fragment is refused with a "you already possess this astrarium" message (exact wording is
-- the user's own spec text, not a captured client string) until the held key item is redeemed
-- at Berangere, which explicitly resets the char_var back to 0 (see Berangere.lua). This mirrors
-- bossArmorDrop's own floor->tier dispatch below since these are the same 5 boss scripts.
-- FIXED 2026-09-24: the original charvar names (e.g. "UnchartedAstrariumBronzeFragments", 34 chars)
-- all exceeded char_vars.varname's varchar(30) column limit (sql/char_vars.sql:31), so every
-- setCharVar() fragment write for every tier was silently failing (confirmed via live map-server
-- "[SQL] DB error - Data too long for column 'varname'" while testing !astraria bronze set 3, which
-- then read back as fragments=0). Renamed to fit under 30 chars; no numeric/content IDs involved, so
-- this is a safe internal rename, not a fabricated id.
Nyzul.astraria =
{
    BRONZE   = { charvar = "AstrariaFragBronze",   ki = BRONZE_ASTRARIUM,   maxFragments = 5, name = "bronze astrarium" },
    SILVER   = { charvar = "AstrariaFragSilver",   ki = SILVER_ASTRARIUM,   maxFragments = 5, name = "silver astrarium" },
    MYTHRIL  = { charvar = "AstrariaFragMythril",  ki = MYTHRIL_ASTRARIUM,  maxFragments = 5, name = "mythril astrarium" },
    GOLD     = { charvar = "AstrariaFragGold",     ki = GOLD_ASTRARIUM,     maxFragments = 5, name = "gold astrarium" },
    PLATINUM = { charvar = "AstrariaFragPlatinum", ki = PLATINUM_ASTRARIUM, maxFragments = 1, name = "platinum astrarium" },
}

local unchartedFloorToAstrariaTier =
{
    [ 20] = "BRONZE",
    [ 40] = "SILVER",
    [ 60] = "MYTHRIL",
    [ 80] = "GOLD",
    [100] = "PLATINUM",
}

Nyzul.unchartedAstrariaFragmentGain = function(player, mob)
    if not player or player:getCurrentAssault() ~= 52 then
        return
    end

    local currentFloor = mob:getInstance():getLocalVar("Nyzul_Current_Floor")
    local tier = unchartedFloorToAstrariaTier[currentFloor]
    if not tier then
        return
    end

    local data = Nyzul.astraria[tier]

    if player:hasKeyItem(data.ki) then
        if data.maxFragments > 1 then
            local fragments = player:getVar(data.charvar)
            if fragments < data.maxFragments - 1 then
                fragments = fragments + 1
                player:setVar(data.charvar, fragments)
                player:PrintToPlayer(string.format("You obtain a fragment of the %s. (%u/%u)", data.name, fragments, data.maxFragments))
                return
            end
        end
        player:PrintToPlayer(string.format("You already possess this astrarium. Unable to obtain additional parts."))
        return
    end

    local fragments = player:getVar(data.charvar) + 1

    if fragments >= data.maxFragments then
        player:setVar(data.charvar, 0)
        player:addKeyItem(data.ki)
        player:messageSpecial(zones[player:getZoneID()].text.KEYITEM_OBTAINED, data.ki)
    else
        player:setVar(data.charvar, fragments)
        player:PrintToPlayer(string.format("You obtain a fragment of the %s. (%u/%u)", data.name, fragments, data.maxFragments))
    end
end

-- Called from Berangere.lua on a successful redemption -- resets fragment progress to 0 per
-- user spec ("Once that particular astrarium is removed by redeeming, fragment char_var is
-- reset to 0"), discarding any fragments banked toward the next one while the KI was held.
Nyzul.unchartedAstrariaRedeem = function(player, tier)
    local data = Nyzul.astraria[tier]
    if not data or not player:hasKeyItem(data.ki) then
        return false
    end

    player:delKeyItem(data.ki)
    player:setVar(data.charvar, 0)
    return true
end

Nyzul.specifiedGroupKill = function(mob)
    local instance = mob:getInstance()
    if instance:getStage() == Nyzul.objective.ELIMINATE_SPECIFIED_ENEMIES then
        instance:setProgress(instance:getProgress() + 1)
    end
end

Nyzul.specifiedEnemySet = function(mob)
    local instance = mob:getInstance()
    local targetId = instance:getLocalVar("Nyzul_Specified_Enemy")

    -- DSP-PORT-TODO: tpz\.mobMod\.CHECK_AS_NM -- see data/dsp_namespace_map.json
    mob:setMobMod(MOBMOD_CHECK_AS_NM, 0)

    if
        instance:getStage() == Nyzul.objective.ELIMINATE_SPECIFIED_ENEMY and
        targetId ~= 0 and
        mob:getID() == targetId
    then
        -- DSP-PORT-TODO: tpz\.mobMod\.CHECK_AS_NM -- see data/dsp_namespace_map.json
        mob:setMobMod(MOBMOD_CHECK_AS_NM, 1)
    end
end

-- Real fix -- user-reported live: got the Floor Complete message twice after killing monsters on an
-- "Eliminate All Enemies" floor. Root cause: this function's own ELIMINATE_ALL_ENEMIES branch was a
-- duplicate of Nyzul.eliminateAllKill, which every ELIMINATE_ALL_ENEMIES trash mob's onMobDeath
-- already calls separately (e.g. Greatclaw.lua calls both eliminateAllKill(mob) AND
-- specifiedEnemyKill(mob) on the same kill) -- so every kill incremented progress TWICE. That
-- double-increment can cross the completion threshold twice within one kill event: the first
-- increment completes the floor and resets progress/Eliminate to 0 synchronously, then the second
-- increment (same onMobDeath call) reads the freshly-reset Eliminate=0, satisfies
-- progress>=Eliminate again, and fires the completion message a second time. specifiedEnemyKill
-- should only ever touch its own real stage (ELIMINATE_SPECIFIED_ENEMY) -- ELIMINATE_ALL_ENEMIES is
-- eliminateAllKill's job alone.
Nyzul.specifiedEnemyKill = function(mob)
    local instance = mob:getInstance()
    local stage = instance:getStage()

    if stage == Nyzul.objective.ELIMINATE_SPECIFIED_ENEMY then
        if instance:getLocalVar("Nyzul_Specified_Enemy") == mob:getID() then
            instance:setProgress(15)
            instance:setLocalVar("Nyzul_Specified_Enemy", 0)
        end
    end
end

Nyzul.eliminateAllKill = function(mob)
    local instance = mob:getInstance()
    if instance:getStage() == Nyzul.objective.ELIMINATE_ALL_ENEMIES then
        instance:setProgress(instance:getProgress() + 1)
    end
end

return Nyzul
