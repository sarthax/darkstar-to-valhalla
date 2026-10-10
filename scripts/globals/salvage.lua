-----------------------------------
-- Salvage Global Functions
-----------------------------------
-- 2026-09-05/06: backporting from LandSandBoat (LSB). Zone-SPECIFIC mechanics (instance
-- registration/failure, door-open/floor-progression sequencing, wave-clear tracking) are NOT
-- centralized here -- confirmed against Topaz's own real, already-working Arrapago Remnants
-- implementation (instances/arrapago_remnants.lua) that Topaz's established convention puts those
-- inline per zone instance script, not in a shared LSB-style salvageUtil helper. This file stays
-- scoped to mechanics confirmed genuinely zone-independent: player status effects (cell items),
-- and the temp-chest drop-loot mechanic (spawnTempChest/tempBoxTrigger/tempBoxPickItems/
-- tempBoxFinish, added 2026-09-06 -- confirmed not yet wired up in EITHER zone by checking
-- Arrapago's own real trash mob scripts, so this is genuinely new functionality, not something
-- zone-specific being wrongly centralized). Bhaflau Remnants now has real ids/positions from
-- captures (see scripts/zones/Bhaflau_Remnants/IDs.lua), real SQL rows, and real NPC/mob scripts
-- for its cell items, Slot/Socket/Flux Flan, Armoury Crate (fixed + temp-drop pool), and most
-- trash mobs -- see [[topaz_never_fabricate_ids]] for what's still open (floor/stage door
-- progression, exact teleporter coordinates). Silver Sea and Zhayolm Remnants are still untouched.
-----------------------------------
require("scripts/globals/status")
-----------------------------------
salvageUtil = {}

-- DSP has no zones[] table: each zone's IDs.lua defines its own global (Zhayolm, Arrapago, ...).
-- Resolved lazily at call time so a zone whose IDs.lua is not present yet simply returns nil.
function salvageUtil.getIDs(zoneID)
    local ids =
    {
        [73] = Zhayolm,
        [74] = Arrapago,
        [75] = Bhaflau,
        [76] = SilverSea,
    }
    return ids[zoneID]
end
-----------------------------------

-- 2026-09-05: real crash confirmed live -- tpz.region.ALZADAAL covers the shared Alzadaal
-- Undersea Ruins hub zone (72) as well as the 4 actual Remnants instances, so this check let
-- cells be "usable" while just standing in the hub. onCellItemUse then crashes
-- (zones[zoneID].text.CELL_OFFSET is nil) because only the 4 real Remnants zones define that
-- text id -- the hub's own IDs.lua never has it, since this mechanic was never meant to exist
-- there. Gated to the actual 4 Remnants zone ids instead of the broader region flag.
local REMNANTS_ZONES =
{
    [73]    = true,
    [74]   = true,
    [75]    = true,
    [76] = true,
}

function salvageUtil.onCellItemCheck(target, effect, value)
    if not REMNANTS_ZONES[target:getZoneID()] then
        return 55
    end

    local statusEffect = target:getStatusEffect(effect)
    if statusEffect then
        local power = statusEffect:getPower()
        if bit.band(power, value) > 0 then
            return 0
        end
    end
    return 55
end

function salvageUtil.onCellItemUse(target, effect, value, offset)
    local statusEffect = target:getStatusEffect(effect)
    local power = statusEffect:getPower()
    local newpower = bit.band(power, bit.bnot(value))
    local pet = target:getPet()
    local instance = target:getInstance()

    target:delStatusEffectSilent(effect)
    if newpower > 0 then
        local duration = math.floor(statusEffect:getTimeRemaining()/1000)
        target:addStatusEffectEx(effect, effect, newpower, 0, duration)
    end
    -- LSB clears the same three debuffs (DEBILITATION/IMPAIRMENT/OMERTA) off the pet, not just
    -- DEBILITATION -- all three are real confirmed tpz.effect constants (scripts/globals/status.lua).
    if
        pet ~= nil and
        (
            effect == EFFECT_DEBILITATION or
            effect == EFFECT_IMPAIRMENT or
            effect == EFFECT_OMERTA
        )
    then
        pet:delStatusEffectSilent(effect)
        if newpower > 0 then
            local duration = math.floor(statusEffect:getTimeRemaining()/1000)
            pet:addStatusEffectEx(effect, effect, newpower, 0, duration)
        end
    end
    target:messageText(target, salvageUtil.getIDs(target:getZoneID()).text.CELL_OFFSET + offset)

    -- Real per-instance usage counter (instance:getLocalVar/setLocalVar confirmed real, uint64_t,
    -- distinct from the entity-level localvar) -- only meaningful inside an instanced zone.
    if instance then
        instance:setLocalVar('cellsUsed', instance:getLocalVar('cellsUsed') + 1)
    end
