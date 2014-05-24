# ==============================================================
# Author:		Forest Colver
# Create Date:	8 Nov 2010
# Description:	Set a proximity of an NPC given that you want it to be the same on all sides
# ==============================================================

sub SetProx{	
	my $Range = $_[0];
	my $Z = $_[1];
	my $x = plugin::val('$x');
	my $y = plugin::val('$y');
	my $npc = plugin::val('$npc');
	my $z = $npc->GetZ();
	quest::set_proximity($x - $Range, $x + $Range, $y - $Range, $y + $Range, $z - $Z, $z + $Z);
	}

return 1;