-----------------------------------
-- Area: Mamool Ja Training Grounds (Breaking Morale)
--  Mob: Mamool Ja Trainer
-----------------------------------
-- Ambient camp guard -- see instances/breaking_morale.lua. Corrected 2026-08-18: real objective
-- is looting Supplies Crates and turning them in to Quhaaja, not killing these; no longer tied
-- to instance progress.
-- 2026-08-22, built from FFXIclopedia's walkthrough + this codebase's own earlier capture-derived
-- dev notes (see breaking_morale.lua's header): Trainers have true sight and, on spotting a
-- player, "automatically teleport you to a 'prison'" -- if the player is holding a Supplies Crate
-- flavor item at that moment, it's stripped ("The supplies you seized are missing!", real
-- dat-extractor text id, IDs.lua). Modeled via onMobEngaged (the earlier capture's own evidence
-- was "a Trainer uses hate on the player", i.e. this fires through the normal aggro/engage path,
-- not a separate detection radius) -- teleports to Viscous Liquid's real position (the wiki: the
-- prison is "next to the Viscous Liquid") and disengages immediately, so the player is
-- teleported+robbed rather than actually fought.
-- 2026-08-24, user-provided wiki text: real mechanic has two more real details, both wired in --
-- (1) "Mamool Ja Trainers can be killed by high tier elemental magic... If killed in one shot,
-- you will not be sent to the prison" -- the whole taunt/teleport/strip sequence used to fire
-- instantly and unconditionally the moment onMobEngaged runs, before the player's own opening hit
-- could ever land, so a one-shot kill was never actually possible to achieve. Fixed by delaying
-- the sequence behind a short window (TELEPORT_DELAY_MS) and checking mob:isAlive() first --
-- if a burst kill lands in that window, the mob is already dead and the sequence never fires.
-- Not capture-confirmed exactly how long this window really is; treated as a reasonable estimate
-- (long enough for a single opening weaponskill/nuke to resolve).
-- (2) "Mamool Ja Trainers respawn in about ~5 minutes" -- onMobDeath was previously an empty stub,
-- no respawn wired at all. Added via mob:spawn(nil, respawnSec), the same pattern already used
-- for Siegemaster Assassination's Old_Troll.lua repop.
-----------------------------------
require("scripts/globals/status")
package.loaded["scripts/zones/Mamool_Ja_Training_Grounds/TextIDs"] = nil;
require("scripts/zones/Mamool_Ja_Training_Grounds/TextIDs");
-----------------------------------
local LOOT_POOL =
{
    222, 542, 568, 579, 1683, 584, 2227, 556,
}

local TELEPORT_DELAY_MS = 1500 -- ESTIMATE -- see header (2) -- long enough for an opening burst kill to resolve first
local RESPAWN_SEC        = 300  -- ~5 minutes, per the real wiki text

-- 2026-08-29 user-confirmed: teleporting straight to Viscous_Liquid's own npc_list position
-- sometimes clipped the player inside nearby geometry. Real user-verified LOGPOS just clear of
-- obstruction, used instead of reading the prop's own position live.
local PRISON_POS = { x = 50.7691, y = 1.6389, z = -296.7737, rot = 0 }

function onMobEngaged(mob, target)
    if target:getObjType() ~= TYPE_PC then
        return
    end

    -- 2026-08-24, user-confirmed real mechanic: Mamool Ja (Recruit AND Trainer both) do not
    -- attack/catch a player while the Viscous Liquid disguise (EFFECT_COSTUME) is active --
    -- explicitly confirmed against the mission-specific wiki page over the generic one, and
    -- directly by the user ("While illusion is on, Trainers and Recruits will NOT see and
    -- teleport the player"). Immediate disengage, no taunt/teleport/item-strip sequence.
    -- 2026-08-24, follow-up, user re-reported still attacking (teleport correctly suppressed, but
    -- melee wasn't): resetEnmity() alone doesn't necessarily stop an already-engaged mob's current
    -- combat tick -- every other real combat-termination case elsewhere this session
    -- (Black_Baron.lua, Sagelord_Molaal_Ja.lua) always pairs it with an explicit disengage() too.
    -- Added here to match.
    if target:hasStatusEffect(EFFECT_COSTUME) then
        mob:disengage()
        mob:resetEnmity(target)
        return
    end

    target:messageText(mob, TRAINER_CAUGHT_TAUNT)

    local targetId = target:getID()
    mob:timer(TELEPORT_DELAY_MS, function(mob)
        -- stale-player guard: re-resolve by id (captured `target` crashes if they left)
        local target = GetPlayerByID(targetId)
        if not target or not mob:isAlive() or not mob:getInstance() then
            return
        end
        -- Player one-shot the Trainer during the delay window -- no prison teleport, matching
        -- the real wiki text exactly. onMobDeath below still handles the real ~5min respawn.
        if not mob:isAlive() then
            return
        end

        if not target:hasStatusEffect(EFFECT_COSTUME) then
            local instance = mob:getInstance()
            target:setPos(PRISON_POS.x, PRISON_POS.y, PRISON_POS.z, PRISON_POS.rot)
            target:messageText(mob, TRAINER_CAUGHT_TELEPORT)

            -- 2026-08-24: same temp-item storage bug found and fixed in npcs/Quhaaja.lua --
            -- Supplies_Crate.lua grants this pool via addTempItem() (LOC_TEMPITEMS), not regular
            -- inventory. See that file's header for the full delItem() crash explanation.
            for _, itemId in ipairs(LOOT_POOL) do
                if target:hasItem(itemId, LOC_TEMPITEMS) then
                    target:delItem(itemId, 1, LOC_TEMPITEMS)
                    target:messageText(mob, TRAINER_ITEM_STRIPPED)

                    -- 2026-08-29 user-requested: being caught and stripped here (as opposed to
                    -- turning the item in to Quhaaja) reopens the SPECIFIC crate this item came
                    -- from -- see Supplies_Crate.lua's own header. Turning in instead leaves the
                    -- crate empty permanently (Quhaaja.lua never touches this localvar on a
                    -- successful turn-in).
                    local crateId = target:getLocalVar("suppliesCrateId")
                    if crateId and crateId ~= 0 then
                        local crate = instance:getEntity(bit.band(crateId, 0xFFF), TYPE_NPC)
                        if crate then
                            crate:setLocalVar("opened", 0)
                            -- 2026-08-29: reverts the real persisted open state -- see
                            -- Supplies_Crate.lua's onTrigger. setAnimationSub(0) matches this
                            -- codebase's own real working convention for a reset treasure
                            -- container (scripts/globals/caskets.lua's removeChest()).
                            crate:AnimationSub(0)
                            crate:updateAnimationSub()
                        end
                        target:setLocalVar("suppliesCrateId", 0)
                    end
                    break
                end
            end
        end

        -- Player is now teleported away, not actually fought -- disengage + reset enmity so the
        -- Trainer doesn't stay locked in a combat stance against a target that's no longer nearby
        -- (or, if illusion was gained during the delay window, doesn't keep fighting at all).
        mob:disengage()
        mob:resetEnmity(target)
    end)
end

function onMobSpawn(mob)
    mob:spawn(nil, RESPAWN_SEC)
end

function onMobDeath(mob, player, isKiller)
end

