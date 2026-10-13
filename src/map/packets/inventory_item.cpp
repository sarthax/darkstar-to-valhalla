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

#include "../../common/socket.h"
#include "../../common/utils.h"

#include <string.h>

#include "inventory_item.h"

#include "../utils/itemutils.h"
#include "../vana_time.h"


CInventoryItemPacket::CInventoryItemPacket(CItem* PItem, uint8 LocationID, uint8 SlotID) 
{
	this->type = 0x20;
	this->size = 0x16;

	WBUFB(data,(0x0E)) = LocationID;
	WBUFB(data,(0x0F)) = SlotID;	

	if (PItem != nullptr)
	{
		WBUFL(data,(0x04)) = PItem->getQuantity();
		WBUFL(data,(0x08)) = PItem->getCharPrice();
		WBUFW(data,(0x0C)) = PItem->getID();
        memcpy(data + 0x11 , PItem->m_extra, sizeof(PItem->m_extra));

		if (PItem->isSubType(ITEM_CHARGED))
		{
			WBUFB(data,(0x11)) = 0x01;

            // Flag byte (matches LandSandBoat's 0x020 item attr packet):
            // 0x80 always set, 0x40 ready to use, 0x20 empty, 0x10 partially depleted.
            // The client refuses to auction an item whose 0x10 bit is set, so it must only
            // be sent when the item really has fewer than its maximum charges.
            CItemUsable* PCharged = (CItemUsable*)PItem;
            uint8 chargeFlags = 0x80;

            if (PCharged->getCurrentCharges() < PCharged->getMaxCharges())
            {
                chargeFlags |= 0x10;
            }

            if (PCharged->getCurrentCharges() > 0)
            {
                if (PCharged->getReuseTime() == 0)
                {
                    chargeFlags |= 0x40;
                }
                else
                {
                    uint32 CurrentTime = CVanaTime::getInstance()->getVanaTime();

                    WBUFL(data,(0x15)) = PCharged->getNextUseTime();
                    WBUFL(data,(0x19)) = PCharged->getUseDelay() + CurrentTime;
                }
            }
            else
            {
                chargeFlags |= 0x20;
            }
            WBUFB(data,(0x14)) = chargeFlags;
		}

        if (PItem->isType(ITEM_WEAPON) && ((CItemWeapon*)PItem)->isUnlockable())
        {
            WBUFW(data, (0x11) ) = 0;
        }

        if (PItem->getCharPrice() != 0)
        {
            WBUFB(data, (0x10) ) = 0x19;
        }
        else if (PItem->isSubType(ITEM_LOCKED))
        {
            if (PItem->isType(ITEM_LINKSHELL))
            {
                WBUFB(data, (0x10) ) = 0x13;
            }
            else
            {
                WBUFB(data, (0x10) ) = 0x05;
            }
        }
        else
        {
            WBUFB(data, (0x10) ) = 0x00;
        }

        if (PItem->isType(ITEM_LINKSHELL))
        {
            WBUFB(data,(0x19)) = ((CItemLinkshell*)PItem)->GetLSType();
        }
	}
}