end

-----------------------------------
-- 2026-09-06: real temp-chest ("Armoury Crate drops from any enemy") mechanic, ported from LSB's
-- xi.salvage.spawnTempChest/tempBoxTrigger/tempBoxPickItems/tempBoxFinish. Confirmed genuinely
-- zone-independent (unlike instance registration/door-open logic, which Topaz's own real Arrapago
-- Remnants implementation keeps inline per zone) -- checked Arrapago's real trash mob scripts
-- (e.g. scripts/zones/Arrapago_Remnants/mobs/Lamia_Dancer.lua) and found this mechanic ISN'T
-- wired up there either; this is genuinely new functionality for both zones, not a port of
-- something Topaz already has, so it belongs in the shared file rather than being duplicated
-- per zone. Each zone's own ID.npcs.ARMOURY_CRATE table supplies the real ids -- element 1 is that
-- zone's fixed Floor-1 crate (handled by its own npcs/Armoury_Crate.lua), elements 2+ are the
-- repositionable temp-drop pool (confirmed real: Bhaflau captures observed two of these ids at
-- different real positions across two captures, consistent with setPos()-on-drop). Topaz has no
-- utils.slice (LSB does) -- inlined as a plain loop instead, same real behavior.
-----------------------------------

function salvageUtil.spawnTempChest(mob, params)
    local ID = salvageUtil.getIDs(mob:getZoneID())
    local instance = mob:getInstance()

    if not params then
        params = {}
    end

    if params.rate == nil then
        -- Real rate from LSB: Arrapago Remnants uses 300, every other Remnants zone uses 40 --
        -- both are LSB's own already-balanced real constants, not invented here.
        if mob:getZoneID() == 74 then
            params.rate = 300
        else
            params.rate = 40
        end
    end

    if params.rate ~= 0 then
        if params.rate < math.random(1, 1000) then
            return
        end
    end

    if params.itemID_1 == nil or type(params.itemID_1) ~= 'number' then
        params.itemID_1 = false
    end

    for i = 2, #ID.npcs.ARMOURY_CRATE do
        local casket = GetNPCByID(ID.npcs.ARMOURY_CRATE[i], instance)
        if casket and casket:getStatus() == STATUS_DISAPPEAR then
            local pos = mob:getPos()
            casket:setPos(pos.x, pos.y, pos.z, pos.rot)
            casket:resetLocalVars()
            casket:setStatus(STATUS_NORMAL)

            if params.itemID_1 then
                casket:setLocalVar('prePicked', 1)
                casket:setLocalVar('itemID_1', params.itemID_1)
                casket:setLocalVar('itemAmount_1', params.itemAmount_1)
            end

            if params.specialAmount then
                casket:setLocalVar(params.special, params.specialAmount)
            end

            break
        end
    end
end

function salvageUtil.resetTempBoxes(player)
    local ID = salvageUtil.getIDs(player:getZoneID())
    local instance = player:getInstance()

    for i = 2, #ID.npcs.ARMOURY_CRATE do
        local casket = GetNPCByID(ID.npcs.ARMOURY_CRATE[i], instance)
        if casket and casket:getStatus() == STATUS_NORMAL then
            casket:setStatus(STATUS_DISAPPEAR)
            casket:resetLocalVars()
            casket:AnimationSub(8)
        end
    end
end

function salvageUtil.tempBoxTrigger(player, npc)
    if npc:getLocalVar('itemsPicked') == 0 then
        npc:setLocalVar('itemsPicked', 1)
        npc:entityAnimationPacket('open')
        npc:AnimationSub(13)
        if npc:getLocalVar('prePicked') == 0 then
            salvageUtil.tempBoxPickItems(npc)
        end
    end

    -- 2026-09-04: real fix -- this was passing a single Lua TABLE as startEvent's 2nd argument,
    -- ported directly from LSB's own startEvent binding which apparently accepts that. Topaz's
    -- real binding (lua_baseentity.cpp:779, CLuaBaseEntity::startEvent) reads its extra params as
    -- individual positional varargs (va.get<uint32>(0..7), each gated on
    -- va.get_type(N)==sol::type::number) -- it never unpacks a table, so with only one vararg (a
    -- table, not a number) every param defaulted to 0. That's exactly why the real "What do you
    -- take?" menu (message 7252, confirmed real event-2 text in Arrapago's own dat dump) showed
    -- every slot as "(0 remaining)" -- the item id/quantity data never reached the client at all.
    -- Fixed by passing each encoded value as its own positional argument instead.
    player:startEvent(2,
        (npc:getLocalVar('itemID_1') + (npc:getLocalVar('itemAmount_1') * 65536)),
        (npc:getLocalVar('itemID_2') + (npc:getLocalVar('itemAmount_2') * 65536)),
        (npc:getLocalVar('itemID_3') + (npc:getLocalVar('itemAmount_3') * 65536)),
        (npc:getLocalVar('itemID_4') + (npc:getLocalVar('itemAmount_4') * 65536)),
        (npc:getLocalVar('itemID_5') + (npc:getLocalVar('itemAmount_5') * 65536)),
        (npc:getLocalVar('itemID_6') + (npc:getLocalVar('itemAmount_6') * 65536)),
        (npc:getLocalVar('itemID_7') + (npc:getLocalVar('itemAmount_7') * 65536)))
