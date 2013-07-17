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

// Reflects the current server limits, which is currently set for Steam RoF v2
const int16 ServerInventoryLimits[SlotType_Count] =
{
	SIZE_POSSESSIONS,			/* Type 0 */	SIZE_BANK,					/* Type 1 */
	SIZE_SHAREDBANK,			/* Type 2 */	SIZE_TRADE,					/* Type 3 */
	SIZE_WORLD,					/* Type 4 */	SIZE_LIMBO,					/* Type 5 */
	SIZE_TRIBUTE,				/* Type 6 */	SIZE_TROPHYTRIBUTE,			/* Type 7 */
	SIZE_GUILDTRIBUTE,			/* Type 8 */	SIZE_MERCHANT,				/* Type 9 */
	SIZE_DELETED,				/* Type 10 */	SIZE_CORPSE,				/* Type 11 */
	SIZE_BAZAAR,				/* Type 12 */	SIZE_INSPECT,				/* Type 13 */
	SIZE_REALESTATE,			/* Type 14 */	SIZE_VIEWMODPC,				/* Type 15 */
	SIZE_VIEWMODBANK,			/* Type 16 */	SIZE_VIEWMODSHAREDBANK,		/* Type 17 */
	SIZE_VIEWMODLIMBO,			/* Type 18 */	SIZE_ALTSTORAGE,			/* Type 19 */
	SIZE_ARCHIVED,				/* Type 20 */	SIZE_MAIL,					/* Type 21 */
	SIZE_GUILDTROPHYTRIBUTE,	/* Type 22 */	SIZE_KRONO,					/* Type 23 */
	SIZE_OTHER					/* Type 24 */
};

// Non-Client slot type sizes (Set slot types unused by NPC to SIZE_UNUSED)
const int16 MobInventoryLimits[SlotType_Count] =
{
	SIZE_POSSESSIONS,			/* Type 0 */	SIZE_UNUSED,				/* Type 1 */
	SIZE_UNUSED,				/* Type 2 */	SIZE_TRADE,					/* Type 3 */
	SIZE_UNUSED,				/* Type 4 */	SIZE_UNUSED,				/* Type 5 */
	SIZE_TRIBUTE,				/* Type 6 */	SIZE_TROPHYTRIBUTE,			/* Type 7 */
	SIZE_GUILDTRIBUTE,			/* Type 8 */	SIZE_MERCHANT,				/* Type 9 */
	SIZE_DELETED,				/* Type 10 */	SIZE_CORPSE,				/* Type 11 */
	SIZE_BAZAAR,				/* Type 12 */	SIZE_INSPECT,				/* Type 13 */
	SIZE_UNUSED,				/* Type 14 */	SIZE_UNUSED,				/* Type 15 */
	SIZE_UNUSED,				/* Type 16 */	SIZE_UNUSED,				/* Type 17 */
	SIZE_UNUSED,				/* Type 18 */	SIZE_UNUSED,				/* Type 19 */
	SIZE_UNUSED,				/* Type 20 */	SIZE_UNUSED,				/* Type 21 */
	SIZE_GUILDTROPHYTRIBUTE,	/* Type 22 */	SIZE_UNUSED,				/* Type 23 */
	SIZE_UNUSED					/* Type 24 */
};

std::list<ItemInst*> dirty_inst;

int32 NextItemInstSerialNumber = 1;

static inline int32 GetNextItemInstSerialNumber()
{
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
	
	if(NextItemInstSerialNumber >= INT_MAX) { NextItemInstSerialNumber = 1; }
	else { NextItemInstSerialNumber++; }

	return NextItemInstSerialNumber;
}


/*
 Class: InventoryLimits ###########################################################################
	Class to allow efficient coding of inventory restrictions. Slots are limited on a per-client
	basis, allowing one segment of code to handle the entire range of clients instead of having
	multiple version checks with specialized code for each.
 ##################################################################################################
*/
InventoryLimits::~InventoryLimits()
{
	memset(this, 0, sizeof(InventoryLimits));
}

