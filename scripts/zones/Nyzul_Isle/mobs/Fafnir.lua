-----------------------------------
-- Area: Nyzul Isle
--  Mob: Fafnir
-----------------------------------
-- 2026-09-03: real boss-floor HNM (floors 20/40, per BG Wiki -- "Fafnir's Hurricane Wing is
-- actually stronger than his Dragon's Aery incarnation, and can still Spike Flail like all other
-- wyrms."). Real, pre-existing mob_spawn_points row (17093001, mob_groups groupid 162/poolid
-- 1280, zone 77, level 80) -- just never wired to anything. No special-move scripting ported here
-- (same treatment as Behemoth.lua/Imp.lua/Mokke.lua) -- base combat comes from mob_pools' own
-- columns (this row already has hasSpellScript=1/spellList=32 set, so at least some real spell
-- behavior is likely already engine-driven without any Lua needed).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
-- 2026-09-15, real crash found live (VS call stack: CAIContainer::ForceChangeState debug assert,
-- m_stateStack.size() > 10, during CMobEntity::OnDespawn -> Internal_Respawn on a boss floor
-- fight). Root cause: nyzul_isle_investigation.lua's despawnBosses() unconditionally called
-- DespawnMob() on ALL 6 boss-floor mobs on EVERY floor transition, not just whichever was rolled
-- that floor. Since this boss's mob_groups respawntime is 0 (Lua-driven spawning, not native
-- auto-respawn), CRespawnState::Update() never completes once triggered -- so each REDUNDANT
-- DespawnMob() call (on a boss not even currently spawned) permanently stuck a Despawn/Respawn
-- pair on its AI state stack (CheckCompletedStates only ever inspects the stack's top). Enough
-- floor transitions and the stack crosses 10.
--
-- Two wrong fixes tried here before landing on the real one (both reverted):
-- 1. setMobMod(MOBMOD_NO_DESPAWN) -- only feeds CMobEntity::CanRoamHome() (leash despawns), has
--    zero effect on despawnBosses()'s explicit DespawnMob() calls.
-- 2. mob:setBehaviour(bit.bor(..., BEHAVIOUR_NO_DESPAWN)) -- DOES block despawn_state.cpp's
--    completion check, but that flag's real meaning (per mobentity.h's own comment) is "mob does
--    not despawn ON DEATH" -- it stopped the crash but broke the legitimate corpse fade-out after
--    a real kill (user-reported live: corpses stopped despawning, and a 3rd different boss on the
--    same floor threw a new error), since it blocks ALL despawns unconditionally, not just the
--    spurious ones.
-- REAL fix: the redundant DespawnMob() calls themselves are the bug, not the despawn mechanism --
-- despawnBosses() (nyzul_isle_investigation.lua) now checks mob:isSpawned() before calling
-- DespawnMob() on each boss slot, so a boss that isn't currently active is never touched at all.
-- No mob-side change needed; this file is back to its original, pre-2026-09-15 state.
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
    Nyzul.bossArmorDrop(player, mob)
end

