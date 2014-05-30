#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			4 Nov 2010
# Last Edit Date:		2 Dec 2012
# Software Application:	EQEmu, Infinity Server
# Description:			Spell Scriber -- for all spells for Player (up to curr. level)
# ==============================================================

use warnings;

use constant {
	TRUE => 1,
	FALSE => '',
	MAX_SCRIBE_LEVEL => 70,
	SCRIBE_LEVEL_EXPONENT => 3
};

my %GetClassCostMultiplier = (	# Convert each Class Name into a cost multiplier
	"Warrior" => 0.5,
	"Rogue" => 0.5,
	"Monk" => 0.5,
	"Berserker" => 0.5,
	"Shadowknight" => 1,
	"Paladin" => 1,
	"Ranger" => 1,
	"Bard" => 1,
	"Beastlord" => 1,
	"Cleric" => 2,
	"Druid" => 2,
	"Shaman" => 2,
	"Wizard" => 2,
	"Magician" => 2,
	"Enchanter" => 2,
	"Necromancer" => 2
);

my %costTierMultiplier = (	# a cost multiplier for each level range
	1 => 1,
	20 => 2,
	40 => 5,
	60 => 10
);
my $debug = TRUE;

sub SpellScriberBot_say {
	my $text = shift;
	my $name = plugin::val('$name');
	my $qglobals = plugin::var('qglobals');
	my $client = plugin::val('$client');
	
	my $spells = quest::saylink("spells", 1);
	my $calculate = quest::saylink("calculate", 1);
	#my $unscribe = quest::saylink("unscribe",1);

	if ($text =~/hail/i) {
		$client->Message(315, "Good day to you, $name. Would you like me to teach you all of your $spells and disciplines?");
	}
	if ($text =~/spells/i) {
		$client->Message(315, "Great, we can do multiple levels at a time, just give me some money and I will $calculate how many levels that covers and get right to work. I can scribe spells and disciplines beyond your level too, you just won't be able to use them until you are experienced enough. You have previously scribed your spells and disciplines up to level $qglobals->{'spells_scribed_level'}.");
	}
	if ($text =~/calculate/i) {
		$client->Message(315, "Yes, the formula is a bit complex, but let me try and explain it to you. First off caster classes are double the cost of a hybrid class (casters have more spells right) and melee only classes are half the cost of hybrid classes (since they only use disciplines and no spells). So here are the hybrid prices: For levels 1-19 the cost is 1 gold for level one spells, 2 gold for level two spells, 3 gold for level three spells, and so on. Levels 20-39 is twice that, and levels 40-59 is doubled again (so four times 1-19). So to scribe 43rd level spells on a caster class is 43 for the level, times 2 for caster, and times 4 for spells above level 40, 43 x 2 x 4 = 344 gold. Level 60 and higher costs platinum equivalent to the level of spells scribed, so 60 platinum for level 60 spells, 61 platinum for level 61 spells, and so on up to level 70 (and casters classes are double that). Now mind you, don't you fret about remembering the formula, I know it and can calcualte it exactly every time. You just hand me a pile of coins and I'll scribe your spells and give you your change.");
	}
	if ($debug) {
		# for debugging to reset qglobal
		if(($text =~/unscribe/i) || ($text =~/un/i)) {
			quest::unscribespells();
			quest::untraindiscs();
			$client->SetGlobal("spells_scribed_level", 0, 5, "F");
			$client->Message(1,"Unscribed all spells and disciplines and reset qglobal spells_scribed_level");
		}
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub SpellScriberBot_item {
	my $qglobals = plugin::var('qglobals');
	my $name = plugin::val('$name');
	my $client = plugin::val('$client');
	my $class = plugin::val('$class');
	
	my $scribed = $qglobals->{"spells_scribed_level"};
	if ($scribed < MAX_SCRIBE_LEVEL) {
		my $enough = FALSE;
		my $cost = ($scribed + 1)**SCRIBE_LEVEL_EXPONENT * $GetClassCostMultiplier{$class};
		while(($scribed < MAX_SCRIBE_LEVEL) && (plugin::takeCoin($cost,0,0,0))) {
			$scribed++;
			$enough = TRUE;
			$cost = ($scribed + 1)**SCRIBE_LEVEL_EXPONENT * $GetClassCostMultiplier{$class};
		}
		if(!$enough) {
			my $message = "Sorry $name, that's not enough to scribe the next level. You need to give me at least " . (itemizedMoneyString(simplifyMoney($cost,0,0,0)));
			$client->Message(315, $message);
		}else {
			quest::scribespells($scribed);
			quest::traindiscs($scribed);
			$client->SetGlobal("spells_scribed_level", $scribed, 5, "F");
			$client->Message(315, "Thank you $name, I have scribed your spells to level $scribed.");
		}
	} else {
		$client->Message(315, "Hey $name, you're done up to level " . MAX_SCRIBE_LEVEL . " already.");
	}
	plugin::returnUnusedItems();
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

# Args: Array (copper, silver, gold ,platinum)
# Returns: Array (copper, silver, gold ,platinum)
sub simplifyMoney {
	my $myTotalCopper = $_[0] + ($_[1]*10) + ($_[2]*100) + ($_[3]*1000);
	my $c = ($myTotalCopper % 10);
	my $s = (int($myTotalCopper / 10) % 10);
	my $g = (int($myTotalCopper / 100) % 10);
	my $p = int($myTotalCopper / 1000);
	return ($c, $s, $g, $p);	
}

# Args: Array (copper, silver, gold ,platinum)
# Returns: String platGoldSilverCopper
sub itemizedMoneyString {
	my @money;
	($_[3])? push(@money, "$_[3] platinum") : 0;
	($_[2])? push(@money, "$_[2] gold") : 0;
	($_[1])? push(@money, "$_[1] silver") : 0;
	($_[0])? push(@money, "$_[0] copper") : 0;
	return (join(', ', @money));
}

return 1;	#This line is required at the end of every plugin file in order to use it