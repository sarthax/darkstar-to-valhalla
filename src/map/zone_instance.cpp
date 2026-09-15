/*
===========================================================================

Copyright (c) 2010-2015 Darkstar Dev Teams

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/

This file is part of DarkStar-server source code.

===========================================================================
*/

#include "zone_instance.h"
#include "../common/timer.h"
#include "entities/charentity.h"
#include "lua/luautils.h"
#include "utils/zoneutils.h"
#include "status_effect_container.h"
#include "ai/ai_container.h"

/************************************************************************
*																		*
*  Класс CZoneInstance													*
*																		*
************************************************************************/

CZoneInstance::CZoneInstance(ZONEID ZoneID, REGIONTYPE RegionID, CONTINENTTYPE ContinentID)
    : CZone(ZoneID, RegionID, ContinentID)
{
}

CZoneInstance::~CZoneInstance()
{
    for (auto instance : instanceList)
    {
        delete instance;
    }
}

CCharEntity* CZoneInstance::GetCharByName(int8* name)
{
    CCharEntity* PEntity = nullptr;
    for (auto instance : instanceList)
    {
        PEntity = instance->GetCharByName(name);
        if (PEntity) break;
    }
    return PEntity;
}

CCharEntity* CZoneInstance::GetCharByID(uint32 id)
{
    CCharEntity* PEntity = nullptr;
    for (auto instance : instanceList)
    {
        PEntity = instance->GetCharByID(id);
        if (PEntity) break;
    }
    return PEntity;
}

CBaseEntity* CZoneInstance::GetEntity(uint16 targid, uint8 filter)
{
    CBaseEntity* PEntity = nullptr;
    if (filter & TYPE_PC)
    {
        for (auto instance : instanceList)
        {
            PEntity = instance->GetEntity(targid, filter);
            if (PEntity) break;
        }
    }
    return PEntity;
}

void CZoneInstance::InsertMOB(CBaseEntity* PMob)
{
    if (PMob->PInstance)
    {
        PMob->PInstance->InsertMOB(PMob);
    }
}

void CZoneInstance::InsertNPC(CBaseEntity* PNpc)
{
    if (PNpc->PInstance)
    {
        PNpc->PInstance->InsertNPC(PNpc);
    }
}

void CZoneInstance::DeletePET(CBaseEntity* PPet)
{
    if (PPet->PInstance)
    {
        PPet->PInstance->DeletePET(PPet);
    }
}

void CZoneInstance::InsertPET(CBaseEntity* PPet)
{
    if (PPet->PInstance)
    {
        PPet->PInstance->InsertPET(PPet);
    }
}

void CZoneInstance::FindPartyForMob(CBaseEntity* PEntity)
{
    if (PEntity->PInstance)
    {
        PEntity->PInstance->FindPartyForMob(PEntity);
    }
}

void CZoneInstance::TransportDepart(uint16 boundary, uint16 zone)
{
    for (auto instance : instanceList)
    {
        instance->TransportDepart(boundary, zone);
    }
}

void CZoneInstance::DecreaseZoneCounter(CCharEntity* PChar)
{
    CInstance* instance = PChar->PInstance;

    // 2026-09-14, real bug found via live repro (breakpoint never hit, silent bounce back to
    // open world on a same-zone-id GM instance warp): the client's own 0x00D packet (tail end of
    // leaving the PREVIOUS zone/prezone, already in flight) arrives via
    // SmallPacket0x00D -> PChar->loc.zone->DecreaseZoneCounter(PChar) -- but by the time it's
    // processed, setInstance() (lua_baseentity.cpp) has already reassigned PChar->PInstance to
    // the NEW instance the GM command just created. This function blindly read PChar->PInstance's
    // CURRENT value, tore the character back OUT of the brand-new instance, and unconditionally
    // nulled PChar->PInstance again -- all before the character's real zone-in packet for the new
    // instance ever arrived. Guard against this: only run the full teardown if the character was
    // actually registered in THIS specific instance's own charList -- a stale/late 0x00D for an
    // instance the character has already moved on from should be a no-op, not a teardown of
    // whatever instance they're NOW in.
    if (instance && instance->GetCharByID(PChar->id) != PChar)
    {
        ShowWarning(CL_YELLOW "CZoneInstance::DecreaseZoneCounter: %s's PInstance (instanceid %u, ptr %p) does not have them "
                              "registered in its own charList -- likely a stale zone-out packet racing a same-zone-id instance "
                              "switch -- skipping teardown instead of tearing down the wrong instance\n" CL_RESET,
                    PChar->GetName(), instance->GetID(), (void*)instance);
        return;
    }

    if (instance)
    {
        instance->DecreaseZoneCounter(PChar);
        instance->DespawnPC(PChar);
        CharZoneOut(PChar);
        PChar->StatusEffectContainer->DelStatusEffectSilent(EFFECT_LEVEL_RESTRICTION);
        PChar->PInstance = nullptr;

        if (instance->CharListEmpty())
        {
            if (instance->Failed() || instance->Completed())
            {
                instanceList.erase(std::find(instanceList.begin(), instanceList.end(), instance));
                delete instance;
            }
            else
            {
                instance->SetWipeTime(server_clock::now());
            }
        }
    }
}

