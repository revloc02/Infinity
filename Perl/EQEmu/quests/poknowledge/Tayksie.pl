#!/usr/bin/perl
# ==============================================================
# Author:				Forest Colver
# Create Date:			5 Nov 2010
# Last Edit Date:		4 May 2011
# Software Application:	EQEmu, Infinity Server
# Description:			Porting Bot
# Zone:					guildlobby, poknowledge
# ==============================================================

use warnings;

sub EVENT_SAY {
	if (!defined $qglobals{prestige_level}) {
		quest::setglobal("prestige_level", 0, 5, "F");
	}
	plugin::TaxiBot_say($text, $name, $client);
}