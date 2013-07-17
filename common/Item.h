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

// @merth notes:
// These classes could be optimized with database reads/writes by storing
// a status flag indicating how object needs to interact with database

#ifndef __ITEM_H
#define __ITEM_H

class ItemInst;				// Item belonging to a client (contains info on item, dye, augments, charges, etc)
class InventoryLimits;		// Client-based limits class
class Inventory;			// Character inventory
class ItemParse;			// Parses item packets
class EvolveInfo;			// Stores information about an evolving item family

#include <string>
#include <vector>
#include <map>
#include <list>
#include "../common/eq_packet_structs.h"
#include "../common/eq_constants.h"
#include "../common/item_struct.h"
#include "../common/clientversions.h"
#include "../common/timer.h"

// Helper typedefs
typedef std::map<int16, ItemInst*>::const_iterator iter_inst;
typedef std::map<uint8, ItemInst*>::const_iterator iter_contents;

namespace ItemField
{
	enum
	{
		source = 0,
#define F(x) x,
#include "item_fieldlist.h"
#undef F
		updated
	};
};

// Depricated #defines -U
// Indexing positions to the beginning slot_id's for a bucket of slots
#define IDX_EQUIP		0
#define IDX_CURSOR_BAG	331
#define IDX_INV			22
#define IDX_INV_BAG		251
#define IDX_TRIBUTE		400
#define IDX_BANK		2000
#define IDX_BANK_BAG	2031
#define IDX_SHBANK		2500
#define IDX_SHBANK_BAG	2531
#define IDX_TRADE		3000
#define IDX_TRADE_BAG	3031
#define IDX_TRADESKILL	4000
#define MAX_ITEMS_PER_BAG 10

// Specifies usage type for item inside ItemInst
enum ItemUseType
{
	ItemUseNormal,
	ItemUseWorldContainer
};

typedef enum
{
	byFlagIgnore,	//do not consider this flag
	byFlagSet,		//apply action if the flag is set
	byFlagNotSet	//apply action if the flag is NOT set
} byFlagSetting;

// Left in situ until deemed no longer needed (currently used for legacy scripting) -U
//FatherNitwit: location bits for searching specific
//places with HasItem() and HasItemByUse()
enum
{
	invWhereWorn		= 0x01,
	invWherePersonal	= 0x02,	//in the character's inventory
	invWhereBank		= 0x04,
	invWhereSharedBank	= 0x08,
	invWhereTrading		= 0x10,
	invWhereCursor		= 0x20
};

class InventoryLimits
{
public:
	~InventoryLimits();

	static bool		SetServerInventoryLimits(InventoryLimits &limits);
	static bool		SetMobInventoryLimits(InventoryLimits &limits);
	static bool		SetClientInventoryLimits(InventoryLimits &limits, EQClientVersion client_version = EQClientUnknown);
	
	void			ResetInventoryLimits();
	inline bool		IsLimitsSet() const { return m_limits_set; }

	inline int16	GetSlotTypeSize(int16 slot_type)	const { return (slot_type >= SLOTTYPE_START && slot_type < SlotType_Count) ? m_slottypesize[slot_type] : 0; }
	inline int16	operator[](int16 slot_type)			const { return GetSlotTypeSize(slot_type); }

	inline int16	GetEquipmentStart()					const { return m_equipmentstart; }
	inline int16	GetEquipmentEnd()					const { return m_equipmentend; }
	inline uint32	GetEquipmentBitMask()				const { return m_equipmentbitmask; }
	inline int16	GetPersonalStart()					const { return m_personalstart; }
	inline int16	GetPersonalEnd()					const { return m_personalend; }
	inline uint32	GetPersonalBitMask()				const { return m_personalbitmask; }

	inline uint8	GetBandolierSlotsMax()				const { return m_bandolierslotsmax; }
	inline uint8	GetPotionBeltSlotsMax()				const { return m_potionbeltslotsmax; }
	inline uint8	GetBagSlotsMax()					const { return m_bagslotsmax; }
	inline uint8	GetAugmentsMax()					const { return m_augmentsmax; }

private:
	int16			m_slottypesize[SlotType_Count];

	int16			m_equipmentstart;
	int16			m_equipmentend;
	uint32			m_equipmentbitmask;
	int16			m_personalstart;
	int16			m_personalend;
	uint32			m_personalbitmask;

	uint8			m_bandolierslotsmax;
	uint8			m_potionbeltslotsmax;
	uint8			m_bagslotsmax;
	uint8			m_augmentsmax;

	bool			m_limits_set;
};

class SharedDatabase;

class EvolveInfo
{
public:
	friend class ItemInst;
	//temporary
	uint16	LvlKills[9];
	uint32	FirstItem;
	uint8	MaxLvl;
	bool	AllKills;

	EvolveInfo();
	EvolveInfo(uint32 first, uint8 max, bool allkills, uint32 L2, uint32 L3, uint32 L4, uint32 L5, uint32 L6, uint32 L7, uint32 L8, uint32 L9, uint32 L10);
	~EvolveInfo();
};

#endif // #define __ITEM_H