void CZoneInstance::IncreaseZoneCounter(CCharEntity* PChar)
{
    DSP_DEBUG_BREAK_IF(PChar == nullptr);
    DSP_DEBUG_BREAK_IF(PChar->PTreasurePool != nullptr);

    // 2026-09-14, ported from Topaz's own !warpassault same-zone-id transition fix (2026-08-18):
    // a GM instance-warp command's onInstanceCreated handler calls player:setPos() into the SAME
    // zone the character is already standing in (needed because the ready callback only resolves
    // via the character's current zone), so loc.zone isn't guaranteed to have been nulled out yet
    // when the zone-in machinery re-enters. Recover instead of asserting/crashing.
    if (PChar->loc.zone != nullptr)
    {
        ShowWarning(CL_YELLOW "CZoneInstance::IncreaseZoneCounter: %s still had loc.zone=%p set (likely a same-zone-id "
                              "transition, e.g. a GM instance warp) -- clearing it instead of asserting\n" CL_RESET,
                    PChar->GetName(), (void*)PChar->loc.zone);
        PChar->loc.zone = nullptr;
    }

    //return char to instance (d/c or logout)
    if (!PChar->PInstance)
    {
        // 2026-09-14, real bug found via live repro (worked on first entry, silently hijacked
        // later attempts into a dead instance): CInstance::RegisterChar() appends to
        // m_registeredChars and NOTHING ever removes an entry from it -- there is no
        // UnregisterChar(). setInstance()'s same-zone-id detach fix (lua_baseentity.cpp) clears
        // the character from the old instance's m_charList (stopping the crash), but they stay
        // permanently in that old instance's m_registeredChars, so CharRegistered() keeps
        // matching it forever. The GM-fallback dummy instance (instanceid 0, created below) is
        // the worst offender -- created fresh on every plain zone-in, never Failed()/Completed(),
        // so the periodic ZoneServer sweep never reaps it either -- it just accumulates and gets
        // matched here on a LATER zone-in, hijacking PChar->PInstance away from a fresh real
        // instance load. Dummy instances were only ever meant to be one-shot throwaway
        // housekeeping, never something to recover into -- skip them here.
        for (auto instance : instanceList)
        {
            if (instance->GetID() != 0 && instance->CharRegistered(PChar))
            {
                PChar->PInstance = instance;
            }
        }
        if (!PChar->PInstance && PChar->m_GMlevel > 0)
        {
            // 2026-09-14, crash-reported (vector erase iterator outside range, in
            // DecreaseZoneCounter's `instanceList.erase(std::find(...))`): this used to be a bare
            // `new CInstance(this, 0)` assigned only to PChar->PInstance -- never added to
            // instanceList like every other instance (compare the normal load path below, which
            // does `instanceList.push_back(instance)`). That left it completely untracked:
            // DecreaseZoneCounter's std::find() could never find it once the GM left and it
            // needed erasing, so std::find returned end() and erase(end()) is undefined behavior.
            // Same bug Topaz found and fixed independently via a !warpassault crash, 2026-08-18
            // (see zone_instance.cpp there) -- route this through the same push_back-tracked
            // ownership as every other instance instead of leaving it orphaned.
            CInstance* fallbackInstance = new CInstance(this, 0);
            instanceList.push_back(fallbackInstance);
            PChar->PInstance = fallbackInstance;
        }
    }

    if (PChar->PInstance)
    {
        if (!ZoneTimer)
        {
            createZoneTimer();
        }
        PChar->targid = PChar->PInstance->GetNewTargID();

        if (PChar->targid >= 0x700)
        {
            ShowError(CL_RED"CZone::InsertChar : targid is high (03hX)\n" CL_RESET, PChar->targid);
            return;
        }

        PChar->PInstance->InsertPC(PChar);
        luautils::OnInstanceZoneIn(PChar, PChar->PInstance);
        CharZoneIn(PChar);

        /* disabled until invalid packet error can be worked around (not sending all
           level related stuff twice (before and after level sync)
        if (PChar->PInstance->GetLevelCap() > 0)
        {
            PChar->StatusEffectContainer->DelStatusEffectsByFlag(EFFECTFLAG_DISPELABLE | EFFECTFLAG_ON_ZONE);
            PChar->StatusEffectContainer->AddStatusEffect(new CStatusEffect(
                EFFECT_LEVEL_RESTRICTION,
                EFFECT_LEVEL_RESTRICTION,
                PChar->PInstance->GetLevelCap(),
                0, 0)
            );
        }*/

        if (PChar->PInstance->CheckFirstEntry(PChar->id))
        {
            PChar->loc.p = PChar->PInstance->GetEntryLoc();
            PChar->PAI->QueueAction(queueAction_t(400ms, false, luautils::AfterInstanceRegister));
        }
    }
    else
    {
        //instance no longer exists: put them outside (at exit)
        PChar->loc.prevzone = GetID();

        uint16 zoneid = luautils::OnInstanceLoadFailed(this);

        zoneutils::GetZone(zoneid > MAX_ZONEID ? PChar->loc.prevzone : zoneid)->IncreaseZoneCounter(PChar);
    }
}

