#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			3 Aug 2011
# Last Edit Date:		16 Feb 2013
# Software Application:	EQEmu, Infinity Server
# Description:			Hand in a no drop item that you can't use and it will be traded for something of approximate value in return
# ==============================================================

use warnings;
use DBI;
use POSIX; # implements ceil(), floor(), and a number of other mathematical and trigonometric functions.
use feature 'switch'; # allows use of given-when

use constant {
	TRUE => 1,
	FALSE => '',
	# IDs
	ID_I_TOKEN_FIRST => 252601, # I-token is an infinity token
	ID_I_TOKEN_LAST => 252654, 
	ID_I_TOKEN_CLOTH_HEAD => 252601,	# I-Token: Cloth Head Armor
	ID_I_TOKEN_CLOTH_ARMS => 252602,	# I-Token: Cloth Arm Armor
	ID_I_TOKEN_CLOTH_WRIST => 252603,	# I-Token: Cloth Wrist  Armor
	ID_I_TOKEN_CLOTH_HANDS => 252604,	# I-Token: Cloth Hands Armor
	ID_I_TOKEN_CLOTH_CHEST => 252605,	# I-Token: Cloth Chest Armor
	ID_I_TOKEN_CLOTH_LEGS => 252606,	# I-Token: Cloth Legs Armor
	ID_I_TOKEN_CLOTH_FEET => 252607,	# I-Token: Cloth Feet Armor
	ID_I_TOKEN_LEATHER_HEAD => 252611,	# I-Token: Leather Head Armor
	ID_I_TOKEN_LEATHER_ARMS => 252612,	# I-Token: Leather Arm Armor
	ID_I_TOKEN_LEATHER_WRIST => 252613,	# I-Token: Leather Wrist Armor
	ID_I_TOKEN_LEATHER_HANDS => 252614,	# I-Token: Leather Hands Armor
	ID_I_TOKEN_LEATHER_CHEST => 252615,	# I-Token: Leather Chest Armor
	ID_I_TOKEN_LEATHER_LEGS => 252616,	# I-Token: Leather Legs Armor
	ID_I_TOKEN_LEATHER_FEET => 252617,	# I-Token: Leather Feet Armor
	ID_I_TOKEN_CHAIN_HEAD => 252621,	# I-Token: Chainmail Head Armor
	ID_I_TOKEN_CHAIN_ARMS => 252622,	# I-Token: Chainmail Arm Armor
	ID_I_TOKEN_CHAIN_WRIST => 252623,	# I-Token: Chainmail Wrist Armor
	ID_I_TOKEN_CHAIN_HANDS => 252624,	# I-Token: Chainmail Hands Armor
	ID_I_TOKEN_CHAIN_CHEST => 252625,	# I-Token: Chainmail Chest Armor
	ID_I_TOKEN_CHAIN_LEGS => 252626,	# I-Token: Chainmail Legs Armor
	ID_I_TOKEN_CHAIN_FEET => 252627,	# I-Token: Chainmail Feet Armor
	ID_I_TOKEN_PLATE_HEAD => 252631,	# I-Token: Plate Head Armor
	ID_I_TOKEN_PLATE_ARMS => 252632,	# I-Token: Plate Arm Armor
	ID_I_TOKEN_PLATE_WRIST => 252633,	# I-Token: Plate Wrist Armor
	ID_I_TOKEN_PLATE_HANDS => 252634,	# I-Token: Plate Hands Armor
	ID_I_TOKEN_PLATE_CHEST => 252635,	# I-Token: Plate Chest Armor
	ID_I_TOKEN_PLATE_LEGS => 252636,	# I-Token: Plate Legs Armor
	ID_I_TOKEN_PLATE_FEET => 252637,	# I-Token: Plate Feet Armor
	
	ID_I_TOKEN_DS_CRYSTAL => 252651,	# I-Token: Damage Shield Crystal Lottery
	ID_I_TOKEN_AC_CRYSTAL => 252652,	# I-Token: AC Crystal Lottery
	
	ID_I_TOKEN_RANDOM_WEAPON => 252653,	# I-Token: Random Weapon
	ID_I_TOKEN_CLASS_WEAPON => 252654,	# I-Token: Class Weapon
	
	ID_DAMAGE_SHIELD_CRYSTAL1 => 255901, # Damage Shield Crystal 1
	ID_DAMAGE_SHIELD_CRYSTAL100 => 256000, # Damage Shield Crystal 100
	
	ID_AC_CRYSTAL1 => 253401, # AC Crystal 1
	ID_AC_CRYSTAL100 => 253500, # AC Crystal 100
	
	# Limits
	MAX_DS_CRYSTAL_REWARDS_EXP => 2, # Exponent for calculating the max DS crystals rewards for a given Prestige level
	MAX_AC_CRYSTAL_REWARDS_EXP => 1.5, # Exponent for calculating the max AC crystals rewards for a given Prestige level
	MIN_RANDOM_WEAPON_EXP => 2, # Exponent for calculating the min random-weapon statval reward for a given Prestige level
	MAX_RANDOM_WEAPON_EXP => 2.3, # Exponent for calculating the max random-weapon statval reward for a given Prestige level
	MIN_RANDOM_WEAPON_STAT_VAL => 50, # min random-weapon statval 
	
	EXP_STATVAL_BASE => 2, # Exponent for calculating the base StatVal
	MULTIPLIER_STATVAL_BASE => 7, # Multiplier for calculating the base StatVal
	MULTIPLIER_MIN_STATVAL_BASE => 90, # Multiplier for calculating the minimum base StatVal
	EXP_STATVAL_RANGE => 2, # Exponent for calculating the +/- range for base StatVal
	MULTIPLIER_STATVAL_RANGE => 1, # Exponent for calculating the +/- range for base StatVal
	MULTIPLIER_MIN_STATVAL_RANGE => 30, # Exponent for calculating the +/- range for base StatVal
	
	MULTIPLIER_RANDOM_WEAPON => 1,
	MULTIPLIER_CLASS_WEAPON => 1.65,
	MULTIPLIER_HEAD => 1.25,
	MULTIPLIER_ARMS => 1.2,
	MULTIPLIER_WRIST => 1,
	MULTIPLIER_HANDS => 1.1,
	MULTIPLIER_CHEST => 1.6,
	MULTIPLIER_LEGS => 1.3,
	MULTIPLIER_FEET => 1.15
};

