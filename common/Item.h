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

	static bool	SetServerInventoryLimits(InventoryLimits &limits);
	static bool	SetMobInventoryLimits(InventoryLimits &limits);
	static bool	SetClientInventoryLimits(InventoryLimits &limits, EQClientVersion client_version = EQClientUnknown);
	
	void	ResetInventoryLimits();
	bool	IsLimitsSet() const { return m_limits_set; }

	int16	GetSlotTypeSize(int16 slot_type)	const { return (slot_type >= SLOTTYPE_START && slot_type < SlotType_Count) ? m_slottypesize[slot_type] : 0; }
	int16	operator[](int16 slot_type)			const { return GetSlotTypeSize(slot_type); }

	int16	GetEquipmentStart()					const { return m_equipmentstart; }
	int16	GetEquipmentEnd()					const { return m_equipmentend; }
	uint32	GetEquipmentBitMask()				const { return m_equipmentbitmask; }
	int16	GetPersonalStart()					const { return m_personalstart; }
	int16	GetPersonalEnd()					const { return m_personalend; }
	uint32	GetPersonalBitMask()				const { return m_personalbitmask; }

	uint8	GetBandolierSlotsMax()				const { return m_bandolierslotsmax; }
	uint8	GetPotionBeltSlotsMax()				const { return m_potionbeltslotsmax; }
	uint8	GetBagSlotsMax()					const { return m_bagslotsmax; }
	uint8	GetAugmentsMax()					const { return m_augmentsmax; }

private:
	int16	m_slottypesize[SlotType_Count];

	int16	m_equipmentstart;
	int16	m_equipmentend;
	uint32	m_equipmentbitmask;
	int16	m_personalstart;
	int16	m_personalend;
	uint32	m_personalbitmask;

	uint8	m_bandolierslotsmax;
	uint8	m_potionbeltslotsmax;
	uint8	m_bagslotsmax;
	uint8	m_augmentsmax;

	bool	m_limits_set;
};

class SharedDatabase;

class ItemInst
{
public:
	// Class constructors
	ItemInst(const Item_Struct* item = nullptr, int16 charges = 0);
	ItemInst(SharedDatabase *db, uint32 item_id, int16 charges = 0);
	ItemInst(ItemUseType use_type)
	{
		// if we use this without ever setting m_item, the _Internal<...> functions will
		// need to be modified appropriately or their methods will always fail the !m_item
		// checks. (ref: ItemInst::IsType(ItemClass item_class) function
		
		m_use_type		= use_type;
		m_item			= nullptr;
		m_charges		= 0;
		m_price			= 0;
		m_instnodrop	= false;
		m_merchantslot	= 0;
		m_color			= 0;

		m_exp			= 0;
		m_evolveLvl		= 0;
		m_activated		= false;
		m_scaledItem	= nullptr;
		m_evolveInfo	= nullptr;
		m_scaling		= false;
	}
	ItemInst(const ItemInst& copy);

	// Class deconstructor
	~ItemInst();

	// ItemInst property accessors
	const Item_Struct*	GetUnscaledItem() const { return (m_item ? m_item : nullptr); }
	const Item_Struct*	GetItem() const { return (m_scaledItem ? m_scaledItem : GetUnscaledItem()); }

	int16	GetCharges() const { return m_charges; }
	void	SetCharges(int16 charges) { m_charges = charges; }

	// There are at least two more No<Action>-types out there that we need to find -U
	bool	IsInstNoDrop() const { return m_instnodrop; }
	void	SetInstNoDrop(bool instnodrop) { m_instnodrop = instnodrop; }

	uint32	GetColor() const { return m_color; }
	void	SetColor(uint32 color) { m_color = color; }

	int8	GetEvolveLvl() const { return m_evolveLvl; }
	int8	GetMaxEvolveLvl() const { return (m_evolveInfo ? m_evolveInfo->MaxLvl : 0); }

	uint32	GetExp() const		{ return m_exp; }
	void	SetExp(uint32 exp)	{ m_exp = exp; }
	void	AddExp(uint32 exp)	{ m_exp += exp; }

	void	SetActivated(bool activated) { m_activated = activated; }
	
	void	SetScaling(bool scaling) { m_scaling = scaling; }

	void	SetTimer(std::string name, uint32 time);
	void	StopTimer(std::string name);

	uint32	GetMerchantSlot() const { return m_merchantslot; }
	void	SetMerchantSlot(uint32 merchant_slot) { m_merchantslot = merchant_slot; }

	int32	GetMerchantCount() const { return m_merchantcount; }
	void	SetMerchantCount(int32 merchant_count) { m_merchantcount = merchant_count; }

	uint32	GetPrice() const { return m_price; }
	void	SetPrice(uint32 price) { m_price = price; }

	int16	GetCurrentSlot() const { return m_currentslot; }
	void	SetCurrentSlot(int16 current_slot) { m_currentslot = current_slot; }

	int32	GetSerialNumber() const { return m_serialnumber; }
	void	SetSerialNumber(int32 serial_number) { m_serialnumber = serial_number; }

	// Item_Struct property accessors
	const uint32	GetID()				const { return (m_item ? m_item->ID : 0); }
	const uint32	GetItemScriptID()	const { return (m_item ? m_item->ScriptFileID : 0); }
	const uint32	GetAugmentType()	const { return (m_item ? m_item->AugType : 0); }

