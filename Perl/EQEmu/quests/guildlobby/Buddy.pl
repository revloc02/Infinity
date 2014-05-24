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

use constant {
	TRUE => 1,
	FALSE => '',
	STATVAL_RANGE_MOD => 10, # this is +/- the random percent of the StatValue
	REWARD_LEVEL_RANGE_MOD => 1600, #sqrt of a random number from this range is taken and then subtracted from 100
	PRESTIGE_EXPONENT => 1.6, #makes the reward range modifier smaller for better rewards (careful to avoid making the sqrt negative, basically this formula needs to be true: 100^PRESTIGE_EXPONENT < REWARD_LEVEL_RANGE_MOD)
	NUM_DATABASE_TRYS => 3,
	DEFAULT_TRADE_ITEM_ID => 10032, #Star Ruby
	REQ_LEVEL_OFFSET => 0, #offset from character level for the received item's max reqlevel
	CUSTOM_INFINTY_ITEM_START_ID => 250000 # first id of custom Infinity items
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
	my $unable = quest::saylink("unable",1);
	#my $deity = $client->GetDeity();
	
	if ($text=~/Hail/i) {
		$client->Message(315,"If you have an item that you are $unable to use I will gladly trade it for something you can use.");
	}
	if ($text =~/unable/i)	{
		$client->Message(315,"This must be an item you cannot trade, and your race or class cannot use it ($race $class $ulevel), and it must have some value to me.");
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub EVENT_ITEM {
	establishQuestGlobals();
	my $infinityArmor = quest::saylink("Infinity Armor",1);

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
		if ($_ < CUSTOM_INFINTY_ITEM_START_ID) { # if the item is not one of the custom Infinity items
			@itemStats = plugin::callDatabase("SELECT * FROM v_statvalue_items WHERE id = $_",TRUE,$debug);
			if (defined $itemStats[0]) { #if some valid results came back from the DB
				@Classes = getClasses($itemStats[2]);
				@Races = getRaces($itemStats[3]);
				if ($debug) {$client->Message(1,"Item=$itemStats[0], StatVal=$itemStats[4], NoDrop=$itemStats[9], Classes=@Classes, Races = @Races.");} #debug
				if (!$itemStats[9]) { #if the item is NoDrop
					if ($debug) {$client->Message(1,"matchClass(@Classes)");} #debug
					if ((!matchClass(@Classes)) || (!matchRace(@Races))) { #if the item does not matches the character's class or race
						if ($itemStats[4] > 0) { #if the item has StatValue
							my $dbTrys = 0;
							my $tradeMade = FALSE;
							#100 minus a psuedo-random val between 1-40 (skewing the result to be more likely lower--further from 100). As PCs Pretige the range will lessen for better rewards
							my $rewardLevel = 100-ceil(sqrt(rand(REWARD_LEVEL_RANGE_MOD-$prestigeLevel**PRESTIGE_EXPONENT)));
							# my $rewardLevel = 100-ceil(sqrt(rand(REWARD_LEVEL_RANGE_MOD)));
							while ($dbTrys < NUM_DATABASE_TRYS) { #number of times to try the database for a valid (non-NULL) result
								my @tradeItemStats = ();
								my $retryMod = $dbTrys*STATVAL_RANGE_MOD; # if db is accessed more than once for a valid item the StatVal range increases significantly
								my $lowStatVal = floor($itemStats[4]*($rewardLevel - STATVAL_RANGE_MOD - $retryMod)/100) - $retryMod; #retryMod at end of formula make a wider range for low StatVals
								my $highStatVal = ceil($itemStats[4]*($rewardLevel + STATVAL_RANGE_MOD + $retryMod)/100) + $retryMod; #retryMod inside parenths make a wider range for higher StatVals
								my $maxReqLevel = $ulevel + REQ_LEVEL_OFFSET; #item's reqlevel restriction must be less than $maxReqLevel
								my $sql = "SELECT id, itemtype FROM v_statvalue_items WHERE StatValue >= $lowStatVal AND StatValue <= $highStatVal AND (classes = 0 OR (classes & $classBitwise{$class}) > 0) AND (races = 0 OR (races & $raceBitwise{$race}) > 0) AND reqlevel <= $maxReqLevel ORDER BY rand() limit 1;";
								@tradeItemStats = plugin::callDatabase($sql,TRUE,$debug);
								if (defined $tradeItemStats[0]) { #if some valid results came back from the DB
									$dbTrys=NUM_DATABASE_TRYS; #results are valid so don't try the db again
									my $tradeItemName = quest::varlink($tradeItemStats[0]);
									$client->Message(315,"Thanks $name, I am trading you this $tradeItemName for the $currentItemName you gave me.");
									if ($rewardLevel > 96) {$client->Message(315,"Wow, that was an A+ trade for you.");}
									if (($rewardLevel <= 96) && ($rewardLevel > 86)) {$client->Message(315,"You got good value on that trade.");}
									$tradeMade = TRUE;
									(($tradeItemStats[1] == 14) || ($tradeItemStats[1] == 15)) ? quest::summonitem($tradeItemStats[0], 10) : quest::summonitem($tradeItemStats[0]); # if the item is food or drink
									quest::ding(); # not really a ding, it's the quest complete fanfare
								}
								else {
									$dbTrys++;
									if ($debug) {$client->Message(13,"Failed to get a valid item from db, dbTrys = $dbTrys. Trying again...");} #debug
								}
							}
							if (!$tradeMade) { # if the loop ends and a valid item did not return from the db then trade the default item
								$client->Message(315,"Well $name, I couldn't find anything decent for you, so just take one of these.");
								quest::summonitem(DEFAULT_TRADE_ITEM_ID); #This is very unlikely
							}
							plugin::takeItems($_ => 1);
						}
						else {
							$client->Message(315,"Sorry $name, this $currentItemName is worthless to me, perhaps you could sell it?.");
						}
					}
					else {
						$client->Message(315,"Sorry $name, this $currentItemName is an item that you can already use.");
						if ($itemStats[5] > $ulevel) {
							$client->Message(315,"You will have to wait until you are high enough level though.");
						}
						else {
							$client->Message(315,"(Although it is possible that one who worships your deity can't use this item, which if that's the case I can't help you with a trade, sorry.)");
						}
					}
				}
				else {
					$client->Message(315,"Sorry $name, this $currentItemName is tradeable and I can only take NoDrop items and trade them for you.");
				}
			}
			else {
				$client->Message(13,"ERROR: Likely with the database connection, please try again.");
			}
		}
		else {
			$client->Message(315,"Alas $name, I cannot trade this item.");
		}
	}
	plugin::returnUnusedItems();
}

sub getClasses {
	#send in a number and it returns as array of classes
	my @classArray = ();
	if ($_[0] & 1) {
		push(@classArray, "Warrior");
	}
	if ($_[0] & 2) {
		push(@classArray, "Cleric");
	}
	if ($_[0] & 4) {
		push(@classArray, "Paladin");
	}
	if ($_[0] & 8) {
		push(@classArray, "Ranger");
	}
	if ($_[0] & 16) {
		push(@classArray, "Shadowknight");
	}
	if ($_[0] & 32) {
		push(@classArray, "Druid");
	}
	if ($_[0] & 64) {
		push(@classArray, "Monk");
	}
	if ($_[0] & 128) {
		push(@classArray, "Bard");
	}
	if ($_[0] & 256) {
		push(@classArray, "Rogue");
	}
	if ($_[0] & 512) {
		push(@classArray, "Shaman");
	}
	if ($_[0] & 1024) {
		push(@classArray, "Necromancer");
	}
	if ($_[0] & 2048) {
		push(@classArray, "Wizard");
	}
	if ($_[0] & 4096) {
		push(@classArray, "Magician");
	}
	if ($_[0] & 8192) {
		push(@classArray, "Enchanter");
	}
	if ($_[0] & 16384) {
		push(@classArray, "Beastlord");
	}
	if ($_[0] & 32768) {
		push(@classArray, "Berserker");
	}
	return (@classArray)
}

# Args: int raceBitEnum
# Returns: Array races
sub getRaces {
	my @raceArray = ();
	if ($_[0] & 1) {
		push(@raceArray, "Human");
	}
	if ($_[0] & 2) {
		push(@raceArray, "Barbarian");
	}
	if ($_[0] & 4) {
		push(@raceArray, "Erudite");
	}
	if ($_[0] & 8) {
		push(@raceArray, "Wood Elf");
	}
	if ($_[0] & 16) {
		push(@raceArray, "High Elf");
	}
	if ($_[0] & 32) {
		push(@raceArray, "Dark Elf");
	}
	if ($_[0] & 64) {
		push(@raceArray, "Half Elf");
	}
	if ($_[0] & 128) {
		push(@raceArray, "Dwarf");
	}
	if ($_[0] & 256) {
		push(@raceArray, "Troll");
	}
	if ($_[0] & 512) {
		push(@raceArray, "Ogre");
	}
	if ($_[0] & 1024) {
		push(@raceArray, "Halfling");
	}
	if ($_[0] & 2048) {
		push(@raceArray, "Gnome");
	}
	if ($_[0] & 4096) {
		push(@raceArray, "Iksar");
	}
	if ($_[0] & 8192) {
		push(@raceArray, "Vah Shir");
	}
	if ($_[0] & 16384) {
		push(@raceArray, "Froglok");
	}
	return (@raceArray)
}

# Args: Array classesOfTheItem
# Returns: boolean classMatch of char's class with item's classes
sub matchClass {
	my $classMatch = FALSE;
	foreach (@_) {
		if ($_ eq $class) {
			$classMatch = TRUE;
			last;
		}
	}
	return $classMatch;
}

# Args: Array racesOfTheItem
# Returns: boolean raceMatch of char's race with item's races
sub matchRace {
	my $RaceMatch = FALSE;
	foreach (@_) {
		if ($_ eq $race) {
			$RaceMatch = TRUE;
			last;
		}
	}
	return $RaceMatch;
}

# Args: none
# Returns: void
sub establishQuestGlobals { # if a quest_global does not exist, this will create one
	quest::setglobal("epic_weapon_level", 0, 5, "F") unless defined $qglobals{epic_weapon_level};
	quest::setglobal("prestige_level", 0, 5, "F") unless defined $qglobals{prestige_level};
	quest::setglobal("guildhall_flag", 0, 5, "F") unless defined $qglobals{guildhall_flag};
	quest::setglobal("spells_scribed_level", 0, 5, "F") unless defined $qglobals{spells_scribed_level};
	quest::setglobal("goldgreat_newbie_charm", 0, 5, "F") unless defined $qglobals{goldgreat_newbie_charm};
}