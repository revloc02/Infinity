#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			30 Nov 2011
# Last Edit Date:		10 Feb 2013
# Software Application:	EQEmu, Infinity Server
# Description:			Epic Weapon NPC
# ==============================================================

use warnings;
use DBI;

use constant {
	TRUE => 1,
	FALSE => '',
	CHAR_LEVEL => 0, # Index for character-level requirement
	PRESTIGE_LEVEL => 1, # Index for prestige-level requirement
	AA_COST => 2, # Index for AA cost (unspent AAs)
	PLATINUM_COST => 3, # Index for platinum requirement
	FLAGS => 4, # Index for flags requirement
	TRADESKILL_ITEM => 5, # Index for tradeskill item requirement
	QUEST_ITEM => 6 # Index for prestige-level requirement
};

my %epicWeapon = (	#Convert each Class Name into a number for array operations
# 2nd index value:       0     1     2     3      4      5      6      7      8      9      10
# EpicWeaponLevel:       1    1.5    2     3      4      5      6      7      8      9      10
	"Bard"         => [20542,77631,77640,257003,257004,257005,257006,257007,257008,257009,257010],
	"Beastlord"    => [ 8495,52911,57054,257103,257104,257105,257106,257107,257108,257109,257110],
	"Berserker"    => [68299,18398,18609,257203,257204,257205,257206,257207,257208,257209,257210],
	"Cleric"       => [ 5532, 9955,20076,257303,257304,257305,257306,257307,257308,257309,257310],
	"Druid"        => [20490,62863,62880,257403,257404,257405,257406,257407,257408,257409,257410],
	"Enchanter"    => [10650,52952,52962,257503,257504,257505,257506,257507,257508,257509,257510],
	"Magician"     => [55273,19092,19839,257603,257604,257605,257606,257607,257608,257609,257610],
	"Monk"         => [10652,61025,67742,257703,257704,257705,257706,257707,257708,257709,257710],
	"Necromancer"  => [20544,62581,64067,257803,257804,257805,257806,257807,257808,257809,257810],
	"Paladin"      => [10099,64031,48147,257903,257904,257905,257906,257907,257908,257909,257910],
	"Ranger"       => [20487,62627,62649,258003,258004,258005,258006,258007,258008,258009,258010],
	"Rogue"        => [11057,52347,52348,258103,258104,258105,258106,258107,258108,258109,258110],
	"Shadowknight" => [14383,50003,48136,258203,258204,258205,258206,258207,258208,258209,258210],
	"Shaman"       => [10651,57400,57405,258303,258304,258305,258306,258307,258308,258309,258310],
	"Warrior"      => [66175,60321,60332,258403,258404,258405,258406,258407,258408,258409,258410],
	"Wizard"       => [14341,12665,16576,258503,258504,258505,258506,258507,258508,258509,258510]
);

#TODO flesh out Quest items all the way to epic 10
my @epicRequirement = ();
# 2nd index value       0   1   2       3  4       5       6
# Requirement         Lvl   P  AA      pp  F    TrSk   Quest
$epicRequirement[0] = [50,  1,   1,    100, 0,  FALSE,  FALSE]; # Epic 1
$epicRequirement[1] = [55,  2,   3,    506, 0,  13475,  FALSE]; # Epic 1.5
$epicRequirement[2] = [60,  3,   8,   1600, 0,  FALSE,  18302]; # Epic 2
$epicRequirement[3] = [65,  4,  27,   8100, 1,  19995,   7276]; # Epic 3
$epicRequirement[4] = [65,  6,  64,  25600, 1,  FALSE,  27258]; # Epic 4
$epicRequirement[5] = [65,  9, 125,  62500, 1,   9752, 252581]; # Epic 5
$epicRequirement[6] = [66, 14, 216, 129600, 1,  FALSE, 252582]; # Epic 6
$epicRequirement[7] = [67, 22, 343, 240100, 2,   9662, 252583]; # Epic 7
$epicRequirement[8] = [68, 35, 512, 409600, 2,  FALSE, 252584]; # Epic 8
$epicRequirement[9] = [69, 56, 729, 656100, 2,   9251, 252585]; # Epic 9
$epicRequirement[10]= [70, 90,1000,1000000, 2,      0,  00000]; # Epic 10

my $debug = TRUE;

