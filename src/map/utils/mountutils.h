/*
===========================================================================

  Adapted from LandSandBoat (src/map/utils/mountutils.h)
  Copyright (c) 2026 LandSandBoat Dev Teams

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

===========================================================================
*/

#ifndef _MOUNTUTILS_H
#define _MOUNTUTILS_H

#include "../../common/cbasetypes.h"

// Packed appearance/speed/time word for a personal (raised) chocobo.
// Bit layout is from LandSandBoat and is NOT yet verified against this client build (CLIENT_VER 30170905_5);
// it is only used to store and round-trip registerChocobo()/getFieldChocobo() data until the mount
// packet phase validates it against a capture.
struct ChocoboCustomProperties
{
    union
    {
        uint32 properties;

        struct
        {
            uint32 largeBeak : 1;
            uint32 unknown1 : 1;
            uint32 unknown2 : 1;
            uint32 largeTalons : 1;
            uint32 unknown4 : 1;
            uint32 unknown5 : 1;
            uint32 fullTail : 1;
            uint32 unknown7 : 1;
            uint32 unknown8 : 1;
            uint32 color : 3;
            uint32 speed : 7;
            uint32 minutes : 6;
            uint32 unknown25 : 7;
        };
    };
};

static_assert(sizeof(ChocoboCustomProperties) == sizeof(uint32), "ChocoboCustomProperties must stay one 32 bit word");

// StatusEffect subpower of EFFECT_MOUNTED marking a ride on the player's registered chocobo (LandSandBoat value).
constexpr uint16 kPersonalChocoboFlag = 0x40;

#endif