	// ItemInst methods
	ItemInst*	Clone() const;

	void	Initialize(SharedDatabase *db = nullptr);
	void	ScaleItem();

	bool	EvolveOnAllKills() const { return (m_evolveInfo && m_evolveInfo->AllKills); }
	uint32	GetKillsNeeded(uint8 current_level);

	bool	IsType(ItemClass item_class) const;
	bool	IsStackable() const;

	bool	IsEvolving()	const { return (m_evolveLvl >= 1); }
	bool	IsActivated()	const { return m_activated; }
	bool	IsScaling()		const { return m_scaling; }

	bool	IsEquipable(uint16 race_id, uint16 class_id) const;
	bool	IsEquipable(InventorySlot_Struct is_struct) const;
	bool	IsWeapon() const;
	bool	IsAmmo() const;
	
	bool	IsAugmentable() const;
	bool	IsExpendable() const { return (m_item && ((m_item->Click.Type == ET_Expendable ) || (m_item->ItemType == ItemTypePotion))); }

	bool	IsSlotAllowed(InventorySlot_Struct is_struct) const;
	bool	IsNoneEmptyContainer();
	
	bool	AvailableWearSlot(uint32 aug_wear_slots) const;
	bool	IsAugmented();

	uint8	GetTotalItemCount() const;

	void	ClearTimers();

	void	Clear();
	void	ClearByFlags(byFlagSetting is_nodrop, byFlagSetting is_norent);

	std::string	GetCustomDataString() const;
	std::string	GetCustomData(std::string identifier);
	void	SetCustomData(std::string identifier, std::string value);
	void	SetCustomData(std::string identifier, int value);
	void	SetCustomData(std::string identifier, float value);
	void	SetCustomData(std::string identifier, bool value);
	void	DeleteCustomData(std::string identifier);

	std::map<std::string, Timer>&	GetTimers() { return m_timers; }

	std::map<uint8, ItemInst*>&	GetContents() { return m_contents; }
	// original: std::map<uint8, ItemInst*>*	GetContents() { return &m_contents; }

	std::string	Serialize(InventorySlot_Struct is_struct) const
	{
		InternalSerializedItem_Struct isi_struct;
		isi_struct.slot_id = 0 /* placeholder for 'is_struct' */;
		isi_struct.inst = (const void *)this;
		std::string ser_str;
		ser_str.assign((char *)&isi_struct, sizeof(InternalSerializedItem_Struct));
		return ser_str;
	}

	// Container (bag) methods
	int16	AvailableItemSlot() const; // FirstOpenSlot()

	uint32	GetItemID(int16 sub_slot) const;

	ItemInst*	GetItem(int16 sub_slot) const;
	int16		PutItem(int16 sub_slot, ItemInst* item_inst);
	int16		PutItem(int16 sub_slot, const ItemInst& item_inst);
	int16		PutItem(SharedDatabase *db, int16 sub_slot, uint32 item_id);

	ItemInst*	RemoveItem(int16 sub_slot);
	bool		DeleteItem(int16 sub_slot);
	
	// Augment methods
	int16	AvailableAugmentSlot(uint32 aug_type) const;	

	uint32	GetAugmentID(int16 aug_slot) const;

	ItemInst*	GetAugment(int16 aug_slot) const;
	int16		PutAugment(int16 aug_slot, ItemInst* aug_inst);
	int16		PutAugment(int16 aug_slot, const ItemInst& aug_inst);
	int16		PutAugment(SharedDatabase *db, int16 aug_slot, uint32 aug_id);

	ItemInst*	RemoveAugment(int16 aug_slot);
	bool		DeleteAugment(int16 aug_slot);

	// ItemInst operators
	operator bool() const { return (m_item != nullptr); }
	bool operator == (const ItemInst& right) const { return (m_item ? (right ? (m_item == right.m_item) : false) : false); }
	bool operator != (const ItemInst& right) const { return (m_item ? (right ? (m_item != right.m_item) : false) : false); }

	const ItemInst* operator[](int16 sub_slot) const { return GetItem(sub_slot); } // Container op

protected:
	iter_contents	_begin()	{ return m_contents.begin(); }
	iter_contents	_end()		{ return m_contents.end(); }

	friend class Inventory; // may be deleteable (try to!)

	// Pointers cost less than repeated code
	bool _InternalItemFailCheck(int16 sub_slot) const;
	bool _InternalAugmentFailCheck(int16 aug_slot) const;

	// Handles both container and augments
	ItemInst*	_GetContent(uint8 contents_index) const;
	void		_PutContent(uint8 contents_index, ItemInst* content_inst);
	ItemInst*	_RemoveContent(uint8 contents_index);
	void		_DeleteContent(uint8 contents_index);

	const Item_Struct*	m_item;
	Item_Struct*		m_scaledItem;
	ItemUseType			m_use_type;

	int16				m_charges;
	bool				m_instnodrop;
	uint32				m_color;
	
	EvolveInfo*			m_evolveInfo;
	int8				m_evolveLvl;
	uint32				m_exp;
	bool				m_activated;
	bool				m_scaling;

	uint32				m_merchantslot;
	int32				m_merchantcount;
	uint32				m_price;
	int16				m_currentslot;
	int32				m_serialnumber;

	std::map<std::string, std::string>	m_customdata;
	std::map<std::string, Timer>		m_timers;
	std::map<uint8, ItemInst*>			m_contents;
};

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
