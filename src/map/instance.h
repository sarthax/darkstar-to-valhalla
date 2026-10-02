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

#ifndef _CINSTANCE_H
#define _CINSTANCE_H

#include "zone_entities.h"

#include <map>
#include <set>
#include <string>

enum INSTANCE_STATUS
{
    INSTANCE_NORMAL,
    INSTANCE_FAILED,
    INSTANCE_COMPLETE
};

class CInstance : public CZoneEntities
{
public:

    void RegisterChar(CCharEntity*);

    uint8 GetID();
    uint8 GetLevelCap();
    const int8* GetName();
    position_t GetEntryLoc();								// Get entry location
    duration GetTimeLimit();								// Get instance time limit
    duration GetLastTimeUpdate();							// Get last time a "Time Remaining:" message was displayed
    uint32 GetProgress();									// Tracks the progress through the current stage
    uint32 GetStage();										// Tracks the progress through the instance (eg. floor #)
    uint32 GetLocalVar(const char* var);					// Gets an arbitrary named value scoped to this instance run
    void SetLocalVar(const char* var, uint32 val);			// Sets an arbitrary named value scoped to this instance run
    void ResetLocalVars();									// Clears all instance-scoped named values
    time_point GetWipeTime();									// Stores elapsed time when a wipe is detected
    duration GetElapsedTime(time_point tick);					// Get elapsed time so far

    void SetLevelCap(uint8 cap);
    void SetEntryLoc(float x, float y, float z, float rot); // Set entry location
    void SetLastTimeUpdate(duration time);				// Set last time a "Time Remaining:" message was displayed
    void SetProgress(uint32 progress);						// Set progress through current stage
    void SetStage(uint32 stage);							// Set current stage (eg. floor #)
    void SetWipeTime(time_point time);							// Set elapsed time when a wipe is detected

    void CheckTime(time_point tick);							// Check time limit (run instance time script)
    bool CharRegistered(CCharEntity* PChar);				// Check if PChar is registered to this instance
    void ClearEntities();
    void Fail();											// Fails the instance (onInstanceFailure)
    bool Failed();											// Checks if instance is failed
    void Complete();										// Completes the instance (onInstanceComplete)
    bool Completed();										// Checks if instance is completed
    void Cancel();											// Sets instance to fail without calling onInstanceFailure
    bool CheckFirstEntry(uint32 id);                             // Checks if this is the first time a char is entering

    // 2026-09-16, crash-reported (zone-in): CInstance is pushed onto CZoneInstance::instanceList
    // (and so becomes visible to CZoneInstance::ZoneServer's per-tick loop, on the main thread)
    // synchronously, BEFORE CInstanceLoader::LoadInstance's background thread has finished
    // populating m_mobList/m_npcList via InsertMOB/InsertNPC. ZoneServer's tick iterates those
    // same maps unsynchronized with the loader thread's concurrent inserts -- a data race on
    // std::map that can corrupt/crash anywhere inside it, e.g. FindPartyForMob's m_mobList walk.
    // IsLoading() lets ZoneServer skip a not-yet-loaded instance entirely; CInstanceLoader::Check()
    // clears it only after task.get() returns, i.e. once the background thread is fully done and
    // synchronized back to the main thread.
    bool IsLoading();
    void SetLoading(bool loading);

    uint8           GetSoloBattleMusic();
    uint8           GetPartyBattleMusic();
    uint8           GetBackgroundMusicDay();
    uint8           GetBackgroundMusicNight();

    CInstance(CZone*, uint8 instanceid);
    ~CInstance();

private:
    void LoadInstance();

    uint8 m_instanceid {0};
    uint16 m_entrance {0};
    string_t m_instanceName;
    uint32 m_commander {0};
    uint8 m_levelcap {0};
    duration m_timeLimit {duration::zero()};
    time_point m_startTime;
    duration m_lastTimeUpdate {duration::zero()};
    time_point m_lastTimeCheck;
    time_point m_wipeTimer;
    uint32 m_progress {0};
    uint32 m_stage {0};
    position_t m_entryloc {};
    zoneMusic_t m_zone_music_override {};
    INSTANCE_STATUS m_status {INSTANCE_NORMAL};
    bool m_loading {true};
    std::vector<uint32> m_registeredChars;
    std::set<uint32> m_enteredChars;
    std::map<std::string, uint32> m_localVars;				// Instance-scoped named values (see Get/SetLocalVar) -- same pattern as CBaseEntity::m_localVars
};

#endif