# ==============================================================
# Author:								Forest Colver
# Create Date:					26 Jul 2011
# Last Edit Date:				26 Jul 2011
# Software Application:	EQEmu, Infinity Server
# Description:					This makes the zone a PvP zone.
# Zone:									unrest
# ==============================================================

my $minZoneLevel = 15;
my $maxZoneLevel = 30;

sub EVENT_ENTERZONE {
	if ($ulevel > $maxZoneLevel || $ulevel < $minZoneLevel) {
		$client->Message(15, "The minimum level in this zone is $minZoneLevel and the maximum level is $maxZoneLevel.");
		$client->MovePC(344, 0, 0, 0, 0); # If they are not within proper level limits then port them to GuildLobby
	}
	else {
		quest::pvp(on); #Turn on PvP
		$client->Message(15, "This is a PvP zone. Good luck, you're gonna need it.");
	}
}

sub EVENT_ZONE {
	quest::pvp(off);
	$client->Message(15, "PvP is now turned off.");
}

#END of FILE Zone:unrest  player.pl