bool InventoryLimits::SetServerInventoryLimits(InventoryLimits &limits)
{
	if(limits.m_limits_set) { return false; }
	
	memcpy(limits.m_slottypesize, ServerInventoryLimits, sizeof(InventoryLimits.m_slottypesize));

	limits.m_equipmentstart								= EQUIPMENT_START;
	limits.m_equipmentend								= EQUIPMENT_END;
	limits.m_equipmentbitmask							= EQUIPMENT_BITMASK;
	limits.m_personalstart								= PERSONAL_START;
	limits.m_personalend								= PERSONAL_END;
	limits.m_personalbitmask							= PERSONAL_BITMASK;

	limits.m_bandolierslotsmax							= MAX_BANDOLIERSLOTS;
	limits.m_potionbeltslotsmax							= MAX_POTIONBELTSLOTS;
	limits.m_bagslotsmax								= MAX_BAGSLOTS;
	limits.m_augmentsmax								= MAX_AUGMENTS;

	limits.m_limits_set = true;

	return true;
}

bool InventoryLimits::SetMobInventoryLimits(InventoryLimits &limits)
{
	// If the mob class and its derived classes (npc, bot, etc...) are ever overhauled/developed, this
	// function can be changed to allow use of the full inventory function that a client has access to
	if(limits.m_limits_set) { return false; }

	memcpy(limits.m_slottypesize, MobInventoryLimits, sizeof(InventoryLimits.m_slottypesize));
	
	limits.m_equipmentstart								= EQUIPMENT_START;
	limits.m_equipmentend								= EQUIPMENT_END;
	limits.m_equipmentbitmask							= EQUIPMENT_BITMASK;
	limits.m_personalstart								= MAINSLOT_INVALID;
	limits.m_personalend								= MAINSLOT_INVALID;
	limits.m_personalbitmask							= SIZE_UNUSED;

	limits.m_bandolierslotsmax							= SIZE_UNUSED;
	limits.m_potionbeltslotsmax							= SIZE_UNUSED;
	limits.m_bagslotsmax								= SIZE_UNUSED;
	limits.m_augmentsmax								= SIZE_UNUSED;

	limits.m_limits_set = true;

	return true;
}

bool InventoryLimits::SetClientInventoryLimits(InventoryLimits &limits, EQClientVersion client_version)
{
	// In addition to the #define's needing work, all of the client ranges need to be verified here -U
	if(limits.m_limits_set) { return false; }
	
	SetServerInventoryLimits(limits);

	// Add new clients in descending order
	if(client_version < EQClientRoF)
	{
		limits.m_slottypesize[SlotType_Possessions]			= SIZE_POSSESSIONS_PRE_ROF;
		limits.m_slottypesize[SlotType_Corpse]				= SIZE_CORPSE_PRE_ROF;
		limits.m_slottypesize[SlotType_Bazaar]				= SIZE_BAZAAR_PRE_ROF;
			
		limits.m_personalend								= PERSONAL_END_PRE_ROF;
		limits.m_personalbitmask							= PERSONAL_BITMASK_PRE_ROF;

		limits.m_bagslotsmax								= MAX_BAGSLOTS_PRE_ROF;
		limits.m_augmentsmax								= MAX_AUGMENTS_PRE_ROF;
	}

	if(client_version < EQClientUnderfoot)
	{

	}

	if(client_version < EQClientSoD)
	{

	}

	if(client_version < EQClientSoF)
	{
		limits.m_slottypesize[SlotType_Possessions]			= SIZE_POSSESSIONS_PRE_SOF;
		limits.m_slottypesize[SlotType_Corpse]				= SIZE_CORPSE_PRE_SOF;
		limits.m_slottypesize[SlotType_Bank]				= SIZE_BANK_PRE_SOF;

		limits.m_equipmentbitmask							= EQUIPMENT_BITMASK_PRE_SOF;
	}

	if(client_version < EQClientTitanium)
	{
		limits.m_slottypesize[SlotType_Possessions]			= SIZE_POSSESSIONS_PRE_TI;
		limits.m_slottypesize[SlotType_Corpse]				= SIZE_CORPSE_PRE_TI;

		limits.m_equipmentbitmask							= EQUIPMENT_BITMASK_PRE_TI;
	}

	if(client_version < EQClient62) // If we got here, we screwed the pooch somehow...
	{
		// TODO: log error message
		limits.ResetInventoryLimits();
	}

	limits.m_limits_set = true;

	return true;
}

