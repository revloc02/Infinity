# ==============================================================
# Author:				Forest Colver
# Create Date:			30 Oct 2010
# Last Edit Date:		4 May 2011
# Software Application:	EQEmu, Infinity Server
# Description:			Hail Buff Bot for buffs appropriate to level
# ==============================================================

sub EVENT_SAY {
	plugin::BuffBot_say($text, $name, $client, $ulevel, $userid);
}