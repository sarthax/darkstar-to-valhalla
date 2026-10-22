/*
Egress guard for inventory packets: a legacy (2019) client must never be told about containers 13-16.
Pure functions on raw packet bytes so they can be tested offline (tests/wardrobe5-8/).
*/
#ifndef _CINVENTORYGUARD_H
#define _CINVENTORYGUARD_H

#include "../../common/cbasetypes.h"
#include "../item_container.h"

// Container ID carried by the item packets the 2019 client indexes directly (no <13 check on its side).
// Offsets verified against the DSP packet builders and Toolkit Stage 4: 0x1E +0x08, 0x1F +0x0A, 0x20 +0x0E.
// Returns false for other packet types.
inline bool InventoryPacketContainer(uint16 type, const uint8* data, uint8* container)
{
    switch (type)
    {
        case 0x1E: *container = data[0x08]; return true;
        case 0x1F: *container = data[0x0A]; return true;
        case 0x20: *container = data[0x0E]; return true;
    }
    return false;
}

// True if this packet must NOT be sent to a session with the given capability.
inline bool InventoryPacketBlocked(uint16 type, const uint8* data, bool extendedSession)
{
    uint8 container = 0;
    return InventoryPacketContainer(type, data, &container) && !IsValidContainerID(container, extendedSession);
}

#endif
