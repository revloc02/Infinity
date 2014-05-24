# ==============================================================
# Author:				Forest Colver
# Create Date:			1 Nov 2012
# Last Edit Date:		1 Nov 2012
# Software Application:	EQEmu, Infinity Server
# Description:			Epic Weapon NPC
# ==============================================================

#!/usr/bin/perl

$debug = 1;

sub EVENT_SAY {
	if($text=~/Hail/i) {
		$client->Message(315,"I like pink, blue, green,...red, black, and purple. And I like suckers.");
	}
}
