/*	EQEMu: Everquest Server Emulator
	Copyright (C) 2001-2003 EQEMu Development Team (http://eqemulator.net)

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; version 2 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY except by those people which sell it, which
	are required to give you total support for your newly bought product;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR
	A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#include "debug.h"
#include "StringUtil.h"
#include "Item.h"
#include "database.h"
#include "misc.h"
#include "races.h"
#include "shareddb.h"
#include "classes.h"

#include <limits.h>

#include <sstream>
#include <iostream>

std::list<ItemInst*> dirty_inst;
int32 NextItemInstSerialNumber = 1;

static inline int32 GetNextItemInstSerialNumber() {

	// The Bazaar relies on each item a client has up for Trade having a unique
	// identifier. This 'SerialNumber' is sent in Serialized item packets and
	// is used in Bazaar packets to identify the item a player is buying or inspecting.
	//
	// E.g. A trader may have 3 Five dose cloudy potions, each with a different number of remaining charges
	// up for sale with different prices.
	//
	// NextItemInstSerialNumber is the next one to hand out.
	//
	// It is very unlikely to reach 2,147,483,647. Maybe we should call abort(), rather than wrapping back to 1.
	if(NextItemInstSerialNumber >= INT_MAX)
		NextItemInstSerialNumber = 1;
	else
		NextItemInstSerialNumber++;

	return NextItemInstSerialNumber;
}

EvolveInfo::EvolveInfo() {
	// nothing here yet
}

EvolveInfo::EvolveInfo(uint32 first, uint8 max, bool allkills, uint32 L2, uint32 L3, uint32 L4, uint32 L5, uint32 L6, uint32 L7, uint32 L8, uint32 L9, uint32 L10) {
	FirstItem = first;
	MaxLvl = max;
	AllKills = allkills;
	LvlKills[0] = L2;
	LvlKills[1] = L3;
	LvlKills[2] = L4;
	LvlKills[3] = L5;
	LvlKills[4] = L6;
	LvlKills[5] = L7;
	LvlKills[6] = L8;
	LvlKills[7] = L9;
	LvlKills[8] = L10;
}

EvolveInfo::~EvolveInfo() {
}

bool Item_Struct::IsEquipable(uint16 Race, uint16 Class_) const
{
	bool IsRace = false;
	bool IsClass = false;

	uint32 Classes_ = Classes;

	uint32 Races_ = Races;

	uint32 Race_ = GetArrayRace(Race);

	for (int CurrentClass = 1; CurrentClass <= PLAYER_CLASS_COUNT; ++CurrentClass)
	{
		if (Classes_ % 2 == 1)
		{
			if (CurrentClass == Class_)
			{
					IsClass = true;
				break;
			}
		}
		Classes_ >>= 1;
	}

	Race_ = (Race_ == 18 ? 16 : Race_);

	for (unsigned int CurrentRace = 1; CurrentRace <= PLAYER_RACE_COUNT; ++CurrentRace)
	{
		if (Races_ % 2 == 1)
		{
				if (CurrentRace == Race_)
			{
					IsRace = true;
				break;
			}
		}
		Races_ >>= 1;
	}
	return (IsRace && IsClass);
}
