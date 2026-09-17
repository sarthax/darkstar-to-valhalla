-----------------------------------
-- Area: Lebros Cavern (Evade and Escape)
--  NPC: Switch
-----------------------------------
-- 2026-08-29 REBUILT to the real mechanic (user-confirmed wiki text): 3 switches, randomly
-- placed among 7 possible small rooms, each stays active 5 minutes once hit -- ALL 3 must be
-- active AT THE SAME TIME to spawn the Rune of Release, not just 3 total hits ever. The
-- 2026-08-22 build was a deliberately-flagged simplification (flat cumulative counter, same
-- shared instance progress Dahak kills use) since this codebase had no progress-can-decrease
-- path anywhere -- fixed properly now via a real per-switch expiry timestamp
-- (`activeUntil` = os.time() + 300) checked for simultaneity in
-- instances/evade_and_escape.lua's onInstanceTimeUpdate, instead of ever touching
-- instance:getProgress()/setProgress() directly. Killing a Dahak (still user-confirmed
-- independently valid) is modeled there as a PERMANENT credit (a kill has no natural "5-minute
-- window" to expire), combined with however many switches are live right now.
-----------------------------------
-- 2026-09-02, user-reported live: switch messages were printing to player chat (PrintToPlayer)
-- instead of playing through the real dialog engine -- because no real message ids had been
-- confirmed for this mechanic yet. Now wired to real, dat-extractor-confirmed text (see IDs.lua's
-- Evade and Escape block for the capture crosscheck): SWITCH_ACTIVATED on a fresh trigger,
-- SWITCH_REFRESHED on re-triggering an already-active switch (real text: "...glowing brightly...
-- won't fade any time soon", i.e. extending it, not a rejection).
-- 2026-09-02 (later): CORRECTED visual state field. Was calling setAnimation(9), the wrong field
-- entirely (that's the door-prop open/closed convention, not this model's own real toggle) --
-- this real model (1509, same as Bridge_Switch.lua/Building Bridges and Nyzul Isle's Runic Lamp)
-- was confirmed via a real LandSandBoat source script (Runic_Lamp.lua) to use setAnimationSub(1)
-- for its lit/activated state, not setAnimation. Bridge_Switch.lua had already independently
-- guessed setAnimationSub(1) correctly (from the caskets.lua precedent) before this confirmation
-- existed -- this file corrected to match.
-- 2026-09-11, user-reported live (immersion-breaking): the forceRespawn() calls added below on
-- 2026-09-02 to force a visual refresh do a literal hard despawn, then a REAL respawn packet 1s
-- later (src/map/lua/lua_baseentity.cpp:4145) -- that IS the "despawns and blinks" the user is
-- seeing, on every single trigger and every real 5-min expiry. Root cause of the original "plain
-- setAnimationSub() did nothing" complaint that motivated forceRespawn was never the model or the
-- packet type -- it's the exact same silent-no-op bug already root-caused for Mamool Ja's
-- Supplies_Crate.lua/caskets.lua: setAnimationSub() only broadcasts when the value actually
-- CHANGES (lua_baseentity.cpp:4381). Re-triggering an ALREADY-active switch (the "extend the
-- window" case) calls setAnimationSub(1) while it's already 1 -- a genuine no-op, easily
-- misdiagnosed as "the model doesn't support this". Supplies_Crate.lua's proven fix (confirmed
-- live, no despawn/blink involved): toggle 0 then 1 back-to-back to force a real ENTITY_UPDATE
-- broadcast regardless of current state. Applied here instead of forceRespawn -- same real model,
-- same real animationsub convention, just the already-working non-blinking trigger pattern this
-- codebase already has for exactly this class of prop.
-- 2026-09-12 REAL FIX, found via the user's own retail packet capture (mission_toolkit
-- ffxi_zone_database.db, capture_id 90 "Lebros Cavern LC - Evade and Escape"): 0/1 were never the
-- real values at all. Every real CEntityUpdatePacket for this exact npc (17035481/2/3) that
-- includes the UPDATE_HP bit (the only packets where byte 0x2A is meaningful -- see
-- src/map/packets/entity_update.cpp:106-115) shows animationsub = 4 baseline / 5 once activated,
-- confirmed identically across all 3 real switches, multiple independent trigger events each
-- (e.g. seq 5217->5272, 8488->8526, 8866->8928, 9085->9129). 4 also matches the real stored
-- default already seen on Nyzul Isle's own Rune_of_Transfer/Runic_Lamp rows (npc_list.sql) -- this
-- project's own earlier "default 0->4" experiment (see that row's header comment) was half right
-- but got reverted as "no effect" only because the ACTIVATED value was still wrongly 1 at the
-- time, never re-tested against the real activated value of 5.
local ID = Lebros
local SWITCH_ACTIVE_SECONDS = 300
local UNLIT_ANIM_SUB = 4
local ACTIVATED_ANIM_SUB = 5
function onTrigger(player, npc)
    -- 2026-09-12, user-reported live: this static wall-mounted prop was rotating to face the
    -- player on every trigger. lookAt() is a player-facing-NPC convention (dialogue NPCs) that was
    -- never appropriate here -- Nyzul Isle's real Rune_of_Transfer.lua (the confirmed-correct
    -- precedent for this exact model, 1509) has no lookAt() call at all. Removed.
    local activeUntil = npc:getLocalVar("activeUntil")

    npc:setLocalVar("activeUntil", os.time() + SWITCH_ACTIVE_SECONDS)
    -- 2026-09-02: reset on every (re)trigger so the 60s-left warning (fired from
    -- evade_and_escape.lua's onInstanceTimeUpdate) can fire again for the new window instead of
    -- staying permanently silenced after the first activation.
    npc:setLocalVar("expiryWarned", 0)
    -- 2026-09-11: toggle through the real unlit value first (Supplies_Crate.lua's proven pattern)
    -- so a re-trigger of an already-lit switch still forces a real ENTITY_UPDATE broadcast instead
    -- of a silent no-op (setAnimationSub() only sends a packet when the value changes --
    -- lua_baseentity.cpp:4381). No forceRespawn() -- that was the real source of the despawn/
    -- blink, not a fix for anything.
    npc:AnimationSub(UNLIT_ANIM_SUB)
    npc:AnimationSub(ACTIVATED_ANIM_SUB)

    -- 2026-09-02: visually revert once this real 5-min window genuinely expires -- guarded
    -- against a re-trigger extending activeUntil further in the meantime (real LandSandBoat
    -- Runic_Lamp.lua reverts the same way, checking the state is still due to expire before
    -- clearing it, rather than blindly clearing on a fixed delay).
    npc:timer(SWITCH_ACTIVE_SECONDS * 1000, function(switchNpc)
        if switchNpc:getLocalVar("activeUntil") <= os.time() then
            switchNpc:AnimationSub(UNLIT_ANIM_SUB)
        end
    end)

    if activeUntil and activeUntil > os.time() then
        player:messageText(npc, ID.text.SWITCH_REFRESHED)
    else
        player:messageText(npc, ID.text.SWITCH_ACTIVATED)
    end
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option)
end