end

function salvageUtil.tempBoxPickItems(npc)
    -- Real item pool from LSB -- all 22 real item ids/names, verified against id_bridge.py
    -- earlier this session (all confirmed SAME id on LSB and Topaz).
    local tempBoxItems =
    {
        [1]  = { itemID = 5385, amount = math.random(1, 3) }, -- Bottle of Barbarian's Drink
        [2]  = { itemID = 5386, amount = math.random(1, 3) }, -- Bottle of Fighter's Drink
        [3]  = { itemID = 5387, amount = math.random(1, 3) }, -- Bottle of Oracle's Drink
        [4]  = { itemID = 5388, amount = math.random(1, 3) }, -- Bottle of Assassin's Drink
        [5]  = { itemID = 5389, amount = math.random(1, 3) }, -- Bottle of Spy's Drink
        [6]  = { itemID = 5390, amount = math.random(1, 3) }, -- Bottle of Braver's Drink
        [7]  = { itemID = 5391, amount = math.random(1, 3) }, -- Bottle of Soldier's Drink
        [8]  = { itemID = 5392, amount = math.random(1, 3) }, -- Bottle of Champion's Drink
        [9]  = { itemID = 5393, amount = math.random(1, 3) }, -- Bottle of Monarch's Drink
        [10] = { itemID = 5394, amount = math.random(1, 3) }, -- Bottle of Gnostic's Drink
        [11] = { itemID = 5395, amount = math.random(1, 3) }, -- Bottle of Cleric's Drink
        [12] = { itemID = 5396, amount = math.random(1, 3) }, -- Bottle of Shepherd's Drink
        [13] = { itemID = 5397, amount = math.random(1, 3) }, -- Bottle of Sprinter's Drink
        [14] = { itemID = 5437, amount = math.random(1, 5) }, -- Flask of Strange Milk
        [15] = { itemID = 5438, amount = math.random(1, 5) }, -- Bottle of Strange Juice
        [16] = { itemID = 5434, amount = 1 },                 -- Bottle of Fanatic's Drink
        [17] = { itemID = 5435, amount = 1 },                 -- Bottle of Fool's Drink
        [18] = { itemID = 5440, amount = 1 },                 -- Dusty Wing
        [19] = { itemID = 5439, amount = math.random(1, 3) }, -- Bottle of Vicar's Drink
        [20] = { itemID = 5431, amount = math.random(1, 10) },-- Dusty Potion
        [21] = { itemID = 5432, amount = math.random(1, 10) },-- Dusty Ether
        [22] = { itemID = 5433, amount = 1 },                 -- Dusty Elixir
    }
    local chosen1 = math.random(1, #tempBoxItems)
    local item1 = tempBoxItems[chosen1]
    local item2random = math.random(1, 10) > 4
    local item3random = math.random(1, 10) > 8

    if npc:getLocalVar('itemID_1') == 0 then
        npc:setLocalVar('itemID_1', item1.itemID)
        npc:setLocalVar('itemAmount_1', item1.amount)
        table.remove(tempBoxItems, chosen1)
    end

    if item2random then
        local chosen2 = math.random(1, #tempBoxItems)
        local item2 = tempBoxItems[chosen2]

        npc:setLocalVar('itemID_2', item2.itemID)
        npc:setLocalVar('itemAmount_2', item2.amount)
        table.remove(tempBoxItems, chosen2)
    end

    if item3random then
        local chosen3 = math.random(1, #tempBoxItems)
        local item3 = tempBoxItems[chosen3]

        npc:setLocalVar('itemID_3', item3.itemID)
        npc:setLocalVar('itemAmount_3', item3.amount)
        table.remove(tempBoxItems, chosen3)
    end
end

-- 2026-09-06: real fix -- the fixed Floor-1 Armoury Crate DOES use the real temp-item pick-one-
-- at-a-time menu (tempBoxTrigger/tempBoxFinish), same as the drop-pool caskets -- user confirmed
-- this directly ("the items are supposed to be selected from the temp item menu and not granted
-- all at once"). What's different about the fixed crate is only its item POOL: real cells, not the
-- pool caskets' random drinks/potions, and per the user's own real-game knowledge, guaranteed (not
-- rate-gated): 2x Incus Cell (Weapon, 5365), Praecipitatio Cell (Magic, 5375), Duplicatus Cell
-- (Subjob, 5373), Opacus Cell (Ability, 5374), 2x one of Humilus/Spissatus/Undulatus/Cumulus
-- (HP/MP/Ranged/Body, 5383/5384/5371/5367), one more Praecipitatio or Opacus (coin flip), and 2x
-- other armor/stat cell from the remaining pool (5366/5368/5369/5370/5372/5376/5377/5378/5379/
-- 5380/5381/5382) -- all real confirmed item_basic.sql ids, same pool the crate's old
-- addTreasure()-only logic already used. Consolidates same-id grants into one amount-stacked slot
-- so the 7-slot cap (tempBoxTrigger only ever sends itemID_1..7) is never exceeded: worst case is
-- 7 distinct slots (incus, praecipitatio, duplicatus, opacus, the HP/MP/Ranged/Body pick, and 2
-- other armor/stat cells) since the coin-flip always merges into the existing praecipitatio/
-- opacus slot.
function salvageUtil.tempBoxPickCellItems(npc)
    npc:setLocalVar('prePicked', 1)

    local slots = {}
    local function grant(itemID, amount)
        for _, slot in ipairs(slots) do
            if slot.itemID == itemID then
                slot.amount = slot.amount + amount
                return
            end
        end
        table.insert(slots, { itemID = itemID, amount = amount })
    end

    local HP_MP_RANGED_BODY = {5367, 5371, 5383, 5384} -- cumulus/undulatus/humilus/spissatus_cell
    local OTHER_STAT_ARMOR  = {5366, 5368, 5369, 5370, 5372, 5376, 5377, 5378, 5379, 5380, 5381, 5382}

    grant(5365, 2) -- 2x Incus Cell (Weapon)
    grant(5375, 1) -- Praecipitatio Cell (Magic)
    grant(5373, 1) -- Duplicatus Cell (Subjob)
    grant(5374, 1) -- Opacus Cell (Ability)
    grant(HP_MP_RANGED_BODY[math.random(#HP_MP_RANGED_BODY)], 2)

    if math.random(1, 2) == 1 then
        grant(5375, 1)
    else
        grant(5374, 1)
    end

    grant(OTHER_STAT_ARMOR[math.random(#OTHER_STAT_ARMOR)], 1)
    grant(OTHER_STAT_ARMOR[math.random(#OTHER_STAT_ARMOR)], 1)

    for i, slot in ipairs(slots) do
        npc:setLocalVar('itemID_'..i, slot.itemID)
        npc:setLocalVar('itemAmount_'..i, slot.amount)
    end
end

function salvageUtil.tempBoxFinish(player, csid, option, npc)
    if csid == 2 then
        for choice = 1, 8 do
            if option == choice then
                local item = npc:getLocalVar('itemID_'..choice)
                local itemQnty = npc:getLocalVar('itemAmount_'..choice)

                if item > 0 and itemQnty > 0 then
                    if not player:hasItem(item, LOC_TEMPITEMS) then
                        player:addTempItem(item)
                        npc:setLocalVar('itemAmount_'..choice, itemQnty - 1)
                    else
                        -- LSB shows a "you already have that temp item" message here
                        -- (ID.text.HAVE_TEMP_ITEM) -- not added since that text id isn't
                        -- independently confirmed for Bhaflau yet; skip silently instead of
                        -- guessing a text id, per [[topaz_never_fabricate_ids]].
                    end
                end
            end
        end

        if
            npc:getLocalVar('itemAmount_1') == 0 and
            npc:getLocalVar('itemAmount_2') == 0 and
            npc:getLocalVar('itemAmount_3') == 0 and
            npc:getLocalVar('itemAmount_4') == 0 and
            npc:getLocalVar('itemAmount_5') == 0 and
            npc:getLocalVar('itemAmount_6') == 0 and
            npc:getLocalVar('itemAmount_7') == 0
        then
            npc:queue(10000, function(npcArg)
                npcArg:entityAnimationPacket('kesu')
            end)

            npc:queue(12000, function(npcArg)
                npcArg:setStatus(STATUS_DISAPPEAR)
                npc:AnimationSub(8)
            end)
        end
    end
end
