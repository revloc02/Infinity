#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			10 Feb 2013
# Last Edit Date:		10 Feb 2013
# Software Application:	EQEmu, Infinity Server
# Description:			Fletching Supplies NPC
# ==============================================================

use warnings;

use constant {
	PRICE_FOR_TABOO_ITEM => 50000,
	ITEM_TABOO => 6617 # Mark of Karana
};

sub EVENT_SAY {
	my $Mark = quest::varlink(ITEM_TABOO);
	my $price = PRICE_FOR_TABOO_ITEM;
	if($text=~/Hail/i) {
		quest::say("I'm a shepherd.");
		$client->Message(315,"I am not supposed to do this, but for $price pp I will sell you a $Mark.");
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub EVENT_ITEM {
	
	$silver = $silver + int($copper/10);
	$copper = ($copper%10); #Amount of copper to receive back
	
	$gold = $gold + int($silver/10);
	$silver = ($silver%10); #Amount of silver to receive back
	
	$platinum = $platinum + int($gold/10);
	$gold = ($gold%10); #Amount of gold to receive back
	
	if (plugin::takeCoin(0,0,0,PRICE_FOR_TABOO_ITEM)) {
		quest::summonitem(ITEM_TABOO);
		quest::ding(); # not really a ding, it's the quest complete fanfare
	}
	plugin::returnUnusedItems();
}