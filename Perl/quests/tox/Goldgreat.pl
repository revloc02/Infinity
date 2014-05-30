#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			21 Apr 2011
# Last Edit Date:		23 Jun 2011
# Software Application:	EQEmu, Infinity Server
# Description:			Hail Newbie Bot for buffs and get free ports
# ==============================================================

#use strict; # uncomment this line for some helpful errors and warning, recomment so that this script will work properly in game
use warnings;

sub EVENT_SAY {
	plugin::NewbieBot_say($text);
}

sub EVENT_SPAWN {
		quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50);
}

sub EVENT_ENTER {
  if(!defined $qglobals{goldgreat_newbie_charm}) {
		quest::setglobal("goldgreat_newbie_charm", 0, 5, "F");
  }
}

sub EVENT_ITEM {
	if (plugin::takeCopper(0)) {
		$client->Message(315, "Yeah, I can consolidate these coins for you.");
	}
	plugin::returnUnusedItems();
}