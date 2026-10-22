#include "../../common/socket.h"

#include "w58_ack.h"
#include "w58_handshake.h"

CW58AckPacket::CW58AckPacket(const uint8 sizes[4], const uint16 caps[4])
{
    this->id(W58_PACKET_ID);           // 0x103: the ninth ID bit lives in the size byte, id() handles it
    this->length(W58_ACK_LENGTH);

    std::memcpy(data + 0x04, W58_ACK_MAGIC, 4);
    WBUFW(data, (0x08)) = W58_PROTO_VERSION;
    WBUFW(data, (0x0A)) = 0;           // granted flags: none defined in proto 1
    for (int i = 0; i < 4; ++i)
    {
        WBUFB(data, (0x0C + i)) = sizes[i];
        WBUFW(data, (0x10 + 2 * i)) = caps[i];
    }
}
