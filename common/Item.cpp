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

static inline bool SupportsContainers(InventorySlot_Struct is_struct)
{
	// Since this is static and doesn't contain client references, RoF empty bag into bag slot checks
	// will need to be performed inside of the appropriate handlers
	
	if((is_struct.subslot != SUBSLOT_INVALID) || (is_struct.augslot != AUGSLOT_INVALID)) { return false; }
	
	switch(is_struct.slottype)
	{
		case SlotType_Possessions:
		{
			if(is_struct.mainslot == Slot_Cursor) { return true; }
			
			if((is_struct.mainslot >= PERSONAL_START) && (is_struct.mainslot <= PERSONAL_END)) { return true; }

			break;
		}
		case SlotType_Bank:
		case SlotType_SharedBank:
		case SlotType_Trade:
		case SlotType_Limbo:
		{
			if((is_struct.mainslot >= MAINSLOT_START) && (is_struct.mainslot < ServerInventoryLimits[is_struct.slottype])) { return true; }
		}
		default: { return false; }
	}
	
	return false;
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

	limits.m_equipmentstart		= EQUIPMENT_START;
	limits.m_equipmentend		= EQUIPMENT_END;
	limits.m_equipmentbitmask	= EQUIPMENT_BITMASK;
	limits.m_personalstart		= PERSONAL_START;
	limits.m_personalend		= PERSONAL_END;
	limits.m_personalbitmask	= PERSONAL_BITMASK;

	limits.m_bandolierslotsmax	= MAX_BANDOLIERSLOTS;
	limits.m_potionbeltslotsmax	= MAX_POTIONBELTSLOTS;
	limits.m_bagslotsmax		= MAX_BAGSLOTS;
	limits.m_augmentsmax		= MAX_AUGMENTS;

	limits.m_limits_set = true;

	return true;
}