my %classBitwise = (	#Convert each Class Name into a number for bitwise operations
	"Warrior" => 1,
	"Cleric" => 2,
	"Paladin" => 4,
	"Ranger" => 8,
	"Shadowknight" => 16,
	"Druid" => 32,
	"Monk" => 64,
	"Bard" => 128,
	"Rogue" => 256,
	"Shaman" => 512,
	"Necromancer" => 1024,
	"Wizard" => 2048,
	"Magician" => 4096,
	"Enchanter" => 8192,
	"Beastlord" => 16384,
	"Berserker" => 32768
);
my %raceBitwise = (	#Convert each Race Name into a number for bitwise operations
	"Human" => 1,
	"Barbarian" => 2,
	"Erudite" => 4,
	"Wood Elf" => 8,
	"High Elf" => 16,
	"Dark Elf" => 32,
	"Half Elf" => 64,
	"Dwarf" => 128,
	"Troll" => 256,
	"Ogre" => 512,
	"Halfling" => 1024,
	"Gnome" => 2048,
	"Iksar" => 4096,
	"Vah Shir" => 8192,
	"Froglok" => 16384
);

my $debug = TRUE;
	
sub EVENT_SAY {
	if ($text=~/Hail/i) {
		$client->Message(315,"If you find a I-Token that matches the type of armor you wear, hand it to me and I'll give you an armor piece. The more times you have Prestiged, the better your reward will be.");
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub EVENT_ITEM {
	my $prestigeLevel = $qglobals{prestige_level}; # this is the number of times a character has Pretiged
	my @itemArray = ();
	my @itemStats = ();
	my @Classes = ();
	my @Races = ();
	
	if ($item1) {push(@itemArray, $item1);}
	if ($item2) {push(@itemArray, $item2);}
	if ($item3) {push(@itemArray, $item3);}
	if ($item4) {push(@itemArray, $item4);}
	foreach (@itemArray) {
		my $currentItemName = quest::varlink($_);
		if (($_ >= ID_I_TOKEN_FIRST) && ($_ <= ID_I_TOKEN_LAST)) { # if the item is a I-token
			given($_){
				when(ID_I_TOKEN_DS_CRYSTAL) { # I-Token: Damage Shield Crystal Lottery --NOTE: drop rate one these tokens should be on average 1 for every 500 mobs slain
					getCrystalRewards(ID_DAMAGE_SHIELD_CRYSTAL1,ID_DAMAGE_SHIELD_CRYSTAL100,MAX_DS_CRYSTAL_REWARDS_EXP,$prestigeLevel);
					plugin::takeItems($_ => 1);
				}
				when(ID_I_TOKEN_AC_CRYSTAL) { # I-Token: AC Crystal Lottery --NOTE: drop rate one these tokens should be on average 1 for every 500 mobs slain
					getCrystalRewards(ID_AC_CRYSTAL1,ID_AC_CRYSTAL100,MAX_AC_CRYSTAL_REWARDS_EXP,$prestigeLevel);
					plugin::takeItems($_ => 1);
				}
				when(ID_I_TOKEN_RANDOM_WEAPON) { # I-Token: Random Weapon --NOTE: drop rate one these tokens should be on average 1 for every 50 mobs slain
					tradeItoken($_,$prestigeLevel,MULTIPLIER_RANDOM_WEAPON,"AND ((itemtype >= 0 and itemtype <= 7) OR itemtype = 35 OR itemtype = 45) ");
				}
				when(ID_I_TOKEN_CLASS_WEAPON) { # I-Token: Class Weapon --NOTE: drop rate one these tokens should be on average 1 for every 250 mobs slain
					tradeItoken($_,$prestigeLevel,MULTIPLIER_CLASS_WEAPON,"AND ((itemtype >= 0 and itemtype <= 7) OR itemtype = 35 OR itemtype = 45) AND (classes = 0 OR (classes & $classBitwise{$class}) > 0) AND (races = 0 OR (races & $raceBitwise{$race}) > 0) ");
				}
				
				when(ID_I_TOKEN_CLOTH_HEAD) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_HEAD,"AND itemtype = 10 AND classes = 15360 AND races = 65535 AND slots = 4 ");
				}
				when(ID_I_TOKEN_CLOTH_ARMS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_ARMS,"AND itemtype = 10 AND classes = 15360 AND races = 65535 AND slots = 128 ");
				}
				when(ID_I_TOKEN_CLOTH_WRIST) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_WRIST,"AND itemtype = 10 AND classes = 15360 AND races = 65535 AND slots = 1536 ");
				}
				when(ID_I_TOKEN_CLOTH_HANDS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_HANDS,"AND itemtype = 10 AND classes = 15360 AND races = 65535 AND slots = 4096 ");
				}
				when(ID_I_TOKEN_CLOTH_CHEST) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_CHEST,"AND itemtype = 10 AND classes = 15360 AND races = 65535 AND slots = 131072 ");
				}
				when(ID_I_TOKEN_CLOTH_LEGS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_LEGS,"AND itemtype = 10 AND classes = 15360 AND races = 65535 AND slots = 262144 ");
				}
				when(ID_I_TOKEN_CLOTH_FEET) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_FEET,"AND itemtype = 10 AND classes = 15360 AND races = 65535 AND slots = 524288 ");
				}
				
				when(ID_I_TOKEN_LEATHER_HEAD) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_HEAD,"AND itemtype = 10 AND classes = 16480 AND races = 65535 AND slots = 4 ");
				}
				when(ID_I_TOKEN_LEATHER_ARMS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_ARMS,"AND itemtype = 10 AND classes = 16480 AND races = 65535 AND slots = 128 ");
				}
				when(ID_I_TOKEN_LEATHER_WRIST) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_WRIST,"AND itemtype = 10 AND classes = 16480 AND races = 65535 AND slots = 1536 ");
				}
				when(ID_I_TOKEN_LEATHER_HANDS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_HANDS,"AND itemtype = 10 AND classes = 16480 AND races = 65535 AND slots = 4096 ");
				}
				when(ID_I_TOKEN_LEATHER_CHEST) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_CHEST,"AND itemtype = 10 AND classes = 16480 AND races = 65535 AND slots = 131072 ");
				}
				when(ID_I_TOKEN_LEATHER_LEGS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_LEGS,"AND itemtype = 10 AND classes = 16480 AND races = 65535 AND slots = 262144 ");
				}
				when(ID_I_TOKEN_LEATHER_FEET) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_FEET,"AND itemtype = 10 AND classes = 16480 AND races = 65535 AND slots = 524288 ");
				}
				
				when(ID_I_TOKEN_CHAIN_HEAD) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_HEAD,"AND itemtype = 10 AND classes = 33544 AND races = 65535 AND slots = 4 ");
				}
				when(ID_I_TOKEN_CHAIN_ARMS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_ARMS,"AND itemtype = 10 AND classes = 33544 AND races = 65535 AND slots = 128 ");
				}
				when(ID_I_TOKEN_CHAIN_WRIST) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_WRIST,"AND itemtype = 10 AND classes = 33544 AND races = 65535 AND slots = 1536 ");
				}
				when(ID_I_TOKEN_CHAIN_HANDS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_HANDS,"AND itemtype = 10 AND classes = 33544 AND races = 65535 AND slots = 4096 ");
				}
				when(ID_I_TOKEN_CHAIN_CHEST) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_CHEST,"AND itemtype = 10 AND classes = 33544 AND races = 65535 AND slots = 131072 ");
				}
				when(ID_I_TOKEN_CHAIN_LEGS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_LEGS,"AND itemtype = 10 AND classes = 33544 AND races = 65535 AND slots = 262144 ");
				}
				when(ID_I_TOKEN_CHAIN_FEET) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_FEET,"AND itemtype = 10 AND classes = 33544 AND races = 65535 AND slots = 524288 ");
				}
				
				when(ID_I_TOKEN_PLATE_HEAD) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_HEAD,"AND itemtype = 10 AND classes = 151 AND races = 65535 AND slots = 4 ");
				}
				when(ID_I_TOKEN_PLATE_ARMS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_ARMS,"AND itemtype = 10 AND classes = 151 AND races = 65535 AND slots = 128 ");
				}
				when(ID_I_TOKEN_PLATE_WRIST) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_WRIST,"AND itemtype = 10 AND classes = 151 AND races = 65535 AND slots = 1536 ");
				}
				when(ID_I_TOKEN_PLATE_HANDS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_HANDS,"AND itemtype = 10 AND classes = 151 AND races = 65535 AND slots = 4096 ");
				}
				when(ID_I_TOKEN_PLATE_CHEST) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_CHEST,"AND itemtype = 10 AND classes = 151 AND races = 65535 AND slots = 131072 ");
				}
				when(ID_I_TOKEN_PLATE_LEGS) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_LEGS,"AND itemtype = 10 AND classes = 151 AND races = 65535 AND slots = 262144 ");
				}
				when(ID_I_TOKEN_PLATE_FEET) {
					tradeItoken($_,$prestigeLevel,MULTIPLIER_FEET,"AND itemtype = 10 AND classes = 151 AND races = 65535 AND slots = 524288 ");
				}
				default {
					$client->Message(13, "ERROR: Somehow an I-Token value was returned that has not been accounted for.");
				} # END given-default
			} # END given
		} # END if
		else {
			$client->Message(315,"Alas $name, I cannot trade this item.");
		}
	}
	plugin::returnUnusedItems();
}

