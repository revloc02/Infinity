#!/usr/bin/perl
# ==============================================================
# Author:						Forest Colver
# Create Date:					30 Oct 2010
# Last Edit Date:				20 Sep 2011
# Software Application:	EQEmu, Infinity Server
# Description:					Spell Scriber -- for all spells for Player (up to curr. level)
# NPC ID = 						344102
# ==============================================================

#use strict; # uncomment this line for some helpful errors and warning, recomment so that this script will work properly in game
use warnings;

sub EVENT_SAY {
	plugin::SpellScriberBot_say($text);
}

sub EVENT_ITEM
{
	plugin::SpellScriberBot_item();
}

sub EVENT_SPAWN {
   quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50);
}

sub EVENT_ENTER {
	if(!defined $qglobals{spells_scribed_level}) {
		quest::setglobal("spells_scribed_level", 0, 5, "F");
	}
}