void CZoneInstance::SpawnMOBs(CCharEntity* PChar)
{
    if (PChar->PInstance)
    {
        PChar->PInstance->SpawnMOBs(PChar);
    }
}

void CZoneInstance::SpawnPETs(CCharEntity* PChar)
{
    if (PChar->PInstance)
    {
        PChar->PInstance->SpawnPETs(PChar);
    }
}

void CZoneInstance::SpawnNPCs(CCharEntity* PChar)
{
    if (PChar->PInstance)
    {
        PChar->PInstance->SpawnNPCs(PChar);
    }
}

void CZoneInstance::SpawnPCs(CCharEntity* PChar)
{
    if (PChar->PInstance)
    {
        PChar->PInstance->SpawnPCs(PChar);
    }
}

void CZoneInstance::SpawnMoogle(CCharEntity* PChar)
{
    if (PChar->PInstance)
    {
        PChar->PInstance->SpawnMoogle(PChar);
    }
}

void CZoneInstance::SpawnTransport(CCharEntity* PChar)
{
    if (PChar->PInstance)
    {
        PChar->PInstance->SpawnTransport(PChar);
    }
}

void CZoneInstance::TOTDChange(TIMETYPE TOTD)
{
    for (auto instance : instanceList)
    {
        instance->TOTDChange(TOTD);
    }
}

void CZoneInstance::PushPacket(CBaseEntity* PEntity, GLOBAL_MESSAGE_TYPE message_type, CBasicPacket* packet)
{
    if (PEntity)
    {
        if (PEntity->PInstance)
        {
            PEntity->PInstance->PushPacket(PEntity, message_type, packet);
        }
    }
    else
    {
        for (auto instance : instanceList)
        {
            instance->PushPacket(PEntity, message_type, packet);
        }
    }
}

void CZoneInstance::WideScan(CCharEntity* PChar, uint16 radius)
{
    if (PChar->PInstance)
    {
        PChar->PInstance->WideScan(PChar, radius);
    }
}

