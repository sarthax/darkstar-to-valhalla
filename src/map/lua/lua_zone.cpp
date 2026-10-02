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

#include "../../common/showmsg.h"

#include "../region.h"

#include "lua_zone.h"
#include "lua_baseentity.h"
#include "../zone.h"
#include "../entities/charentity.h"

/************************************************************************
*																		*
*  Конструктор															*
*																		*
************************************************************************/

CLuaZone::CLuaZone(lua_State *L)
{
    if (!lua_isnil(L, -1))
    {
        m_pLuaZone = (CZone*)(lua_touserdata(L, -1));
        lua_pop(L, 1);
    }
    else
    {
        m_pLuaZone = nullptr;
    }
}

/************************************************************************
*																		*
*  Конструктор															*
*																		*
************************************************************************/

CLuaZone::CLuaZone(CZone* PZone)
{
    m_pLuaZone = PZone;
}

/************************************************************************
*																		*
*  Регистрируем активную область в зоне									*
*  Формат входных данных: RegionID, x1, y1, z1, x2, y2, z2				*
*																		*
************************************************************************/

inline int32 CLuaZone::registerRegion(lua_State *L)
{
    if (m_pLuaZone != nullptr)
    {
        if (!lua_isnil(L, 1) && lua_isnumber(L, 1) &&
            !lua_isnil(L, 2) && lua_isnumber(L, 2) &&
            !lua_isnil(L, 3) && lua_isnumber(L, 3) &&
            !lua_isnil(L, 4) && lua_isnumber(L, 4) &&
            !lua_isnil(L, 5) && lua_isnumber(L, 5) &&
            !lua_isnil(L, 6) && lua_isnumber(L, 6) &&
            !lua_isnil(L, 7) && lua_isnumber(L, 7))
        {
            bool circleRegion = false;
            if (lua_tointeger(L, 5) == 0 && lua_tointeger(L, 6) == 0 && lua_tointeger(L, 7) == 0)
                circleRegion = true; // Parameters were 0, we must be a circle.

            CRegion* Region = new CRegion(lua_tointeger(L, 1), circleRegion);

            // If this is a circle, parameter 3 (which would otherwise be vertical coordinate) will be the radius.
            Region->SetULCorner(lua_tointeger(L, 2), lua_tointeger(L, 3), lua_tointeger(L, 4));
            Region->SetLRCorner(lua_tointeger(L, 5), lua_tointeger(L, 6), lua_tointeger(L, 7));

            m_pLuaZone->InsertRegion(Region);
        }
        else
        {
            ShowWarning(CL_YELLOW"Region cannot be registered. Please check the parameters.\n" CL_RESET);
        }
    }
    lua_pushnil(L);
    return 1;
}

/************************************************************************
*																		*
*  Устанавливаем ограничение уровня для зоны							*
*																		*
************************************************************************/

inline int32 CLuaZone::levelRestriction(lua_State *L)
{
    if (m_pLuaZone != nullptr)
    {

    }
    lua_pushnil(L);
    return 1;
}

inline int32 CLuaZone::getPlayers(lua_State* L)
{
    DSP_DEBUG_BREAK_IF(m_pLuaZone == nullptr);

    lua_newtable(L);
    int newTable = lua_gettop(L);

    m_pLuaZone->ForEachChar([&L, &newTable](CCharEntity* PChar) {
        lua_getglobal(L, CLuaBaseEntity::className);
        lua_pushstring(L, "new");
        lua_gettable(L, -2);
        lua_insert(L, -2);
        lua_pushlightuserdata(L, (void*)PChar);
        lua_pcall(L, 2, 1, 0);
        lua_setfield(L, newTable, PChar->GetName());
    });

    return 1;
}

inline int32 CLuaZone::getID(lua_State* L)
{
    DSP_DEBUG_BREAK_IF(m_pLuaZone == nullptr);

    lua_pushinteger(L, m_pLuaZone->GetID());

    return 1;
}

inline int32 CLuaZone::getRegionID(lua_State* L)
{
    DSP_DEBUG_BREAK_IF(m_pLuaZone == nullptr);

    lua_pushinteger(L, m_pLuaZone->GetRegionID());

    return 1;
}

