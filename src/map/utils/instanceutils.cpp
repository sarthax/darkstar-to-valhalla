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

#include "../instance_loader.h"

#include "instanceutils.h"
#include "zoneutils.h"

#include "../lua/luautils.h"

CInstanceLoader* Loader = nullptr;

namespace instanceutils
{
	void CheckInstance()
	{
		if (Loader)
		{
			if (Loader->Check())
			{
				delete Loader;
				Loader = nullptr;
			}
		}
	}

	void LoadInstance(uint8 instanceid, uint16 zoneid, CCharEntity* PRequester)
	{
        CZone* PZone = zoneutils::GetZone(zoneid);
		// 2026-09-14, live-test debug: Loader is a module-level singleton -- if a previous
		// LoadInstance() call's async task hasn't been reaped by CheckInstance() yet (or never got
		// cleared for any reason), every call here falls straight into the nullptr branch below,
		// SILENTLY (no error logged anywhere) -- suspected real cause of "instances silently not
		// loading" during this session's live integration test.
		ShowDebug(CL_CYAN"instanceutils::LoadInstance: instanceid=%u zoneid=%u requester=%s Loader=%s PZone=%s\n" CL_RESET,
			instanceid, zoneid, PRequester ? PRequester->GetName() : "?",
			Loader ? "BUSY (blocking this call)" : "free", PZone ? "valid" : "NULL");
		if (!Loader && PZone)
		{
			Loader = new CInstanceLoader(instanceid, PZone, PRequester);
		}
		else
		{
			luautils::OnInstanceCreated(PRequester, nullptr);
		}
	}
};