# Args: int itemIdI-token, int prestigeLevel, float baseStatValSlotMultiplier, string sqlAndClause
# Returns: void
sub tradeItoken {
	my $dbTrys = 0;
	my $tradeMade = 0;
	my $currentItemName = quest::varlink($_[0]);
	while (not $tradeMade) { # continue to try the database for a valid (non-NULL) result
		my $baseStatVal = int((($_[1]+1)**EXP_STATVAL_BASE * MULTIPLIER_STATVAL_BASE) + (($_[1]+1) * MULTIPLIER_MIN_STATVAL_BASE)) * $_[2]; # starting statVal before a range is applied
		my $rangeStatVal = int((($_[1]+1)**EXP_STATVAL_RANGE * MULTIPLIER_STATVAL_RANGE) + (($_[1]+1) * MULTIPLIER_MIN_STATVAL_RANGE)); # statVal +/- range
		my $lowStatVal = floor($baseStatVal - $rangeStatVal - ($rangeStatVal * $dbTrys));
		my $highStatVal = ceil($baseStatVal + $rangeStatVal + ($rangeStatVal * $dbTrys));
		my $sql = "SELECT id FROM v_statvalue_items WHERE StatValue >= $lowStatVal AND StatValue <= $highStatVal " . $_[3] . " ORDER BY rand() limit 1;";
		my @randomItokenItem = plugin::callDatabase($sql,TRUE,$debug);
		if (defined $randomItokenItem[0]) { #if some valid results came back from the DB
			my $tradeItemName = quest::varlink($randomItokenItem[0]);
			$client->Message(315,"Thanks $name, I am trading you this $tradeItemName for the $currentItemName you gave me.");
			$tradeMade = 1;
			quest::summonitem($randomItokenItem[0]);
			quest::ding(); # not really a ding, it's the quest complete fanfare
		}
		else {
			$dbTrys++;
			if ($debug) {$client->Message(13,"Failed to get a valid item from db, dbTrys = $dbTrys. Trying again...");} #debug
		}
	}
	plugin::takeItems($_[0] => 1);
}

# Args: int ID_CRYSTAL1, int ID_CRYSTAL100, float MAX_CRYSTAL_REWARDS_EXP, int prestigeLevel
# Returns: void
sub getCrystalRewards {
	my $minRewards = ($_[3] + 1);
	my $maxRewards = int(($_[3] + 2)**$_[2]);
	my $randReward = int(rand($maxRewards - $minRewards)); # random number from 0 to the-full-range
	$randReward = $randReward + $minRewards;
	$client->Message(315,"From $minRewards to $maxRewards your roll was $randReward, you shall receive that many Crystals");
	my $rewardModulus = $randReward % 100;
	if ($debug) {$client->Message(1,"rewardModulus=$rewardModulus");} #debug
	my $rewardCentiCrystals = int($randReward / 100);
	if ($rewardModulus) {
		quest::summonitem(($_[0] + $rewardModulus - 1), 1);
	}
	if ($rewardCentiCrystals) {
		quest::summonitem($_[1], $rewardCentiCrystals);
	}
	quest::ding(); # not really a ding, it's the quest complete fanfare
}