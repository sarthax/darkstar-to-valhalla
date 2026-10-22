/*
Server->client acknowledgement of the Wardrobe 5-8 handshake (packet 0x103, 24 bytes).
Layout: see w58_handshake.h. Only ever sent to a session that passed W58Decide().
*/
#ifndef _CW58ACKPACKET_H
#define _CW58ACKPACKET_H

#include "../../common/cbasetypes.h"
#include "basic.h"

class CW58AckPacket : public CBasicPacket
{
public:
    // sizes/caps are already in the 0x1C convention: 1 + GetSize(), 1 + GetBuff(), for Wardrobe 5, 6, 7, 8.
    CW58AckPacket(const uint8 sizes[4], const uint16 caps[4]);
};

#endif
