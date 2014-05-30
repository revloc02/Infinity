#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			1 Sep 2011
# Last Edit Date:		31 Dec 2012
# Software Application:	EQEmu, Infinity Server
# Description:			Get a random item to go find for a random reward from a list
# ==============================================================

use warnings;
use POSIX; # implements ceil(), floor(), and a number of other mathematical and trigonometric functions.
use feature 'switch'; # allows use of given-when

use constant {
	TRUE => 1,
	FALSE => '',
	JACKPOT_STATVAL_MIN => 10000, # minimum stat val for the highest prize
	SECOND_JACKPOT_STATVAL_MIN => 2000, # minimum stat val for the second highest prize
	ITEM_FIRST_PRIZE => 250000, # Ring of Infinity Upgrade
	THIRD_PRIZE_STATVAL_MAX => 8000,
	ITEM_FOURTH_PRIZE => 252001, # Infinity Charm Upgrade
	SEVENTH_PRIZE_STATVAL_MAX => 2000,
	RANDOM_CRYSTAL_ID_OFFSET => 253101, # ID of the first Infinity crystal in the database
	ITEM_ID_FOR_BIG_LOTTERY => 22503, # blue diamond
	ITEM_ID_TO_RESET_RANDOM_ITEM_QUEST => 252575, # Confirmation Item: Reset Random Quest
	
	# jackpot prize ranges
	JACKPOT => 			1000,
	SECOND_JACKPOT => 	998,
	FIRST_PRIZE => 		980,
	SECOND_PRIZE => 	900,
	THIRD_PRIZE => 		750,
	FOURTH_PRIZE => 	600,
	FIFTH_PRIZE => 		400,
	SIXTH_PRIZE => 		200,
	SEVENTH_PRIZE => 	100
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
# made these variables because apparently the plugin::takeItems function does not accept constants
my $ITEM_ID_FOR_BIG_LOTTERY = ITEM_ID_FOR_BIG_LOTTERY;
my $ITEM_ID_TO_RESET_RANDOM_ITEM_QUEST = ITEM_ID_TO_RESET_RANDOM_ITEM_QUEST;

my $debug = TRUE;

sub EVENT_SAY {
	establishQuestGlobals();
	my $epicWeaponLevel = $qglobals{epic_weapon_level};
	my $retrieve = quest::saylink("retrieve",1);
	my $randomitemquest = quest::saylink("random item quest",1);
	my $check = quest::saylink("check",1);
	my $reset = quest::saylink("reset",1);
	my $bluediamondlottery = quest::saylink("Blue Diamond Lottery",1);
	
	my $resetRandomItemQuest = quest::varlink($ITEM_ID_TO_RESET_RANDOM_ITEM_QUEST);
	my $bluediamond = quest::varlink($ITEM_ID_FOR_BIG_LOTTERY);
	
	if ($text=~/Hail/i) {
		if ($debug) {$client->Message(1,"random_item_quest qglobals=$qglobals{random_item_quest} epic_weapon_level qglobals=$epicWeaponLevel MaxSV=$epicToMaxSV{$qglobals{epic_weapon_level}}");} #debug
		$client->Message(315,"Hey $name. I can give you a quest to go and $retrieve a random item, or you can try the $bluediamondlottery for a chance at a very hansome prize. Also if you are unhappy with a previous quest I have given you it can be $reset for a price.");
	}
	if ($text =~ /retrieve/i) {
		$client->Message(315, "You will be sent to find a fairly commonly dropped random item, and when you return and give it to me your reward will be a random item from the database--could be ANYTHING! Would you like a $randomitemquest? Or perhaps you'd like to $check to see if I've already given one?");
	}
	if ($text =~ /random item quest/i) {
		if ($qglobals{random_item_quest}) {
			my $randomItemLink = quest::varlink($qglobals{random_item_quest});
			$client->Message(315, "Sorry $name, I already given you a assignment, your quest is to go get one $randomItemLink. There is a way to remove the Random Quest, for a price I can $reset it for you.");
		} else {
			establishRandomQuest();
		}
	}
	if ($text =~ /check/i) {
		if ($qglobals{random_item_quest}) {
			my $randomItemLink = quest::varlink($qglobals{random_item_quest});
			$client->Message(315, "Yes $name, we have established a quest for you to go get one $randomItemLink. There is a way to remove the Random Quest, for a price I can $reset it for you.");
		} else {
			$client->Message(315, "You have not been assigned a random item quest yet.");
		}
	}
	if ($text =~ /reset/i) {
		$client->Message(315, "If you would like to be reassigned to a different random item quest you buy a $resetRandomItemQuest from me and then give it back to me. Careful doing this because once you hand the $resetRandomItemQuest back to me the quest will be reset (buying the $resetRandomItemQuest and handing it back IS the confirmation process).");
	}
	if ($text =~ /Blue Diamond Lottery/i) {
		$client->Message(315, "Give me a $bluediamond for a chance to win several different levels of prizes.");
	}
	if ($text=~/resetqglobal/i) {
		if ($debug) {
			# for debugging to reset qglobal
			$client->Message(1,"reset qglobal random_item_quest");
			quest::setglobal("random_item_quest", 0, 5, "F");
		}
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub EVENT_ITEM {
	establishQuestGlobals();
	my $epicWeaponLevel = $qglobals{epic_weapon_level} or 0;
	my $prestigeLevel = $qglobals{prestige_level} or 0;
	if (plugin::takeItems($ITEM_ID_FOR_BIG_LOTTERY => 1)) {
		my $randReward = ceil(rand(JACKPOT)) + $prestigeLevel; # TODO  maybe I should add in Prestige Level as a bonus, and identify that in the prize message
		given($randReward) {
			when ($randReward >= JACKPOT) {
				my @prize = plugin::callDatabase("SELECT id FROM v_statvalue_items WHERE StatValue >= " . JACKPOT_STATVAL_MIN . " AND (classes = 0 OR (classes & $classBitwise{$class}) > 0) AND (races = 0 OR (races & $raceBitwise{$race}) > 0) ORDER BY rand() limit 1;",TRUE,$debug);
				deliverPrize($randReward,$prize[0],1,"Jackpot",$prestigeLevel);
			}
			when ($randReward >= SECOND_JACKPOT) {
				my @prize = plugin::callDatabase("SELECT id, itemtype FROM v_statvalue_items WHERE StatValue >= " . SECOND_JACKPOT_STATVAL_MIN . " ORDER BY rand() limit 1;",TRUE,$debug);
				my $numberOfItems = (($prize[1] == 14) || ($prize[1] == 15)) ? 10 : 1;
				deliverPrize($randReward,$prize[0],$numberOfItems,"Jackpot",$prestigeLevel);
			}
			when ($randReward >= FIRST_PRIZE) {
				deliverPrize($randReward,ITEM_FIRST_PRIZE,1,"");
			}
			when ($randReward >= SECOND_PRIZE) {
				my $randCrystalId = (100 * int(rand(33))) + RANDOM_CRYSTAL_ID_OFFSET + (ceil(($randReward - SECOND_PRIZE) / 10) - 1);
				deliverPrize($randReward,$randCrystalId,1,"Crystal",$prestigeLevel);
			}
			when ($randReward >= THIRD_PRIZE) {
				my @prize = plugin::callDatabase("SELECT id, itemtype FROM v_statvalue_items WHERE StatValue > 0 AND StatValue <= " . THIRD_PRIZE_STATVAL_MAX . " ORDER BY rand() limit 1;",TRUE,$debug);
				my $numberOfItems = (($prize[1] == 14) || ($prize[1] == 15)) ? ceil(($randReward - THIRD_PRIZE) / 10) : 1;
				deliverPrize($randReward,$prize[0],$numberOfItems,"Item",$prestigeLevel);
			}
			when ($randReward >= FOURTH_PRIZE) {
				deliverPrize($randReward,ITEM_FOURTH_PRIZE,1,"");
			}
			when ($randReward >= FIFTH_PRIZE) {
				my $randRoll = $randReward - $prestigeLevel;
				$client->Message(315,"From 1 to 1000 your roll was $randRoll plus your Prestige Level $prestigeLevel as a bonus for a total of $randReward and so your Break-Even Prize is 250 pp.");
				quest::givecash(0,0,0,250); #atm this = cost of a blue diamond
			}
			when ($randReward >= SIXTH_PRIZE) {
				my @prize = plugin::callDatabase("SELECT id FROM items WHERE itemtype = 14 OR itemtype = 15 ORDER BY rand() limit 1",TRUE,$debug);
				deliverPrize($randReward,$prize[0],ceil(($randReward - SIXTH_PRIZE) / 10),"Consolation",$prestigeLevel);
			}
			when ($randReward >= SEVENTH_PRIZE) {
				my @prize = plugin::callDatabase("SELECT id, itemtype FROM v_statvalue_items WHERE StatValue > 0 AND StatValue <= " . SEVENTH_PRIZE_STATVAL_MAX . " ORDER BY rand() limit 1;",TRUE,$debug);
				my $numberOfItems = (($prize[1] == 14) || ($prize[1] == 15)) ? ceil(($randReward - SEVENTH_PRIZE) / 10) : 1;
				deliverPrize($randReward,$prize[0],$numberOfItems,"Item",$prestigeLevel);
			}
			default {
				my @prize = plugin::callDatabase("SELECT Itemid FROM forage ORDER BY rand() limit 1",TRUE,$debug);
				deliverPrize($randReward,$prize[0],ceil(($randReward) / 10),"Consolation",$prestigeLevel);
			}
		} # END given
	}
	if (plugin::givenItems($ITEM_ID_TO_RESET_RANDOM_ITEM_QUEST => 1)) {
		if ($qglobals{random_item_quest} > 0) {
			plugin::takeItems($ITEM_ID_TO_RESET_RANDOM_ITEM_QUEST => 1);
			my $randomitemquest = quest::saylink("random item quest",1);
			quest::setglobal("random_item_quest", 0, 5, "F"); #clear out the item ID from the global
			$client->Message(315,"Excellent $name, I relinquish you from your current quest. Would you like a new $randomitemquest?");
		} else {
			$client->Message(315,"You have not been assigned a random item quest yet. You can keep the card.");
		}
	}
	if (($qglobals{random_item_quest} > 0) && (plugin::takeItems($qglobals{random_item_quest} => 1))) {
		my $minRandomItemStatVal = (($epicWeaponLevel**2) * 500) + 2000;
		my @RandomItemReward = plugin::callDatabase("SELECT id, StatValue FROM v_statvalue_items WHERE StatValue <= $minRandomItemStatVal ORDER BY rand() limit 1;",TRUE,$debug);
		my $randomItemRewardLink = quest::varlink($RandomItemReward[0]);
		quest::ding(); # not really a ding, it's the quest complete fanfare
		$client->Message(315, "And your reward is...$randomItemRewardLink. And the StatValue on that is: $RandomItemReward[1]");
		quest::summonitem($RandomItemReward[0]);
		quest::setglobal("random_item_quest", 0, 5, "F"); #clear out the item ID from the global
	}
	plugin::returnUnusedItems();
}

# Args: none
# Returns: void
sub establishRandomQuest {
	my $dropRateMin = 50 - (($ulevel**1.5)/12); # the higher the level the lower the droprate can go. Lvl 1 = 49%+, Lvl 65 = 6%+ (droprates can go above 100%)
	$dropRateMin = ($dropRateMin < 0) ? 0 : floor($dropRateMin); # must be at least zero
	my $levelMax = $ulevel + 10;
	my @RandomItem = plugin::callDatabase("SELECT itemId, NpcName, zone FROM inf_commonlootdrops WHERE TruDropRate >= $dropRateMin AND level <= $levelMax ORDER BY rand() limit 1",TRUE,$debug);
	my $randomItemLink = quest::varlink($RandomItem[0]);
	quest::setglobal("random_item_quest", $RandomItem[0], 5, "F");
	$client->Message(315, "Your quest is to go get one $randomItemLink. This item could potentially be found on many different beings but I can tell you that one creature that may have this item is $RandomItem[1] (you better write that down), and one place to find such $RandomItem[1] is $RandomItem[2] (you better write that down too).");
}

# Args: int randomRoll, int item, int numberOfItems, String message, int prestigeLevel
# Returns: void
sub deliverPrize {
	my $prizeLink = quest::varlink($_[1]);
	my $randRoll = $_[0] - $_[4];
	$client->Message(315,"From 1 to 1000 your roll was $randRoll plus your Prestige Level $_[4] as a bonus for a total of $_[0] and so your $_[3] Prize is $_[2] $prizeLink.");
	quest::ding(); # not really a ding, it's the quest complete fanfare
	quest::summonitem($_[1], $_[2]);
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