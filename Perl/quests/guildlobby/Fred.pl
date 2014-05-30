#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			22 Feb 2013
# Last Edit Date:		22 Feb 2013
# Software Application:	EQEmu, Infinity Server
# Description:			Buy Jackpot tokens
# ==============================================================

use warnings;

use constant {
	COST_BIG_LOTTERY_TICKET => 1000,
	ITEM_BIG_LOTTERY_TICKET => 22503 # blue diamond
};

my $debug = 1;

sub EVENT_SAY {
	my $bigLotteryItemName = quest::varlink(ITEM_BIG_LOTTERY_TICKET);
	if ($text =~/hail/i) {
		$client->Message(315, "Hello $name, you can buy $bigLotteryItemName for Taryn's Big Lottery from me for only " . COST_BIG_LOTTERY_TICKET . " pp a piece. Hand me a pile of money and I'll give you your $bigLotteryItemName stack and your change.");
	}
	$client->Message(315, " "); # This just puts a blank line in to separate blocks of text to make them easier to read
}

sub EVENT_ITEM {
	my $ticketCount =0;
	while (plugin::takeCoin(0,0,0,COST_BIG_LOTTERY_TICKET)) {
		$ticketCount++;
	}
	if ($ticketCount > 0) {
		quest::summonitem(ITEM_BIG_LOTTERY_TICKET, $ticketCount);
		quest::ding(); # not really a ding, it's the quest complete fanfare
	}
	plugin::returnUnusedItems();
}