/************************************************************************
*  Function: checkNavPath()
*  Purpose : DSP-PORT: diagnostic -- queries this zone's real navmesh directly for whether a
*            path exists between two points, bypassing any visual/animation state entirely.
*            Ported from Topaz's own CLuaZone::checkNavPath()
*            (src/map/lua/lua_zone.cpp:81) -- old-dsp-reference's underlying navmesh engine
*            (src/map/navmesh.h/.cpp, CNavMesh::findPath()/validPosition()) already exists and
*            matches Topaz's own shape (same CZone::m_navMesh field, same CNavMesh API), so
*            this is a Lua-binding-only addition, not new engine work.
*  Example : local found, waypoints = zone:checkNavPath(x1,y1,z1,x2,y2,z2)
************************************************************************/

inline int32 CLuaZone::checkNavPath(lua_State* L)
{
    DSP_DEBUG_BREAK_IF(m_pLuaZone == nullptr);
    DSP_DEBUG_BREAK_IF(lua_isnil(L, 1) || !lua_isnumber(L, 1));
    DSP_DEBUG_BREAK_IF(lua_isnil(L, 2) || !lua_isnumber(L, 2));
    DSP_DEBUG_BREAK_IF(lua_isnil(L, 3) || !lua_isnumber(L, 3));
    DSP_DEBUG_BREAK_IF(lua_isnil(L, 4) || !lua_isnumber(L, 4));
    DSP_DEBUG_BREAK_IF(lua_isnil(L, 5) || !lua_isnumber(L, 5));
    DSP_DEBUG_BREAK_IF(lua_isnil(L, 6) || !lua_isnumber(L, 6));

    if (m_pLuaZone->m_navMesh == nullptr)
    {
        lua_pushboolean(L, false);
        lua_pushinteger(L, 0);
        return 2;
    }

    position_t start{}; start.x = (float)lua_tonumber(L, 1); start.y = (float)lua_tonumber(L, 2); start.z = (float)lua_tonumber(L, 3); // DSP position_t order is rotation,x,y,z,moving -- brace-init mis-assigned
    position_t end{}; end.x = (float)lua_tonumber(L, 4); end.y = (float)lua_tonumber(L, 5); end.z = (float)lua_tonumber(L, 6);

    auto path = m_pLuaZone->m_navMesh->findPath(start, end);

    lua_pushboolean(L, !path.empty());
    lua_pushinteger(L, (lua_Integer)path.size());
    return 2;
}

/************************************************************************
*  Function: checkNavPosition()
*  Purpose : DSP-PORT: diagnostic -- checks whether a single point is close enough to any
*            navmesh polygon to be a valid reference point at all. Ported from Topaz's own
*            CLuaZone::checkNavPosition() (src/map/lua/lua_zone.cpp:111), wraps
*            CNavMesh::validPosition() (already implemented in old-dsp-reference's
*            navmesh.cpp, just not previously exposed to Lua).
*  Example : local valid = zone:checkNavPosition(x,y,z)
************************************************************************/

inline int32 CLuaZone::checkNavPosition(lua_State* L)
{
    DSP_DEBUG_BREAK_IF(m_pLuaZone == nullptr);
    DSP_DEBUG_BREAK_IF(lua_isnil(L, 1) || !lua_isnumber(L, 1));
    DSP_DEBUG_BREAK_IF(lua_isnil(L, 2) || !lua_isnumber(L, 2));
    DSP_DEBUG_BREAK_IF(lua_isnil(L, 3) || !lua_isnumber(L, 3));

    if (m_pLuaZone->m_navMesh == nullptr)
    {
        lua_pushboolean(L, false);
        return 1;
    }

    position_t pos{}; pos.x = (float)lua_tonumber(L, 1); pos.y = (float)lua_tonumber(L, 2); pos.z = (float)lua_tonumber(L, 3);
    lua_pushboolean(L, m_pLuaZone->m_navMesh->validPosition(pos));
    return 1;
}

/************************************************************************
*																		*
*  Инициализация методов в lua											*
*																		*
************************************************************************/

const int8 CLuaZone::className[] = "CZone";
Lunar<CLuaZone>::Register_t CLuaZone::methods[] =
{
    LUNAR_DECLARE_METHOD(CLuaZone,levelRestriction),
    LUNAR_DECLARE_METHOD(CLuaZone,registerRegion),
    LUNAR_DECLARE_METHOD(CLuaZone,getPlayers),
    LUNAR_DECLARE_METHOD(CLuaZone,getID),
    LUNAR_DECLARE_METHOD(CLuaZone,getRegionID),
    LUNAR_DECLARE_METHOD(CLuaZone,checkNavPath),
    LUNAR_DECLARE_METHOD(CLuaZone,checkNavPosition),
    {nullptr,nullptr}
};