bool InventoryLimits::SetMobInventoryLimits(InventoryLimits &limits)
{
	// If the mob class and its derived classes (npc, bot, etc...) are ever overhauled/developed, this
	// function can be changed to allow use of the full inventory function that a client has access to
	if(limits.m_limits_set) { return false; }

	memcpy(limits.m_slottypesize, MobInventoryLimits, sizeof(InventoryLimits.m_slottypesize));
	
	limits.m_equipmentstart		= EQUIPMENT_START;
	limits.m_equipmentend		= EQUIPMENT_END;
	limits.m_equipmentbitmask	= EQUIPMENT_BITMASK;
	limits.m_personalstart		= MAINSLOT_INVALID;
	limits.m_personalend		= MAINSLOT_INVALID;
	limits.m_personalbitmask	= SIZE_UNUSED;

	limits.m_bandolierslotsmax	= SIZE_UNUSED;
	limits.m_potionbeltslotsmax	= SIZE_UNUSED;
	limits.m_bagslotsmax		= SIZE_UNUSED;
	limits.m_augmentsmax		= SIZE_UNUSED;

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
	an item instance (includes dye, augments, charges, etc.) - including class EvoItemInst items
 ##################################################################################################
*/
ItemInst::ItemInst(const Item_Struct* item, int16 charges)
{
	m_use_type		= ItemUseNormal;
	m_item			= item;
	m_charges		= charges;
	m_price			= 0;
	m_instnodrop	= false;
	m_merchantslot	= 0;

	if(m_item && m_item->ItemClass == ItemClassCommon) { m_color = m_item->Color; }
	else { m_color = 0; }

	m_merchantcount	= 1;
	m_serialnumber	= GetNextItemInstSerialNumber();

	m_exp			= 0;
	m_evolveLvl		= 0;
	m_activated		= false;
	m_scaledItem	= nullptr;
	m_evolveInfo	= nullptr;
	m_scaling		= false;
}

ItemInst::ItemInst(SharedDatabase *db, uint32 item_id, int16 charges)
{
	m_use_type		= ItemUseNormal;
	m_item			= db->GetItem(item_id);
	m_charges		= charges;
	m_price			= 0;
	m_merchantslot	= 0;
	m_instnodrop	= false;

	if(m_item && m_item->ItemClass == ItemClassCommon) { m_color = m_item->Color; }
	else { m_color = 0; }

	m_merchantcount	= 1;
	m_serialnumber	= GetNextItemInstSerialNumber();

	m_exp			= 0;
	m_evolveLvl		= 0;
	m_activated		= false;
	m_scaledItem	= nullptr;
	m_evolveInfo	= nullptr;
	m_scaling		= false;
}

ItemInst::ItemInst(const ItemInst& copy)
{
	m_use_type		= copy.m_use_type;
	m_item			= copy.m_item;
	m_charges		= copy.m_charges;
	m_price			= copy.m_price;
	m_color			= copy.m_color;
	m_merchantslot	= copy.m_merchantslot;
	m_currentslot	= copy.m_currentslot;
	m_instnodrop	= copy.m_instnodrop;
	m_merchantcount	= copy.m_merchantcount;

	iter_contents cc_iter;
	for(cc_iter = copy.m_contents.begin(); cc_iter != copy.m_contents.end(); cc_iter++)
	{
		ItemInst* inst_old = cc_iter->second;
		ItemInst* inst_new = nullptr;

		if(inst_old) { inst_new = inst_old->Clone(); }

		if(inst_new != nullptr) { m_contents[cc_iter->first] = inst_new; }
	}

	std::map<std::string, std::string>::const_iterator ccd_iter;
	for(ccd_iter = copy.m_customdata.begin(); ccd_iter != copy.m_customdata.end(); ccd_iter++)
	{
		m_customdata[ccd_iter->first] = ccd_iter->second;
	}

	m_serialnumber	= copy.m_serialnumber;
	m_customdata	= copy.m_customdata; // Hmmm... Why did we just iterate this above?
	m_timers		= copy.m_timers;

	m_exp			= copy.m_exp;
	m_evolveLvl		= copy.m_evolveLvl;
	m_activated		= copy.m_activated;

	if(copy.m_scaledItem) { m_scaledItem = new Item_Struct(*copy.m_scaledItem); }
	else { m_scaledItem = nullptr; }

	if(copy.m_evolveInfo) { m_evolveInfo = new EvolveInfo(*copy.m_evolveInfo); }
	else { m_evolveInfo = nullptr; }

	m_scaling = copy.m_scaling;
}

ItemInst::~ItemInst()
{
	Clear();
	safe_delete(m_scaledItem);
	safe_delete(m_evolveInfo);
}

void ItemInst::SetTimer(std::string name, uint32 time)
{
	Timer t(time);
	t.Start(time, false);
	m_timers[name] = t;
}

void ItemInst::StopTimer(std::string name)
{
	auto iter = m_timers.find(name);

	if(iter != m_timers.end()) { m_timers.erase(iter); }
}

ItemInst* ItemInst::Clone() const
{
	return new ItemInst(*this); // Pseudo-polymorphic copy constructor
}

void ItemInst::Initialize(SharedDatabase *db)
{
	if(!m_item) { return; }

	// initialize scaling items
	if(m_item->CharmFileID != 0)
	{
		m_scaling = true;
		ScaleItem();
	}
	// initialize evolving items
	else if((db) && m_item->LoreGroup >= 1000 && m_item->LoreGroup != -1)
	{
		// not complete yet
	}
}

void ItemInst::ScaleItem()
{
	if(m_scaledItem) { memcpy(m_scaledItem, m_item, sizeof(Item_Struct)); }
	else { m_scaledItem = new Item_Struct(*m_item); }

	float Mult = (float)(GetExp()) / 10000; // scaling is determined by exp, with 10,000 being full stats

	m_scaledItem->AStr	= (int8)((float)m_item->AStr * Mult);
	m_scaledItem->ASta	= (int8)((float)m_item->ASta * Mult);
	m_scaledItem->AAgi	= (int8)((float)m_item->AAgi * Mult);
	m_scaledItem->ADex	= (int8)((float)m_item->ADex * Mult);
	m_scaledItem->AInt	= (int8)((float)m_item->AInt * Mult);
	m_scaledItem->AWis	= (int8)((float)m_item->AWis * Mult);
	m_scaledItem->ACha	= (int8)((float)m_item->ACha * Mult);

	m_scaledItem->MR	= (int8)((float)m_item->MR * Mult);
	m_scaledItem->PR	= (int8)((float)m_item->PR * Mult);
	m_scaledItem->DR	= (int8)((float)m_item->DR * Mult);
	m_scaledItem->CR	= (int8)((float)m_item->CR * Mult);
	m_scaledItem->FR	= (int8)((float)m_item->FR * Mult);

	m_scaledItem->HP	= (int32)((float)m_item->HP * Mult);
	m_scaledItem->Mana	= (int32)((float)m_item->Mana * Mult);
	m_scaledItem->AC	= (int32)((float)m_item->AC * Mult);

	m_scaledItem->SkillModValue	= (int32)((float)m_item->SkillModValue * Mult);
	m_scaledItem->BaneDmgAmt	= (int8)((float)m_item->BaneDmgAmt * Mult);
	m_scaledItem->BardValue		= (int32)((float)m_item->BardValue * Mult);
	m_scaledItem->ElemDmgAmt	= (uint8)((float)m_item->ElemDmgAmt * Mult);
	m_scaledItem->Damage		= (uint32)((float)m_item->Damage * Mult);

	m_scaledItem->CombatEffects	= (int8)((float)m_item->CombatEffects * Mult);
	m_scaledItem->Shielding		= (int8)((float)m_item->Shielding * Mult);
	m_scaledItem->StunResist	= (int8)((float)m_item->StunResist * Mult);
	m_scaledItem->StrikeThrough	= (int8)((float)m_item->StrikeThrough * Mult);
	m_scaledItem->ExtraDmgAmt	= (uint32)((float)m_item->ExtraDmgAmt * Mult);
	m_scaledItem->SpellShield	= (int8)((float)m_item->SpellShield * Mult);
	m_scaledItem->Avoidance		= (int8)((float)m_item->Avoidance * Mult);
	m_scaledItem->Accuracy		= (int8)((float)m_item->Accuracy * Mult);

	m_scaledItem->FactionAmt1	= (int32)((float)m_item->FactionAmt1 * Mult);
	m_scaledItem->FactionAmt2	= (int32)((float)m_item->FactionAmt2 * Mult);
	m_scaledItem->FactionAmt3	= (int32)((float)m_item->FactionAmt3 * Mult);
	m_scaledItem->FactionAmt4	= (int32)((float)m_item->FactionAmt4 * Mult);

	m_scaledItem->Endur				= (uint32)((float)m_item->Endur * Mult);
	m_scaledItem->DotShielding		= (uint32)((float)m_item->DotShielding * Mult);
	m_scaledItem->Attack			= (uint32)((float)m_item->Attack * Mult);
	m_scaledItem->Regen				= (uint32)((float)m_item->Regen * Mult);
	m_scaledItem->ManaRegen			= (uint32)((float)m_item->ManaRegen * Mult);
	m_scaledItem->EnduranceRegen	= (uint32)((float)m_item->EnduranceRegen * Mult);
	m_scaledItem->Haste				= (uint32)((float)m_item->Haste * Mult);
	m_scaledItem->DamageShield		= (uint32)((float)m_item->DamageShield * Mult);

	m_scaledItem->Purity			= (uint32)((float)m_item->Purity * Mult);
	m_scaledItem->BackstabDmg		= (uint32)((float)m_item->BackstabDmg * Mult);
	m_scaledItem->DSMitigation		= (uint32)((float)m_item->DSMitigation * Mult);
	m_scaledItem->HeroicStr			= (int32)((float)m_item->HeroicStr * Mult);
	m_scaledItem->HeroicInt			= (int32)((float)m_item->HeroicInt * Mult);
	m_scaledItem->HeroicWis			= (int32)((float)m_item->HeroicWis * Mult);
	m_scaledItem->HeroicAgi			= (int32)((float)m_item->HeroicAgi * Mult);
	m_scaledItem->HeroicDex			= (int32)((float)m_item->HeroicDex * Mult);
	m_scaledItem->HeroicSta			= (int32)((float)m_item->HeroicSta * Mult);
	m_scaledItem->HeroicCha			= (int32)((float)m_item->HeroicCha * Mult);
	m_scaledItem->HeroicMR			= (int32)((float)m_item->HeroicMR * Mult);
	m_scaledItem->HeroicFR			= (int32)((float)m_item->HeroicFR * Mult);
	m_scaledItem->HeroicCR			= (int32)((float)m_item->HeroicCR * Mult);
	m_scaledItem->HeroicDR			= (int32)((float)m_item->HeroicDR * Mult);
	m_scaledItem->HeroicPR			= (int32)((float)m_item->HeroicPR * Mult);
	m_scaledItem->HeroicSVCorrup	= (int32)((float)m_item->HeroicSVCorrup * Mult);
	m_scaledItem->HealAmt			= (int32)((float)m_item->HealAmt * Mult);
	m_scaledItem->SpellDmg			= (int32)((float)m_item->SpellDmg * Mult);
	m_scaledItem->Clairvoyance		= (uint32)((float)m_item->Clairvoyance * Mult);

	m_scaledItem->CharmFileID = 0; // this stops the client from trying to scale the item itself.
}

uint32 ItemInst::GetKillsNeeded(uint8 current_level)
{
	uint32 kills = -1;	// default to -1 (max uint32 value) because this value is usually divided by, so we don't want to ever return zero.
	
	if(m_evolveInfo && (current_level != m_evolveInfo->MaxLvl)) { kills = m_evolveInfo->LvlKills[current_level - 1]; }

	if(kills == 0) { kills = -1; }

	return kills;
}

bool ItemInst::IsType(ItemClass item_class) const
{
	if((m_use_type == ItemUseWorldContainer) && (item_class == ItemClassContainer)) { return true; }

	return (m_item ? (m_item->ItemClass == item_class) : false);
}

bool ItemInst::IsStackable() const
{
	return (m_item ? m_item->Stackable : false);
}

bool ItemInst::IsEquipable(uint16 race_id, uint16 class_id) const
{
	if(!m_item || (m_item->Slots == 0)) { return false; }

	return m_item->IsEquipable(race_id, class_id);
}

bool ItemInst::IsEquipable(InventorySlot_Struct is_struct) const
{
	if(!m_item) { return false; }

	if(is_struct.slottype == SlotType_Possessions)
	{
		if(is_struct.subslot == SUBSLOT_INVALID && is_struct.augslot == AUGSLOT_INVALID)
		{
			if(is_struct.mainslot >= EQUIPMENT_START && is_struct.mainslot <= EQUIPMENT_END)
			{
				if(m_item->Slots & (1 << is_struct.mainslot)) { return true; }
			}
		}
	}

	return false;
}

bool ItemInst::IsWeapon() const
{
	if(!m_item) { return false; }
	
	/*
	if we don't want augments showing up as weapons, remove the (!m_item) check and enable the one below
	(there are many (augtype > 0) items that appear with (damage != 0), (delay != 0) and (damage != 0 and delay != 0) as of peq rev 69)

	if(_InternalItemFailCheck(SUBSLOT_START)) { return false; }
	*/

	if(m_item->ItemType == ItemTypeArrow && m_item->Damage != 0) { return true; }
	else { return ((m_item->Damage != 0) && (m_item->Delay != 0)); }
}

bool ItemInst::IsAmmo() const
{
	if(!m_item) { return false; }
	
	/*
	if we don't want augments showing up as ammo, remove the (!m_item) check and enable the one below
	(no (augtype > 0) appears to be ammo as of peq rev 69)

	if(_InternalItemFailCheck(SUBSLOT_START)) { return false; }
	*/

	return ((m_item->ItemType == ItemTypeArrow) ||
		(m_item->ItemType == ItemTypeThrowing) ||
		(m_item->ItemType == ItemTypeThrowingv2));
}

bool ItemInst::IsAugmentable() const
{
	if(_InternalAugmentFailCheck(AUGSLOT_START)) { return false; }
	
	for(uint8 aug_index = AUGSLOT_START; aug_index < MAX_AUGMENTS; aug_index++)
	{
		if(m_item->AugSlotType[aug_index]) { return true; }
	}

	return false;
}

// This needs some work..consider adding augment slot checks
bool ItemInst::IsSlotAllowed(InventorySlot_Struct is_struct) const
{
	if(!m_item) { return false; }
	else if(SupportsContainers(is_struct)) { return true; }
	else if(IsEquipable(is_struct)) { return true; }
	else if(is_struct.augslot == AUGSLOT_INVALID)
	{
		if(is_struct.slottype == SlotType_Possessions)
		{
			if(is_struct.mainslot >= PERSONAL_START && is_struct.mainslot < ServerInventoryLimits[SlotType_Possessions])
			{
				// The use of 'm_item->BagSlots' will prevent bag overloading - the use of illegal bag slots
				// ..otherwise, if there are issues, use '< MAX_BAGSLOTS' (same for below)

				if(is_struct.subslot >= SUBSLOT_INVALID && is_struct.subslot < (int16)m_item->BagSlots) { return true; }
			}
		}
		else if(is_struct.slottype > SlotType_Possessions && is_struct.slottype < SlotType_Count)
		{	
			if(is_struct.mainslot >= MAINSLOT_START && is_struct.mainslot < ServerInventoryLimits[is_struct.slottype])
			{
				if(is_struct.subslot >= SUBSLOT_INVALID && is_struct.subslot < (int16)m_item->BagSlots) { return true; }
			}
		}
	}

	return false;
}

bool ItemInst::IsNoneEmptyContainer()
{
	if(_InternalItemFailCheck(SUBSLOT_START)) { return false; }

	// We could probably just use 'return !m_contents.Empty()' if we trust the Inventory sub-system
	for(int16 sub_slot = SUBSLOT_START; sub_slot < m_item->BagSlots; sub_slot++)
	{
		if(GetItem(sub_slot)) { return true; }
	}

	return false;
}

bool ItemInst::AvailableWearSlot(uint32 aug_wear_slots) const
{
	if(_InternalItemFailCheck(SUBSLOT_START)) { return false; }

	uint32 wear_index;
	for(wear_index = EQUIPMENT_START; wear_index <= EQUIPMENT_END; wear_index++)
	{
		if(m_item->Slots & (1 << wear_index))
		{
			if(aug_wear_slots & (1 << wear_index)) { break; }
		}
	}

	return ((wear_index <= EQUIPMENT_END) ? true : false);
}

bool ItemInst::IsAugmented()
{
	if(_InternalAugmentFailCheck(AUGSLOT_START)) { return false; }
	
	// Same here..'return !m_contents.Empty()'
	for(int16 aug_slot = AUGSLOT_START; aug_slot < (int16)MAX_AUGMENTS; aug_slot++)
	{
		if(GetAugmentID(aug_slot)) { return true; }
	}

	return false;
}

uint8 ItemInst::GetTotalItemCount() const
{
	uint8 item_count = 1;
	
	if(!m_item) { return item_count; }

	if(m_item->ItemClass == ItemClassContainer)
	{
		for(int16 sub_slot = SUBSLOT_START; sub_slot < (int16)m_item->BagSlots; sub_slot++)
		{
			if(GetItem(sub_slot)) { item_count++; }
		}
	}
	else if(m_item->ItemClass == ItemClassCommon)
	{
		for(int16 aug_slot = AUGSLOT_START; aug_slot < (int16)MAX_AUGMENTS; aug_slot++)
		{
			if(GetAugment(aug_slot)) { item_count++; }
		}
	}

	return item_count;
}

void ItemInst::ClearTimers()
{
	m_timers.clear();
}

void ItemInst::Clear()
{
	iter_contents cur, end;
	cur = m_contents.begin();
	end = m_contents.end();
	for(; cur != end; cur++)
	{
		ItemInst* inst = cur->second;
		safe_delete(inst);
	}

	m_contents.clear();
}

void ItemInst::ClearByFlags(byFlagSetting is_nodrop, byFlagSetting is_norent)
{
	iter_contents cur, end, del;
	cur = m_contents.begin();
	end = m_contents.end();
	for(; cur != end;)
	{
		ItemInst* inst = cur->second;
		const Item_Struct* item = inst->GetItem();
		del = cur;
		cur++;

		if(!item) { continue; }

		switch(is_nodrop)
		{
			case byFlagSet:
			{
				if(item->NoDrop == 0)
				{
					safe_delete(inst);
					m_contents.erase(del->first);
					continue;
				}
			}
			case byFlagNotSet:
			{
				if(item->NoDrop != 0)
				{
					safe_delete(inst);
					m_contents.erase(del->first);
					continue;
				}
			}
			default: { break; }
		}

		switch(is_norent)
		{
			case byFlagSet:
			{
				if(item->NoRent == 0)
				{
					safe_delete(inst);
					m_contents.erase(del->first);
					continue;
				}
			}
			case byFlagNotSet:
			{
				if(item->NoRent != 0)
				{
					safe_delete(inst);
					m_contents.erase(del->first);
					continue;
				}
			}
			default: { break; }
		}
	}
}

std::string ItemInst::GetCustomDataString() const
{
	std::string ret_val;
	std::map<std::string, std::string>::const_iterator cd_iter = m_customdata.begin();
	while(cd_iter != m_customdata.end())
	{
		if(ret_val.length() > 0) { ret_val += "^"; }

		ret_val += cd_iter->first;
		ret_val += "^";
		ret_val += cd_iter->second;
		cd_iter++;

		if(ret_val.length() > 0) { ret_val += "^"; }
	}

	return ret_val;
}

std::string ItemInst::GetCustomData(std::string identifier)
{
	std::map<std::string, std::string>::const_iterator cd_iter = m_customdata.find(identifier);

	if(cd_iter != m_customdata.end()) { return cd_iter->second; }

	return "";
}

void ItemInst::SetCustomData(std::string identifier, std::string value)
{
	DeleteCustomData(identifier);
	m_customdata[identifier] = value;
}

void ItemInst::SetCustomData(std::string identifier, int value)
{
	DeleteCustomData(identifier);
	std::stringstream ss;
	ss << value;
	m_customdata[identifier] = ss.str();
}

void ItemInst::SetCustomData(std::string identifier, float value)
{
	DeleteCustomData(identifier);
	std::stringstream ss;
	ss << value;
	m_customdata[identifier] = ss.str();
}

void ItemInst::SetCustomData(std::string identifier, bool value)
{
	DeleteCustomData(identifier);
	std::stringstream ss;
	ss << value;
	m_customdata[identifier] = ss.str();
}

void ItemInst::DeleteCustomData(std::string identifier)
{
	std::map<std::string, std::string>::iterator cd_iter = m_customdata.find(identifier);

	if(cd_iter != m_customdata.end()) { m_customdata.erase(cd_iter); }
}

int16 ItemInst::AvailableItemSlot() const // FirstOpenSlot()
{
	if(_InternalItemFailCheck(SUBSLOT_START)) { return SUBSLOT_INVALID; }
	
	int16 sub_slot;
	for(sub_slot = SUBSLOT_START; sub_slot < (int16)m_item->BagSlots; sub_slot++)
	{
		if(!GetItem(sub_slot)) { break; }
	}

	return ((sub_slot < (int16)m_item->BagSlots) ? sub_slot : SUBSLOT_INVALID);
}

uint32 ItemInst::GetItemID(int16 sub_slot) const
{
	const ItemInst* item_inst = GetItem(sub_slot);

	return (item_inst ? item_inst->GetItem()->ID : 0);
}

ItemInst* ItemInst::GetItem(int16 sub_slot) const
{
	if(_InternalItemFailCheck(sub_slot)) { return nullptr; }

	return _GetContent((uint8)sub_slot);
}

int16 ItemInst::PutItem(int16 sub_slot, ItemInst* item_inst)
{
	if(_InternalItemFailCheck(sub_slot)) { return SUBSLOT_INVALID; }

	_DeleteContent((uint8)sub_slot);
	_PutContent((uint8)sub_slot, item_inst);

	return sub_slot;
}

int16 ItemInst::PutItem(int16 sub_slot, const ItemInst& item_inst)
{
	if(_InternalItemFailCheck(sub_slot)) { return SUBSLOT_INVALID; }

	_DeleteContent((uint8)sub_slot);
	_PutContent((uint8)sub_slot, item_inst.Clone());

	return sub_slot;
}

int16 ItemInst::PutItem(SharedDatabase *db, int16 sub_slot, uint32 item_id)
{
	if(_InternalItemFailCheck(sub_slot)) { return SUBSLOT_INVALID; }

	// I modeled this after the original PutAugment(SharedDatabase *db, ...) function. I don't know why we create an
	// instance in db, and then Clone() it, but this will need to be tested and verified before commiting to live.
	// If possible, I'd like to just point to the db created inst instead of cloning and pointing to the new one.

	if(item_id)
	{
		const ItemInst* db_inst = db->CreateItem(item_id);

		if(db_inst)
		{
			ItemInst* item_inst = db_inst->Clone();

			_DeleteContent((uint8)sub_slot);
			_PutContent((uint8)sub_slot, item_inst);
			safe_delete(db_inst);

			return sub_slot;
		}
	}

	return SUBSLOT_INVALID;
}

ItemInst* ItemInst::RemoveItem(int16 sub_slot) // PopItem()
{
	if(_InternalItemFailCheck(sub_slot)) { return nullptr; }

	return _RemoveContent((uint8)sub_slot);
}

bool ItemInst::DeleteItem(int16 sub_slot)
{
	if(_InternalItemFailCheck(sub_slot)) { return false; }

	_DeleteContent((uint8)sub_slot);

	return true;
}

// THIS NEEDS TO BE TESTED!!!
int16 ItemInst::AvailableAugmentSlot(uint32 aug_type) const
{
	// I made some changes and need to make sure that I understand them..and that upstream calls are updated as well -U
	
	if(_InternalAugmentFailCheck(AUGSLOT_START)) { return AUGSLOT_INVALID; }

	int16 aug_slot;
	for(aug_slot = AUGSLOT_START; aug_slot < (int16)MAX_AUGMENTS; aug_slot++)
	{
		if(!GetItem(aug_slot))
		{
			if(aug_type == (uint32)~0 ||
				(m_item->AugSlotType[(uint8)aug_slot] && ((1 << (m_item->AugSlotType[(uint8)aug_slot] - 1)) & aug_type)))
			{
				break;
			}
		}
	}

	return ((aug_slot < (int16)MAX_AUGMENTS) ? aug_slot : AUGSLOT_INVALID);
}

uint32 ItemInst::GetAugmentID(int16 aug_slot) const
{
	const ItemInst* aug_inst = GetAugment(aug_slot);

	return (aug_inst ? aug_inst->GetItem()->ID : 0);
}

ItemInst* ItemInst::GetAugment(int16 aug_slot) const
{
	if(_InternalAugmentFailCheck(aug_slot)) { return nullptr; }

	ItemInst* aug_inst = _GetContent((uint8)aug_slot);

	return ((aug_inst && aug_inst->GetItem()->AugType > 0) ? aug_inst : nullptr);
}

int16 ItemInst::PutAugment(int16 aug_slot, ItemInst* aug_inst)
{
	if(_InternalAugmentFailCheck(aug_slot)) { return AUGSLOT_INVALID; }

	if(aug_inst && aug_inst->GetItem()->AugType == 0) { return AUGSLOT_INVALID; }

	_DeleteContent((uint8)aug_slot);
	_PutContent((uint8)aug_slot, aug_inst);

	return aug_slot;
}

int16 ItemInst::PutAugment(int16 aug_slot, const ItemInst& aug_inst)
{
	if(_InternalAugmentFailCheck(aug_slot)) { return AUGSLOT_INVALID; }

	if(aug_inst && aug_inst.GetItem()->AugType == 0) { return AUGSLOT_INVALID; }

	_DeleteContent((uint8)aug_slot);
	_PutContent((uint8)aug_slot, aug_inst.Clone());

	return aug_slot;
}

int16 ItemInst::PutAugment(SharedDatabase *db, int16 aug_slot, uint32 aug_id)
{
	if(_InternalAugmentFailCheck(aug_slot)) { return AUGSLOT_INVALID; }

	// See notes in ItemInst::PutItem(SharedDatabase *db, int16 sub_slot, uint32 item_id)

	if(aug_id && db->GetItem(aug_id)->AugType > 0)
	{
		const ItemInst* db_inst = db->CreateItem(aug_id);

		if(db_inst)
		{
			ItemInst* aug_inst = db_inst->Clone();

			_DeleteContent((uint8)aug_slot);
			_PutContent((uint8)aug_slot, aug_inst);
			safe_delete(db_inst);

			return aug_slot;
		}
	}

	return AUGSLOT_INVALID;
}

ItemInst* ItemInst::RemoveAugment(int16 aug_slot)
{
	if(_InternalAugmentFailCheck(aug_slot)) { return nullptr; }

	ItemInst* aug_inst = _GetContent((uint8)aug_slot);

	return ((aug_inst && aug_inst->GetItem()->AugType > 0) ? _RemoveContent((uint8)aug_slot) : nullptr);
}

bool ItemInst::DeleteAugment(int16 aug_slot)
{
	if(_InternalAugmentFailCheck(aug_slot)) { return false; }

	ItemInst* aug_inst = _GetContent((uint8)aug_slot);

	if(aug_inst && aug_inst->GetItem()->AugType > 0)
	{
		_DeleteContent((uint8)aug_slot);

		return true;
	}
	else { return false; }
}

bool ItemInst::_InternalItemFailCheck(int16 sub_slot) const
{
	return (!m_item ||
		(m_item->ItemClass != ItemClassContainer) ||
		(sub_slot & MCONTENTS_OOR) ||
		((uint8)sub_slot >= m_item->BagSlots));
}

bool ItemInst::_InternalAugmentFailCheck(int16 aug_slot) const
{
	return (!m_item ||
		(m_item->ItemClass != ItemClassCommon) ||
		(aug_slot & MCONTENTS_OOR) ||
		((uint8)aug_slot >= MAX_AUGMENTS));
}

ItemInst* ItemInst::_GetContent(uint8 contents_index) const
{
	iter_contents c_iter = m_contents.find(contents_index);

	if(c_iter != m_contents.end()) { return c_iter->second; }

	return nullptr;
}

void ItemInst::_PutContent(uint8 contents_index, ItemInst* content_inst)
{
	m_contents[contents_index] = content_inst;
}

ItemInst* ItemInst::_RemoveContent(uint8 contents_index)
{
	iter_contents c_iter = m_contents.find(contents_index);

	if(c_iter != m_contents.end())
	{
		ItemInst* remove_inst = c_iter->second;
		m_contents.erase(contents_index);

		return remove_inst;
	}

	return nullptr;
}

void ItemInst::_DeleteContent(uint8 contents_index)
{
	ItemInst* delete_inst = _RemoveContent(contents_index);
	safe_delete(delete_inst);
}
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