void InventoryLimits::ResetInventoryLimits()
{
	memset(this->m_slottypesize, 0, sizeof(InventoryLimits.m_slottypesize));
	
	m_equipmentstart	= MAINSLOT_INVALID;
	m_equipmentend		= MAINSLOT_INVALID;
	m_equipmentbitmask	= SIZE_UNUSED;
	m_personalstart		= MAINSLOT_INVALID;
	m_personalend		= MAINSLOT_INVALID;
	m_personalbitmask	= SIZE_UNUSED;

	m_bandolierslotsmax		= SIZE_UNUSED;
	m_potionbeltslotsmax	= SIZE_UNUSED;
	m_bagslotsmax			= SIZE_UNUSED;
	m_augmentsmax			= SIZE_UNUSED;

	m_limits_set = false;
}
// ################################################################################################


/*
 Class: Inventory #################################################################################
	Client inventory
 ##################################################################################################
*/

// ################################################################################################


/*
 Class: ItemInst ##################################################################################
	Class for an instance of an item. An item instance encapsulates item data and data specific to
	an item instance (includes dye, augments, charges, etc.) Now includes EvoItemInst properties
 ##################################################################################################
*/

// ################################################################################################


/*
 Class: EvolveInfo ################################################################################
	<description>
 ##################################################################################################
*/
EvolveInfo::EvolveInfo()
{
	// nothing here yet
}

EvolveInfo::EvolveInfo(uint32 first, uint8 max, bool allkills, uint32 L2, uint32 L3, uint32 L4, uint32 L5, uint32 L6, uint32 L7, uint32 L8, uint32 L9, uint32 L10)
{
	FirstItem	= first;
	MaxLvl		= max;
	AllKills	= allkills;
	LvlKills[0]	= L2;
	LvlKills[1]	= L3;
	LvlKills[2]	= L4;
	LvlKills[3]	= L5;
	LvlKills[4]	= L6;
	LvlKills[5]	= L7;
	LvlKills[6]	= L8;
	LvlKills[7]	= L9;
	LvlKills[8]	= L10;
}

EvolveInfo::~EvolveInfo()
{

}
// ################################################################################################


/*
 Structure: Item_Struct ###########################################################################
	<description>
 ##################################################################################################
*/
bool Item_Struct::IsEquipable(uint16 race_id, uint16 class_id) const
{
	bool IsRace = false;
	bool IsClass = false;

	uint32 Classes_ = Classes;
	uint32 Races_ = Races;

	uint32 Race_ = GetArrayRace(race_id);

	for(int CurrentClass = 1; CurrentClass <= PLAYER_CLASS_COUNT; ++CurrentClass)
	{
		if(Classes_ % 2 == 1)
		{
			if(CurrentClass == class_id)
			{
					IsClass = true;
					break;
			}
		}

		Classes_ >>= 1;
	}

	Race_ = (Race_ == 18 ? 16 : Race_);

	for(unsigned int CurrentRace = 1; CurrentRace <= PLAYER_RACE_COUNT; ++CurrentRace)
	{
		if(Races_ % 2 == 1)
		{
			if(CurrentRace == Race_)
			{
				IsRace = true;
				break;
			}
		}

		Races_ >>= 1;
	}

	return (IsRace && IsClass);
}
// ################################################################################################