void CZoneInstance::ZoneServer(time_point tick, bool check_regions)
{
    auto it = instanceList.begin();
    while (it != instanceList.end())
    {
        CInstance* instance = *it;

        instance->ZoneServer(tick, check_regions);
        instance->CheckTime(tick);

        if ((instance->Failed() || instance->Completed()) && instance->CharListEmpty())
        {
            it = instanceList.erase(it);
            delete instance;
            continue;
        }
        ++it;
    }
}

void CZoneInstance::ForEachChar(std::function<void(CCharEntity*)> func)
{
    for (auto instance : instanceList)
    {
        for (auto PChar : instance->GetCharList())
        {
            func((CCharEntity*)PChar.second);
        }
    }
}

void CZoneInstance::ForEachCharInstance(CBaseEntity* PEntity, std::function<void(CCharEntity*)> func)
{
    for (auto PChar : PEntity->PInstance->GetCharList())
    {
        func((CCharEntity*)PChar.second);
    }
}

void CZoneInstance::ForEachMobInstance(CBaseEntity* PEntity, std::function<void(CMobEntity*)> func)
{
    for (auto PMob : PEntity->PInstance->m_mobList)
    {
        func((CMobEntity*)PMob.second);
    }
}

CInstance* CZoneInstance::CreateInstance(uint8 instanceid)
{
    // 2026-09-14, ported from Topaz's own !warpassault fix chain (2026-08-18): guard against two
    // live CInstance objects claiming the same instanceid. Normally impossible in real play (an
    // instance only goes away once Failed()/Completed(), at which point ZoneServer()'s sweep
    // erases it), but an instance abandoned without ever completing/failing (e.g. a GM warped out
    // via a GM instance-warp command instead of playing it through) sits in instanceList
    // indefinitely until its own time limit naturally elapses. Re-requesting the same instanceid
    // before that happens used to create a second, colliding CInstance with duplicate entity ids.
    // Only reap it here if it's truly abandoned (no one currently inside) -- never evict real
    // players.
    //
    // 2026-09-14, live-crash-reported (Nyzul Isle Investigation, !wa 51 -- use-after-free in
    // CInstanceLoader::Check() iterating instance->m_mobList): CharListEmpty() alone is NOT proof
    // of abandonment -- a just-created instance is ALSO charlist-empty for its entire async load
    // window (CInstanceLoader::LoadInstance() runs on a background thread; RegisterChar() only
    // ever fires later, via setInstance(), once that load finishes and the player actually enters
    // -- see that function's own comment). Nyzul Isle's real mob roster (172 mobs across every
    // floor) makes this load unusually slow, giving a wide window for a second !wa 51 (e.g. a
    // player retrying because the instance seemed stuck) to race in, see the FIRST instance still
    // sitting there charlist-empty, and delete it out from under its own in-flight
    // CInstanceLoader. That loader's Check() then calls task.get() and dereferences the
    // already-freed CInstance -- the exact use-after-free in the crash report. Added a grace
    // period (using the instance's own GetElapsedTime(), already tracked from construction) so a
    // freshly-created, still-loading instance can never be reaped this way regardless of charlist
    // state -- 30s is generously longer than any real instance load should ever take.
    auto it = std::find_if(instanceList.begin(), instanceList.end(),
                            [instanceid](CInstance* el) { return el->GetID() == instanceid; });
    if (it != instanceList.end())
    {
        if ((*it)->CharListEmpty() && (*it)->GetElapsedTime(server_clock::now()) > std::chrono::seconds(30))
        {
            ShowWarning(CL_YELLOW "CZoneInstance::CreateInstance: instanceid %u already existed with an empty char list "
                                  "(abandoned without completing/failing) -- erasing stale instance before creating a new one\n" CL_RESET,
                        instanceid);
            delete *it;
            instanceList.erase(it);
        }
        else
        {
            ShowWarning(CL_YELLOW "CZoneInstance::CreateInstance: instanceid %u already exists (active chars, or still "
                                  "within its load grace period) -- creating a second instance with the same id anyway "
                                  "(not evicting real players or an in-flight load)\n" CL_RESET,
                        instanceid);
        }
    }

    CInstance* instance = new CInstance(this, instanceid);
    instanceList.push_back(instance);
    return instance;
}