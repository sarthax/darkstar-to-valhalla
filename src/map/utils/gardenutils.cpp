/*
===========================================================================

  Copyright (c) 2010-2018 Darkstar Dev Teams

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

#include "gardenutils.h"

#include <array>
#include <cmath>
#include <algorithm>
#include <map>
#include <string>
#include <tuple>

#include "../entities/charentity.h"
#include "../item_container.h"
#include "../items/item_flowerpot.h"
#include "../map.h"
#include "../items/item_furnishing.h"
#include "../packets/inventory_item.h"
#include "../packets/inventory_finish.h"
#include "../packets/furniture_interact.h"
#include "../vana_time.h"

#define MAX_RESULTID 2500

constexpr uint32 VANADAY_SECONDS            = 3456;
constexpr uint32 VANADAYS_TO_WILT           = 36;
constexpr uint32 VANADAYS_TO_GUARANTEE_WILT = 144;
constexpr uint32 VANATIME_FOR_WILT_STAGE    = 65535 * VANADAY_SECONDS;

std::map<uint32, GardenResultList_t> g_pGardenResultMap; // global map of gardening results

GardenResult_t::GardenResult_t() = default;
GardenResult_t::GardenResult_t(uint16 ItemID, uint8 MinQuantity, uint8 MaxQuantity, uint8 Weight)
: ItemID(ItemID)
, MinQuantity(MinQuantity)
, MaxQuantity(MaxQuantity)
, Weight(Weight)
{
}

namespace gardenutils
{
    void LoadResultList()
    {
        int32 ret = Sql_Query(SqlHandle, "SELECT resultId, seed, element1, element2, result, min_quantity, max_quantity, weight FROM gardening_results");

        if (ret != SQL_ERROR && Sql_NumRows(SqlHandle) != 0)
        {
            while (Sql_NextRow(SqlHandle) == SQL_SUCCESS)
            {
                uint8 SeedID   = (uint8)Sql_GetUIntData(SqlHandle, 1);
                uint8 Element1 = (uint8)Sql_GetUIntData(SqlHandle, 2);
                uint8 Element2 = (uint8)Sql_GetUIntData(SqlHandle, 3);

                uint32 uid = (SeedID << 8) + (Element1 << 4) + Element2;

                GardenResultList_t& resultList = g_pGardenResultMap[uid];

                uint16 ItemID      = (uint16)Sql_GetIntData(SqlHandle, 4);
                uint8  MinQuantity = (uint8)Sql_GetIntData(SqlHandle, 5);
                uint8  MaxQuantity = (uint8)Sql_GetIntData(SqlHandle, 6);
                uint8  Weight      = (uint8)Sql_GetIntData(SqlHandle, 7);
                resultList.emplace_back(ItemID, MinQuantity, MaxQuantity, Weight);
            }
        }
    }

    void Initialize()
    {
        LoadResultList();
    }

    void UpdateGardening(CCharEntity* PChar, bool sendPacket)
    {
        uint32 vanatime = CVanaTime::getInstance()->getVanaTime();
        for (auto containerID : { LOC_MOGSAFE, LOC_MOGSAFE2 })
        {
            CItemContainer* PContainer = PChar->getStorage(containerID);
            for (int slotID = 0; slotID < PContainer->GetSize(); ++slotID)
            {
                CItem* PItem = PContainer->GetItem(slotID);
                if (PItem != nullptr && PItem->isType(ITEM_FURNISHING))
                {
                    CItemFlowerpot* PPotItem = static_cast<CItemFlowerpot*>(PItem);
                    if (PPotItem != nullptr && PPotItem->canGrow() && vanatime >= PPotItem->getStageTimestamp())
                    {
                        uint8  stageDuration        = GetStageDuration(PPotItem);
                        uint32 daysSinceStageChange = (vanatime - PPotItem->getStageTimestamp()) / VANADAY_SECONDS;
                        // DSP has no Moghancement/GARDENING_WILT_BONUS mod yet, so no wilt bonus applies
                        uint8  wiltTime             = VANADAYS_TO_WILT;
                        bool   wasExamined          = PPotItem->wasExamined();
                        if ((!wasExamined && (stageDuration > wiltTime || (stageDuration + daysSinceStageChange > wiltTime))) ||
                            daysSinceStageChange > VANADAYS_TO_GUARANTEE_WILT + wiltTime)
                        {
                            PPotItem->setStage(FLOWERPOT_STAGE_WILTED);
                            PPotItem->setStageTimestamp(vanatime + VANATIME_FOR_WILT_STAGE);
                        }
                        else
                        {
                            GrowToNextStage(PPotItem);
                        }

                        PPotItem->clearExamined();

                        char extra[sizeof(PItem->m_extra) * 2 + 1];
                        Sql_EscapeStringLen(SqlHandle, extra, (const char*)PItem->m_extra, sizeof(PItem->m_extra));
                        const char* Query = "UPDATE char_inventory SET extra = '%s' WHERE charid = %u AND location = %u AND slot = %u";
                        Sql_Query(SqlHandle, Query, extra, PChar->id, containerID, slotID);

                        if (sendPacket)
                        {
                            PChar->pushPacket(new CInventoryItemPacket(PPotItem, containerID, slotID));
                        }
                    }
                }
            }
        }
    }

    std::tuple<uint16, uint8> CalculateResults(CCharEntity* PChar, CItemFlowerpot* PItem)
    {
        std::array<uint8, 9> elements = { 0 };
        elements[PItem->getCommonCrystalFeed()] += 10;
        if (PItem->isTree())
        {
            elements[PItem->getExtraCrystalFeed()] += 10;
        }

        switch (PItem->getPlant())
        {
            case FLOWERPOT_PLANT_HERB_SEEDS:
                elements[FLOWERPOT_ELEMENT_WIND] += 10;
                break;
            case FLOWERPOT_PLANT_GRAIN_SEEDS:
                elements[FLOWERPOT_ELEMENT_FIRE] += 10;
                break;
            case FLOWERPOT_PLANT_VEGETABLE_SEEDS:
                elements[FLOWERPOT_ELEMENT_EARTH] += 10;
                break;
            case FLOWERPOT_PLANT_FRUIT_SEEDS:
                elements[FLOWERPOT_ELEMENT_WATER] += 10;
                break;
            case FLOWERPOT_PLANT_CACTUS_STEMS:
                elements[FLOWERPOT_ELEMENT_LIGHT] += 10;
                break;
            case FLOWERPOT_PLANT_TREE_CUTTINGS:
                elements[FLOWERPOT_ELEMENT_ICE] += 10;
                break;
            case FLOWERPOT_PLANT_TREE_SAPLINGS:
                elements[FLOWERPOT_ELEMENT_DARK] += 10;
                break;
            case FLOWERPOT_PLANT_WILDGRASS_SEEDS:
                elements[FLOWERPOT_ELEMENT_LIGHTNING] += 10;
                break;
            default:
                elements[FLOWERPOT_ELEMENT_NONE] += 10;
                break;
        }

        if (map_config.garden_day_matters)
        {
            // The plant timestamp is in earth seconds since the SE epoch; convert it to vana minutes
            // the same way CVanaTime::updateVanaTime does before taking the weekday.
            uint32 vanaDate = (uint32)(PItem->getPlantTimestamp() / 60.0 * 25) + 886 * VTIME_YEAR;
            uint32 weekday  = (vanaDate % VTIME_WEEK) / VTIME_DAY;
            // Weekday order (Fire, Earth, Water, Wind, Ice, Lightning, Light, Dark) is not the
            // FLOWERPOT_ELEMENT_TYPE order, so map it explicitly.
            static const FLOWERPOT_ELEMENT_TYPE dayElements[8] = {
                FLOWERPOT_ELEMENT_FIRE, FLOWERPOT_ELEMENT_EARTH, FLOWERPOT_ELEMENT_WATER, FLOWERPOT_ELEMENT_WIND,
                FLOWERPOT_ELEMENT_ICE, FLOWERPOT_ELEMENT_LIGHTNING, FLOWERPOT_ELEMENT_LIGHT, FLOWERPOT_ELEMENT_DARK
            };
            elements[dayElements[weekday]] += 10;
        }

        if (map_config.garden_pot_matters)
        {
            switch (PItem->getID())
            {
                case 216: // Porcelain Flowerpot
                    elements[FLOWERPOT_ELEMENT_WIND] += 10;
                    break;
                case 217: // Brass Flowerpot
                    elements[FLOWERPOT_ELEMENT_FIRE] += 10;
                    break;
                case 218: // Earthen Flowerpot
                    elements[FLOWERPOT_ELEMENT_EARTH] += 10;
                    break;
                case 219: // Ceramic Flowerpot
                    elements[FLOWERPOT_ELEMENT_WATER] += 10;
                    break;
                case 220: // Wooden Flowerpot
                    elements[FLOWERPOT_ELEMENT_LIGHT] += 10;
                    break;
                case 221: // Arcane Flowerpot
                    elements[FLOWERPOT_ELEMENT_DARK] += 10;
                    break;
                default:
                    break;
            }
        }

        int16 strength = 0;
        if (PItem->getCommonCrystalFeed() == FLOWERPOT_ELEMENT_NONE)
        {
            for (uint8 element : elements)
            {
                if (element > strength)
                {
                    strength = element;
                }
            }
        }
        else
        {
            strength = elements[PItem->getCommonCrystalFeed()];
        }
        if (PItem->isTree())
        {
            if (PItem->getExtraCrystalFeed() == FLOWERPOT_ELEMENT_NONE)
            {
                uint16 best = 0;
                for (uint8 element : elements)
                {
                    if (element > best)
                    {
                        best = element;
                    }
                }
                strength += best;
            }
            else
            {
                strength += elements[PItem->getExtraCrystalFeed()];
            }
        }

        if (map_config.garden_moonphase_matters)
        {
            strength += (int16)std::ceil(CVanaTime::getInstance()->getMoonPhase() / 10.0f);
        }

        if (map_config.garden_mh_aura_matters)
        {
            // Add up all of the installed furniture auras. DSP stores furnishing elements 0-based
            // (0 = Fire ... 7 = Dark), unlike Topaz/LSB's 1-based values.
            std::array<uint16, 8> auras = { 0 };
            for (auto containerID : { LOC_MOGSAFE, LOC_MOGSAFE2 })
            {
                CItemContainer* PContainer = PChar->getStorage(containerID);
                for (int slotID = 0; slotID < PContainer->GetSize(); ++slotID)
                {
                    CItem* POther = PContainer->GetItem(slotID);
                    if (POther != nullptr && POther->isType(ITEM_FURNISHING))
                    {
                        CItemFurnishing* PFurniture = static_cast<CItemFurnishing*>(POther);
                        if (PFurniture->isInstalled() && PFurniture->getElement() < auras.size())
                        {
                            auras[PFurniture->getElement()] += PFurniture->getAura();
                        }
                    }
                }
            }

            // Determine the dominant aura
            uint16 dominantAura = 0;
            for (uint8 elementID = 0; elementID < 8; ++elementID)
            {
                dominantAura = std::max(auras[elementID], dominantAura);
            }
            strength += dominantAura / 10;
        }

        strength += (int16)((100 - strength) * (PItem->getStrength() / 32.0f));

        uint32 resultUid = (PItem->getPlant() << 8) + (PItem->getCommonCrystalFeed() << 4) + PItem->getExtraCrystalFeed();

        GardenResult_t      item;
        uint16              cumulativeWeight = 0;
        GardenResultList_t& resultList       = g_pGardenResultMap[resultUid];
        for (GardenResult_t& result : resultList)
        {
            cumulativeWeight += result.Weight;
            if (strength < cumulativeWeight)
            {
                item = result;
                break;
            }
        }
        if (item.ItemID == 0)
        {
            if (resultList.empty())
            {
                return std::make_tuple((uint16)0, (uint8)0);
            }
            item = resultList.back();
        }

        float percentage = (strength - (cumulativeWeight - item.Weight)) / float(item.Weight);
        uint8 quantity   = item.MinQuantity + int((item.MaxQuantity - item.MinQuantity) * percentage + 0.1);

        return std::make_tuple(item.ItemID, quantity);
    }

    void GrowToNextStage(CItemFlowerpot* PItem, bool growFromFeed /*= false*/)
    {
        switch (PItem->getStage())
        {
            case FLOWERPOT_STAGE_EMPTY:
                PItem->setStage(FLOWERPOT_STAGE_INITIAL);
                break;
            case FLOWERPOT_STAGE_INITIAL:
                PItem->setStage(FLOWERPOT_STAGE_FIRST_SPROUTS);
                break;
            case FLOWERPOT_STAGE_FIRST_SPROUTS:
                if (PItem->isTree())
                {
                    PItem->setStage(FLOWERPOT_STAGE_FIRST_SPROUTS_2);
                }
                else
                {
                    PItem->setStage(FLOWERPOT_STAGE_SECOND_SPROUTS_2);
                }
                break;
            case FLOWERPOT_STAGE_FIRST_SPROUTS_2:
                PItem->setStage(FLOWERPOT_STAGE_FIRST_SPROUTS_CRYSTAL);
                break;
            case FLOWERPOT_STAGE_FIRST_SPROUTS_CRYSTAL:
                PItem->setStage(FLOWERPOT_STAGE_SECOND_SPROUTS);
                break;
            case FLOWERPOT_STAGE_SECOND_SPROUTS:
                PItem->setStage(FLOWERPOT_STAGE_SECOND_SPROUTS_2);
                break;
            case FLOWERPOT_STAGE_SECOND_SPROUTS_2:
                PItem->setStage(FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL);
                break;
            case FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL:
                PItem->setStage(FLOWERPOT_STAGE_SECOND_SPROUTS_3);
                break;
            case FLOWERPOT_STAGE_SECOND_SPROUTS_3:
                PItem->setStage(FLOWERPOT_STAGE_THIRD_SPROUTS);
                break;
            case FLOWERPOT_STAGE_THIRD_SPROUTS:
                PItem->setStage(FLOWERPOT_STAGE_MATURE_PLANT);
                break;
            case FLOWERPOT_STAGE_MATURE_PLANT:
            case FLOWERPOT_STAGE_WILTED:
            default:
                break;
        }

        PItem->setStageTimestamp(CVanaTime::getInstance()->getVanaTime() + GetStageDuration(PItem, growFromFeed) * VANADAY_SECONDS);
    }

    uint8 GetStageDuration(CItemFlowerpot* PItem, bool growFromFeed /*= false*/)
    {
        switch (PItem->getPlant())
        {
            case FLOWERPOT_PLANT_FRUIT_SEEDS:
                switch (PItem->getStage())
                {
                    case FLOWERPOT_STAGE_EMPTY:
                        return 1;
                    case FLOWERPOT_STAGE_INITIAL:
                        return 8;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS:
                        return 10;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS_2:
                        return 12;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS_CRYSTAL:
                        return 50;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS:
                        return growFromFeed ? 18 : 4;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_2:
                        return 14;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL:
                        return 52;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_3:
                        return growFromFeed ? 16 : 4;
                    case FLOWERPOT_STAGE_THIRD_SPROUTS:
                        return 20;
                    case FLOWERPOT_STAGE_MATURE_PLANT:
                        return 187;
                    default:
                        break;
                }
                break;
            case FLOWERPOT_PLANT_HERB_SEEDS:
                switch (PItem->getStage())
                {
                    case FLOWERPOT_STAGE_INITIAL:
                        return 9;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS:
                        return 4;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_2:
                        return 12;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL:
                        return 50;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_3:
                        return growFromFeed ? 24 : 4;
                    case FLOWERPOT_STAGE_THIRD_SPROUTS:
                        return 30;
                    case FLOWERPOT_STAGE_MATURE_PLANT:
                        return 187;
                    default:
                        break;
                }
                break;
            case FLOWERPOT_PLANT_GRAIN_SEEDS:
                switch (PItem->getStage())
                {
                    case FLOWERPOT_STAGE_INITIAL:
                        return 1;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS:
                        return 2;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_2:
                        return 6;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL:
                        return 62;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_3:
                        return growFromFeed ? 24 : 4;
                    case FLOWERPOT_STAGE_THIRD_SPROUTS:
                        return 36;
                    case FLOWERPOT_STAGE_MATURE_PLANT:
                        return 187;
                    default:
                        break;
                }
                break;
            case FLOWERPOT_PLANT_VEGETABLE_SEEDS:
                switch (PItem->getStage())
                {
                    case FLOWERPOT_STAGE_INITIAL:
                        return 18;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS:
                        return 4;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_2:
                        return 2;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL:
                        return 56;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_3:
                        return growFromFeed ? 16 : 1;
                    case FLOWERPOT_STAGE_THIRD_SPROUTS:
                        return 30;
                    case FLOWERPOT_STAGE_MATURE_PLANT:
                        return 187;
                    default:
                        break;
                }
                break;
            case FLOWERPOT_PLANT_CACTUS_STEMS:
                switch (PItem->getStage())
                {
                    case FLOWERPOT_STAGE_EMPTY:
                        return 18;
                    case FLOWERPOT_STAGE_INITIAL:
                        return 26;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS:
                        return 42;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS_2:
                        return 74;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS_CRYSTAL:
                        return 72;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS:
                        return growFromFeed ? 40 : 4;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_2:
                        return 48;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL:
                        return 72;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_3:
                        return growFromFeed ? 52 : 4;
                    case FLOWERPOT_STAGE_THIRD_SPROUTS:
                        return 72;
                    case FLOWERPOT_STAGE_MATURE_PLANT:
                        return 187;
                    default:
                        break;
                }
                break;
            case FLOWERPOT_PLANT_TREE_CUTTINGS:
                switch (PItem->getStage())
                {
                    case FLOWERPOT_STAGE_EMPTY:
                        return 24;
                    case FLOWERPOT_STAGE_INITIAL:
                        return 30;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS:
                        return 40;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS_2:
                        return 74;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS_CRYSTAL:
                        return 72;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS:
                        return growFromFeed ? 48 : 8;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_2:
                        return 52;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL:
                        return 72;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_3:
                        return growFromFeed ? 54 : 8;
                    case FLOWERPOT_STAGE_THIRD_SPROUTS:
                        return 60;
                    case FLOWERPOT_STAGE_MATURE_PLANT:
                        return 187;
                    default:
                        break;
                }
                break;
            case FLOWERPOT_PLANT_TREE_SAPLINGS:
                switch (PItem->getStage())
                {
                    case FLOWERPOT_STAGE_EMPTY:
                        return 40;
                    case FLOWERPOT_STAGE_INITIAL:
                        return 48;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS:
                        return 62;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS_2:
                        return 74;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS_CRYSTAL:
                        return 80;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS:
                        return growFromFeed ? 60 : 22;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_2:
                        return 80;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL:
                        return 86;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_3:
                        return growFromFeed ? 64 : 26;
                    case FLOWERPOT_STAGE_THIRD_SPROUTS:
                        return 108;
                    case FLOWERPOT_STAGE_MATURE_PLANT:
                        return 187;
                    default:
                        break;
                }
                break;
            case FLOWERPOT_PLANT_WILDGRASS_SEEDS:
                switch (PItem->getStage())
                {
                    case FLOWERPOT_STAGE_INITIAL:
                        return 12;
                    case FLOWERPOT_STAGE_FIRST_SPROUTS:
                        return 18;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_2:
                        return 28;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_CRYSTAL:
                        return 62;
                    case FLOWERPOT_STAGE_SECOND_SPROUTS_3:
                        return growFromFeed ? 36 : 4;
                    case FLOWERPOT_STAGE_THIRD_SPROUTS:
                        return 46;
                    case FLOWERPOT_STAGE_MATURE_PLANT:
                        return 187;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
        return 0;
    }

    namespace
    {
        const char* STAGE_NAMES[] = { "EMPTY", "INITIAL", "FIRST_SPROUTS", "FIRST_SPROUTS_2", "FIRST_SPROUTS_CRYSTAL", "SECOND_SPROUTS",
                                      "SECOND_SPROUTS_2", "SECOND_SPROUTS_CRYSTAL", "SECOND_SPROUTS_3", "THIRD_SPROUTS", "MATURE_PLANT", "WILTED" };

        void SavePot(CCharEntity* PChar, CItemFlowerpot* PPot, uint8 containerID, uint8 slotID)
        {
            int8 extra[sizeof(PPot->m_extra) * 2 + 1];
            Sql_EscapeStringLen(SqlHandle, extra, (const int8*)PPot->m_extra, sizeof(PPot->m_extra));
            Sql_Query(SqlHandle, "UPDATE char_inventory SET extra = '%s' WHERE charid = %u AND location = %u AND slot = %u", extra, PChar->id, containerID, slotID);
            PChar->pushPacket(new CInventoryItemPacket(PPot, containerID, slotID));
        }

        std::string Describe(CItemFlowerpot* PPot, uint8 containerID, uint8 slotID)
        {
            uint32 now = CVanaTime::getInstance()->getVanaTime();
            uint32 ts  = PPot->getStageTimestamp();
            char   buf[400];
            snprintf(buf, sizeof(buf),
                     "[c%u s%u] pot %u: plant=%u stage=%u(%s) crystal1=%u crystal2=%u strength=%u dried=%d examined=%d tree=%d nextStageIn=%s%u vanaSec",
                     (uint32)containerID, (uint32)slotID, (uint32)PPot->getID(), (uint32)PPot->getPlant(), (uint32)PPot->getStage(),
                     PPot->getStage() < 12 ? STAGE_NAMES[PPot->getStage()] : "?", (uint32)PPot->getCommonCrystalFeed(),
                     (uint32)PPot->getExtraCrystalFeed(), (uint32)PPot->getStrength(), (int)PPot->isDried(), (int)PPot->wasExamined(),
                     (int)PPot->isTree(), ts > now ? "" : "-", ts > now ? ts - now : now - ts);
            return buf;
        }
    } // namespace

    std::string DebugCommand(CCharEntity* PChar, const std::string& action, int32 value, int32 slotFilter)
    {
        std::string out;
        int         count = 0;
        for (uint8 containerID : { (uint8)LOC_MOGSAFE, (uint8)LOC_MOGSAFE2 })
        {
            CItemContainer* PContainer = PChar->getStorage(containerID);
            for (int slotID = 0; slotID < PContainer->GetSize(); ++slotID)
            {
                CItem* PItem = PContainer->GetItem(slotID);
                if (PItem == nullptr || !PItem->isType(ITEM_FURNISHING) || PItem->getID() < 216 || PItem->getID() > 221)
                {
                    continue;
                }
                if (slotFilter >= 0 && slotFilter != slotID)
                {
                    continue;
                }
                CItemFlowerpot* PPot = static_cast<CItemFlowerpot*>(PItem);
                ++count;
                bool   changed = false;
                uint32 now     = CVanaTime::getInstance()->getVanaTime();

                if (action == "stage")
                {
                    if (value >= 1 && value <= FLOWERPOT_STAGE_WILTED && PPot->getPlant() != FLOWERPOT_PLANT_NONE)
                    {
                        PPot->setStage((FLOWERPOT_STAGE_TYPE)value);
                        PPot->setStageTimestamp(now + GetStageDuration(PPot) * VANADAY_SECONDS);
                        changed = true;
                    }
                }
                else if (action == "grow")
                {
                    if (PPot->getPlant() != FLOWERPOT_PLANT_NONE)
                    {
                        for (int i = 0; i < std::max(1, (int)value); ++i)
                        {
                            GrowToNextStage(PPot);
                        }
                        changed = true;
                    }
                }
                else if (action == "mature")
                {
                    if (PPot->getPlant() != FLOWERPOT_PLANT_NONE)
                    {
                        PPot->setStage(FLOWERPOT_STAGE_MATURE_PLANT);
                        PPot->setStageTimestamp(now + GetStageDuration(PPot) * VANADAY_SECONDS);
                        changed = true;
                    }
                }
                else if (action == "wilt")
                {
                    if (PPot->getPlant() != FLOWERPOT_PLANT_NONE)
                    {
                        PPot->setStage(FLOWERPOT_STAGE_WILTED);
                        PPot->setStageTimestamp(now + VANATIME_FOR_WILT_STAGE);
                        changed = true;
                    }
                }
                else if (action == "ready")
                {
                    // make the current stage due now; the normal tick advances it (feeding stages still wait for a crystal)
                    PPot->setStageTimestamp(now);
                    changed = true;
                }
                else if (action == "plant")
                {
                    if (value >= FLOWERPOT_PLANT_FRUIT_SEEDS && value <= FLOWERPOT_PLANT_WILDGRASS_SEEDS)
                    {
                        PPot->cleanPot();
                        PPot->setPlant((FLOWERPOT_PLANT_TYPE)value);
                        PPot->setPlantTimestamp(now);
                        PPot->setStrength(dsprand::GetRandomNumber(32));
                        GrowToNextStage(PPot);
                        changed = true;
                    }
                }
                else if (action == "clean")
                {
                    PPot->cleanPot();
                    changed = true;
                }
                else if (action == "crystal1" || action == "crystal2")
                {
                    if (value >= 0 && value <= FLOWERPOT_ELEMENT_DARK)
                    {
                        if (action == "crystal1")
                        {
                            PPot->setFirstCrystalFeed((FLOWERPOT_ELEMENT_TYPE)value);
                        }
                        else
                        {
                            PPot->setSecondCrystalFeed((FLOWERPOT_ELEMENT_TYPE)value);
                        }
                        changed = true;
                    }
                }
                else if (action == "strength")
                {
                    if (value >= 0 && value <= 31)
                    {
                        PPot->setStrength((uint8)value);
                        changed = true;
                    }
                }
                else if (action == "dry")
                {
                    PPot->setDried(value != 0);
                    changed = true;
                }
                else if (action == "examined")
                {
                    if (value != 0)
                    {
                        PPot->markExamined();
                    }
                    else
                    {
                        PPot->clearExamined();
                    }
                    changed = true;
                }
                else if (action == "results")
                {
                    uint16 resultID;
                    uint8  qty;
                    std::tie(resultID, qty) = CalculateResults(PChar, PPot);
                    char buf[120];
                    snprintf(buf, sizeof(buf), "[c%u s%u] harvest would give item %u x%u", (uint32)containerID, (uint32)slotID, (uint32)resultID, (uint32)qty);
                    out += std::string(buf) + "\n";
                }
                else if (action != "info")
                {
                    return "unknown action";
                }

                if (changed)
                {
                    SavePot(PChar, PPot, containerID, slotID);
                    PChar->pushPacket(new CFurnitureInteractPacket(PPot, containerID, slotID));
                    PChar->pushPacket(new CInventoryFinishPacket());
                }
                out += Describe(PPot, containerID, slotID) + (changed ? "  (updated)" : "") + "\n";
            }
        }
        if (count == 0)
        {
            return "no flowerpot found in Mog Safe / Safe 2 (or slot filter matched nothing)";
        }
        return out;
    }
} // namespace gardenutils
