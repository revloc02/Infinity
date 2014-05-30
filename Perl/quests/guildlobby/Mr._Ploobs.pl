#!/usr/bin/perl
# ==============================================================
# Author:						Forest Colver
# Create Date:					3 Aug 2011
# Last Edit Date:				1 Sep 2011
# Software Application:			EQEmu, Infinity Server
# Description:					AA/Platinum Exchange
# ==============================================================

#use strict; # uncomment this line for some helpful errors and warning, recomment so that this script will work properly in game
use warnings;

use constant {
	MIN_PURCHASE_LEVEL => 51,
	PRICE_TO_BUY_AA => 10000,
	PRICE_TO_SELL_AA => 5000
};

sub EVENT_SAY {
	my $buyAA = quest::saylink("buy",1);
	my $sellAA = quest::saylink("sell",1);
	my $absolutelySure = quest::saylink("absolutely sure",1);
	if ($ulevel >= MIN_PURCHASE_LEVEL) {
		if ($text =~/hail/i) {
			$client->Message(315, "Hello $name, you can $buyAA an AA from me for " . PRICE_TO_BUY_AA . " platinum or you can $sellAA an AA to me and receive " . PRICE_TO_SELL_AA . " platinum.");
		}
		if ($text =~/buy/i) {
			$client->Message(315, "Okay, hand me at least " . PRICE_TO_BUY_AA . " platinum and I will give you another AA.");
		}
		if ($text =~/sell/i) {
			$client->Message(315, "If you are sure you want to sell me an AA you must tell me you are $absolutelySure and then it will be done.");
		}
		if ($text =~/absolutely sure/i) {
			my $unSpentAAs = $client->GetAAPoints();
			if ($unSpentAAs > 0) {
				if(defined $qglobals{AAs_sold}) {
					quest::setglobal("AAs_sold", $qglobals{AAs_sold} + 1, 5, "F");
				} else {
					quest::setglobal("AAs_sold", 1, 5, "F");
				}
				$unSpentAAs--;
				$client->SetAAPoints($unSpentAAs);
				$client->Message(315, "Nice doing business with ya.");
				quest::givecash(0,0,0,PRICE_TO_SELL_AA);
			} else {
				$client->Message(315, "Sorry, you have no un-spent AAs to sell there $name.");
			}
		}
	} else {
		$client->Message(315, "Sorry there young sapling, you must be level " . MIN_PURCHASE_LEVEL . " before I can transact any business with you.");
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub EVENT_ITEM {
	if (plugin::takeCoin(0,0,0,PRICE_TO_BUY_AA)) {
		if(defined $qglobals{AAs_bought}) {
			quest::setglobal("AAs_bought", $qglobals{AAs_bought} + 1, 5, "F"); # increment
		} else {
			quest::setglobal("AAs_bought", 1, 5, "F"); # define qglobal var
		}
		$client->Message(315,"Yes, thank you $name, there's your shiny, new AA point, spend it wisely.");
		$client->AddAAPoints(1);
		quest::ding(); # not really a ding, it's the quest complete fanfare
	} else {
		$client->Message(315,"Sorry $name, that's not enough money to buy anything.");
	}
	plugin::returnUnusedItems();
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}