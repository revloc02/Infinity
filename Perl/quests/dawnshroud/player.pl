# ==============================================================
# Author:				Forest Colver
# Create Date:			5 Nov 2010
# Last Edit Date:		31 Mar 2011
# Software Application:	EQEmu, Infinity Server
# Description:			This make the zone a PvP zone.
# Zone:					dawnshroud
# ==============================================================

my $minZoneLevel = 0;
my $maxZoneLevel = 81;

sub EVENT_ENTERZONE {
	if ($ulevel > $maxZoneLevel || $ulevel < $minZoneLevel) {
		$client->Message(15, "The minimum level in this zone is $minZoneLevel and the maximum level is $maxZoneLevel.");
		$client->MovePC(344, 0, 0, 0, 0); # If they are not within proper level limits then port them to GuildLobby
	}
	else {
		#quest::pvp(on);
		#$client->Message(15, "Welcome to dawnshroud. This is a PvP zone. Good luck, you're gonna need it.");
	}
}

sub EVENT_ZONE {
	quest::pvp(off);
	$client->Message(15, "PvP is now turned off.");
}

#END of FILE Zone:dawnshroud  player.pl