sub EVENT_SAY {
	establishQuestGlobals();
	my $epicWeaponLevel = $qglobals{epic_weapon_level};
	my $epicWeapons = quest::saylink("epic weapons",1);
	my $requirements = quest::saylink("requirements",1);
	
	if ($text=~/Hail/i) {
		if ($debug) {$client->Message(1,"epic_weapon_level qglobals=$epicWeaponLevel");} #debug
		$client->Message(315,"Hey, $name I give out quests for $epicWeapons.");
		if ($epicWeaponLevel == 0) {
			$client->Message(315, "You have not gotten an epic weapon yet. Would you like to see the $requirements for you next Epic Weapon?.");
		} elsif ($epicWeaponLevel == 1) {
			$client->Message(315, "So, I see you've worked with me before and gotten your first epic, excellent! Would you like to see the $requirements for your Epic 1.5 Weapon?.");
		} elsif ($epicWeaponLevel == 2) {
			$client->Message(315, "Now then $name, you have your Epic 1.5, would you like to see the $requirements for the Epic 2.0?.");
		} elsif ($epicWeaponLevel == 11) {
			$client->Message(315, "You are a true Legend $name, the Epic 10 Weapon is the most powerful weapon for the $class class.");
		} else {
			my $currentEpicWeaponLevel = $epicWeaponLevel - 1;
			$client->Message(315, "You currently have your Epic $currentEpicWeaponLevel Weapon. Would you like to see the $requirements for your Epic $epicWeaponLevel Weapon?.");
		}
	}
	if ($text =~ /epic weapons/i)	{
		$client->Message(315, "For each class there are epic weapons levels up to Epic 10. Fulfill the $requirements and pay the costs to obtain more and more powerful epic weapons.");
	}
	if ($text =~ /requirements/i)	{
		if ($epicWeaponLevel < 11) {
			$client->Message(7, "Requirements:");
			$client->Message(263, "-----Level: $epicRequirement[$epicWeaponLevel][CHAR_LEVEL]");
			$client->Message(263, "-----Prestige: $epicRequirement[$epicWeaponLevel][PRESTIGE_LEVEL]");
			$client->Message(263, "-----AA cost: $epicRequirement[$epicWeaponLevel][AA_COST]");
			$client->Message(263, "-----pp: $epicRequirement[$epicWeaponLevel][PLATINUM_COST]");
			$client->Message(263, "-----Infinity Flags: $epicRequirement[$epicWeaponLevel][FLAGS]");
			my $tradeSkillItemLink = quest::varlink($epicRequirement[$epicWeaponLevel][TRADESKILL_ITEM]);
			$client->Message(263, "-----Tradeskill item: $tradeSkillItemLink");
			my $questItemLink = quest::varlink($epicRequirement[$epicWeaponLevel][QUEST_ITEM]);
			$client->Message(263, "-----Quest item: $questItemLink");
			if ($epicWeaponLevel > 0) {
				my $previousEpicLink = quest::varlink($epicWeapon{$class}[$epicWeaponLevel - 1]);
				$client->Message(263, "-----Previous Epic: $previousEpicLink");
			}
		} else {
			$client->Message(315, "Sorry $name, there is not such thing as an Epic 11 Weapon.");
		}
	}
	if ($text=~/resetqglobal/i) {
		if ($debug) {
			# for debugging to reset qglobal
			$client->Message(1,"reset qglobal epic_weapon_level");
			quest::setglobal("epic_weapon_level", 0, 5, "F");
		}
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub EVENT_ITEM {
	establishQuestGlobals();
	my $epicWeaponLevel = $qglobals{epic_weapon_level} or 0;
	my $prestigeLevel = $qglobals{prestige_level} or 0;
	my $guildhallFlag = $qglobals{guildhall_flag} or 0;
	my $unSpentAAs = $client->GetAAPoints();
	
	if ($epicWeaponLevel < 11) {
		if ($ulevel >= $epicRequirement[$epicWeaponLevel][CHAR_LEVEL]) {
			if ($prestigeLevel >= $epicRequirement[$epicWeaponLevel][PRESTIGE_LEVEL]) {
				if ($unSpentAAs >= $epicRequirement[$epicWeaponLevel][AA_COST]) {
					if (plugin::givenCoin(0,0,0,$epicRequirement[$epicWeaponLevel][PLATINUM_COST])) {
						if ($guildhallFlag >= $epicRequirement[$epicWeaponLevel][FLAGS]) {
							if (($epicRequirement[$epicWeaponLevel][TRADESKILL_ITEM] == FALSE) || (plugin::givenItems($epicRequirement[$epicWeaponLevel][TRADESKILL_ITEM] => 1))) {
								if (($epicRequirement[$epicWeaponLevel][QUEST_ITEM] == FALSE) || (plugin::givenItems($epicRequirement[$epicWeaponLevel][QUEST_ITEM] => 1))) {
									if (($epicWeaponLevel == 0) || (plugin::givenItems($epicWeapon{$class}[$epicWeaponLevel - 1] => 1))) {
										$client->SetAAPoints($unSpentAAs - $epicRequirement[$epicWeaponLevel][AA_COST]);
										plugin::takeCoin(0,0,0,$epicRequirement[$epicWeaponLevel][PLATINUM_COST]);
										if ($epicRequirement[$epicWeaponLevel][TRADESKILL_ITEM]) {plugin::takeItems($epicRequirement[$epicWeaponLevel][TRADESKILL_ITEM] => 1);}
										if ($epicRequirement[$epicWeaponLevel][QUEST_ITEM]) {plugin::takeItems($epicRequirement[$epicWeaponLevel][QUEST_ITEM] => 1);}
										if ($epicWeaponLevel > 0) {plugin::takeItems($epicWeapon{$class}[$epicWeaponLevel - 1] => 1);}
										my $epicLink = quest::varlink($epicWeapon{$class}[$epicWeaponLevel]);
										$client->Message(315, "Congratulations $name! Here's your Epic: $epicLink");
										quest::ding(); # not really a ding, it's the quest complete fanfare
										if ($debug) {$client->Message(1,"Epic = $epicWeapon{$class}[$epicWeaponLevel]");} #debug
										quest::summonitem($epicWeapon{$class}[$epicWeaponLevel]);
										if ($epicWeaponLevel == 0) {
											multipleEpics();
										}
										quest::setglobal("epic_weapon_level", ++$epicWeaponLevel, 5, "F");
									} else {
										my $previousEpicLink = quest::varlink($epicWeapon{$class}[$epicWeaponLevel - 1]);
										$client->Message(315, "$name, you need to turn in your previous epic weapon, $previousEpicLink, to receieve the next epic weapon.");
									}
								} else {
									my $questItemLink = quest::varlink($epicRequirement[$epicWeaponLevel][QUEST_ITEM]);
									$client->Message(315, "Sorry $name, you need to give me a $questItemLink as a part of you receiving this epic weapon.");
								}
							} else {
								my $tradeSkillItemLink = quest::varlink($epicRequirement[$epicWeaponLevel][TRADESKILL_ITEM]);
								$client->Message(315, "Alas $name, you need to work on your baking skill, I require $tradeSkillItemLink as a part of you receiving this epic weapon.");
							}
						} else {
							$client->Message(315, "Sorry $name, you need to get a flag, go talk to So-and-so.");
						}
					} else {
						$client->Message(315, "Sorry $name, you need to give me at least $epicRequirement[$epicWeaponLevel][PLATINUM_COST] pp to get your next epic weapon.");
					}
				} else {
					$client->Message(315, "Sorry $name, you do not have enough un-spent AAs. You'll need $epicRequirement[$epicWeaponLevel][AA_COST] AA Points to use to get your next epic weapon.");
				}
			} else {
				$client->Message(315, "Sorry $name, you need to do the Prestige Quest at least $epicRequirement[$epicWeaponLevel][PRESTIGE_LEVEL] times to get your next epic weapon and you've only done it $prestigeLevel times. Go talk to Lenelila");
			}
		} else {
			$client->Message(315, "Unfortunately you need to be at least $epicRequirement[$epicWeaponLevel][CHAR_LEVEL]th level to get your next epic weapon.");
		}
	} else {
		$client->Message(315, "Um $name, you've got your Epic 10 Weapon already and that's as high as it goes, why are you giving me this stuff?");
	}
	plugin::returnUnusedItems();
}

# Args: none
# Returns: void
sub multipleEpics { # accomodate Warrior, Ranger, and Beastlord with multiple epics
	if ($class eq 'Warrior') { # Warrior 1.0
		quest::summonitem(66176); # Blade of Tactics
		quest::summonitem(66177); # Blade of Strategy
	}
	if ($class eq 'Ranger') { # Ranger
		quest::summonitem(20488); # Earthcaller
	}
	if ($class eq 'Beastlord') { # Beastlord
		quest::summonitem(8496); # Claw of the Savage Spirit
	}
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